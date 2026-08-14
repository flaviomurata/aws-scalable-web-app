output "instance_id" {
  description = "ID of the standalone application EC2 instance."
  value       = aws_instance.application.id
}

output "load_balancer_dns_name" {
  description = "DNS name of the public Application Load Balancer."
  value       = aws_lb.application.dns_name
}

output "application_url" {
  description = "HTTP URL of the student records application."
  value       = "http://${aws_lb.application.dns_name}"
}
