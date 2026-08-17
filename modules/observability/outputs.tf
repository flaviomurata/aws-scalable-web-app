output "alert_topic_arn" {
  description = "ARN of the SNS topic receiving operational alerts."
  value       = aws_sns_topic.alerts.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch operational dashboard."
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
