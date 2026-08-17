resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name        = "${var.project_name}-${var.environment}-unhealthy-targets"
  alarm_description = "Application Load Balancer has unhealthy application targets."

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  alarm_name        = "${var.project_name}-${var.environment}-target-5xx"
  alarm_description = "Application targets are returning HTTP 5xx responses."

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 5

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "asg_capacity" {
  alarm_name        = "${var.project_name}-${var.environment}-asg-capacity"
  alarm_description = "Auto Scaling Group has fewer in-service instances than its configured minimum."

  namespace   = "AWS/AutoScaling"
  metric_name = "GroupInServiceInstances"

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 5
  datapoints_to_alarm = 5

  comparison_operator = "LessThanThreshold"
  threshold           = var.autoscaling_group_min_size

  treat_missing_data = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name        = "${var.project_name}-${var.environment}-rds-cpu"
  alarm_description = "RDS CPU utilization is persistently high."

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  datapoints_to_alarm = 3

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.rds_cpu_threshold

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  alarm_name        = "${var.project_name}-${var.environment}-rds-free-storage"
  alarm_description = "RDS free storage is running low."

  namespace   = "AWS/RDS"
  metric_name = "FreeStorageSpace"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  datapoints_to_alarm = 3

  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = var.rds_free_storage_threshold_bytes

  treat_missing_data = "notBreaching"
}
