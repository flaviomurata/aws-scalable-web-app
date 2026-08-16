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
