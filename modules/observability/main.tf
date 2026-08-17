data "aws_caller_identity" "current" {}

#trivy:ignore:AWS-0095
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"
}

data "aws_iam_policy_document" "alerts" {
  statement {
    sid    = "AllowCloudWatchAlarms"
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = [
      aws_sns_topic.alerts.arn,
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudwatch.amazonaws.com",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:cloudwatch:${var.aws_region}:${data.aws_caller_identity.current.account_id}:alarm:${var.project_name}-${var.environment}-*",
      ]
    }
  }
}

resource "aws_sns_topic_policy" "alerts" {
  arn    = aws_sns_topic.alerts.arn
  policy = data.aws_iam_policy_document.alerts.json
}

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

  alarm_actions = [
    aws_sns_topic.alerts.arn,
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn,
  ]

  depends_on = [
    aws_sns_topic_policy.alerts,
  ]
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

  alarm_actions = [
    aws_sns_topic.alerts.arn,
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn,
  ]

  depends_on = [
    aws_sns_topic_policy.alerts,
  ]
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

  alarm_actions = [
    aws_sns_topic.alerts.arn,
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn,
  ]

  depends_on = [
    aws_sns_topic_policy.alerts,
  ]
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

  alarm_actions = [
    aws_sns_topic.alerts.arn,
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn,
  ]

  depends_on = [
    aws_sns_topic_policy.alerts,
  ]
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

  alarm_actions = [
    aws_sns_topic.alerts.arn,
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn,
  ]

  depends_on = [
    aws_sns_topic_policy.alerts,
  ]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}"

  dashboard_body = jsonencode({
    start          = "-PT3H"
    periodOverride = "inherit"

    widgets = [
      {
        type   = "alarm"
        x      = 0
        y      = 0
        width  = 24
        height = 4

        properties = {
          title  = "Operational alarm status"
          sortBy = "stateUpdatedTimestamp"

          alarms = [
            aws_cloudwatch_metric_alarm.unhealthy_targets.arn,
            aws_cloudwatch_metric_alarm.target_5xx.arn,
            aws_cloudwatch_metric_alarm.asg_capacity.arn,
            aws_cloudwatch_metric_alarm.rds_cpu.arn,
            aws_cloudwatch_metric_alarm.rds_free_storage.arn,
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 4
        width  = 12
        height = 6

        properties = {
          title   = "Unhealthy application targets"
          region  = var.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 60
          stat    = "Maximum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "UnHealthyHostCount",
              "LoadBalancer",
              var.load_balancer_arn_suffix,
              "TargetGroup",
              var.target_group_arn_suffix,
            ],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 4
        width  = 12
        height = 6

        properties = {
          title   = "Application HTTP 5xx"
          region  = var.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 300
          stat    = "Sum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_Target_5XX_Count",
              "LoadBalancer",
              var.load_balancer_arn_suffix,
              "TargetGroup",
              var.target_group_arn_suffix,
            ],
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 10
        width  = 12
        height = 6

        properties = {
          title   = "Auto Scaling capacity"
          region  = var.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 60
          stat    = "Average"

          metrics = [
            [
              "AWS/AutoScaling",
              "GroupDesiredCapacity",
              "AutoScalingGroupName",
              var.autoscaling_group_name,
            ],
            [
              "AWS/AutoScaling",
              "GroupInServiceInstances",
              "AutoScalingGroupName",
              var.autoscaling_group_name,
            ],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 10
        width  = 12
        height = 6

        properties = {
          title   = "RDS CPU utilization"
          region  = var.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 300
          stat    = "Average"

          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "DBInstanceIdentifier",
              var.db_instance_id,
            ],
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 16
        width  = 24
        height = 6

        properties = {
          title   = "RDS free storage"
          region  = var.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 300
          stat    = "Average"

          metrics = [
            [
              "AWS/RDS",
              "FreeStorageSpace",
              "DBInstanceIdentifier",
              var.db_instance_id,
            ],
          ]
        }
      },
    ]
  })
}
