locals {
  application_port        = 3000
  instance_warmup_seconds = 600
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_security_group" "load_balancer" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  description = "Security group for the public Application Load Balancer."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
}

resource "aws_security_group" "application" {
  name_prefix = "${var.project_name}-${var.environment}-app-"
  description = "Security group for application instances."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_from_internet_http" {
  security_group_id = aws_security_group.load_balancer.id

  description = "Allow HTTP traffic from the internet"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app_http" {
  security_group_id = aws_security_group.load_balancer.id

  description = "Allow HTTP traffic from the ALB to the application instances"

  referenced_security_group_id = aws_security_group.application.id

  from_port   = local.application_port
  to_port     = local.application_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb_http" {
  security_group_id = aws_security_group.application.id

  description = "Allow HTTP traffic from the ALB"

  referenced_security_group_id = aws_security_group.load_balancer.id

  from_port   = local.application_port
  to_port     = local.application_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_internet_http" {
  security_group_id = aws_security_group.application.id

  description = "Allow HTTP traffic from the application instances to the internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_internet_https" {
  security_group_id = aws_security_group.application.id

  description = "Allow HTTPS traffic from the application instances to the internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_db_mysql" {
  security_group_id = aws_security_group.application.id

  description = "Allow MySQL traffic from the application instances to the database"

  referenced_security_group_id = var.database_security_group_id

  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app_mysql" {
  security_group_id = var.database_security_group_id

  description = "Allow MySQL traffic from the application instances"

  referenced_security_group_id = aws_security_group.application.id

  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"
}

data "aws_iam_policy_document" "application_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "application" {
  name = "${var.project_name}-${var.environment}-app"

  assume_role_policy = data.aws_iam_policy_document.application_assume_role.json
}

data "aws_iam_policy_document" "application_secret" {
  statement {
    sid    = "ReadApplicationDatabaseSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      var.application_secret_arn,
    ]
  }
}

resource "aws_iam_role_policy" "application_secret" {
  name = "${var.project_name}-${var.environment}-secret-read"
  role = aws_iam_role.application.name

  policy = data.aws_iam_policy_document.application_secret.json
}

resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.application.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "application" {
  name = "${var.project_name}-${var.environment}-app"
  role = aws_iam_role.application.name
}

resource "aws_launch_template" "application" {
  name_prefix = "${var.project_name}-${var.environment}-app-"

  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.application.id,
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.application.name
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(templatefile(
    "${path.module}/templates/user_data.sh.tftpl",
    {
      aws_region              = var.aws_region
      app_port                = local.application_port
      application_secret_name = var.application_secret_name
      schema_sql_base64       = base64encode(file("${path.module}/files/schema.sql"))
      config_js_base64        = base64encode(file("${path.module}/files/config.js"))
    }
  ))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-${var.environment}-app"
    }
  }

  monitoring {
    enabled = true
  }
}

resource "aws_lb" "application" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.load_balancer.id,
  ]

  subnets = var.public_subnet_ids
}

resource "aws_lb_target_group" "application" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = local.application_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }
}

data "aws_default_tags" "current" {}

resource "aws_autoscaling_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-main-"

  min_size = var.min_size
  max_size = var.max_size

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    aws_lb_target_group.application.arn,
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 600

  launch_template {
    id      = aws_launch_template.application.id
    version = aws_launch_template.application.latest_version
  }

  dynamic "tag" {
    for_each = merge(
      data.aws_default_tags.current.tags,
      {
        Name = "${var.project_name}-${var.environment}-app"
      }
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = local.instance_warmup_seconds
      auto_rollback          = true
      skip_matching          = true
    }
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
  ]

  metrics_granularity = "1Minute"
}

resource "aws_autoscaling_policy" "cpu_target" {
  name = "${var.project_name}-${var.environment}-cpu-target-tracking"

  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.target_cpu_utilization
  }
}
