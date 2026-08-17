output "autoscaling_group_name" {
  description = "Name of the application Auto Scaling Group."
  value       = aws_autoscaling_group.main.name
}

output "load_balancer_dns_name" {
  description = "DNS name of the public Application Load Balancer."
  value       = aws_lb.application.dns_name
}

output "application_url" {
  description = "HTTP URL of the student records application."
  value       = "http://${aws_lb.application.dns_name}"
}

output "load_balancer_arn_suffix" {
  description = "ARN suffix used as the CloudWatch LoadBalancer metric dimension."
  value       = aws_lb.application.arn_suffix
}

output "target_group_arn_suffix" {
  description = "ARN suffix used as the CloudWatch TargetGroup metric dimension."
  value       = aws_lb_target_group.application.arn_suffix
}
