output "vpc_id" {
  description = "ID of the project VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.networking.private_subnet_ids
}

output "db_address" {
  description = "DNS address of the RDS database."
  value       = module.database.db_address
}

output "database_security_group_id" {
  description = "Security group ID associated with the RDS database."
  value       = module.database.database_security_group_id
}

output "application_database_secret_arn" {
  description = "ARN of the database secret consumed by the application."
  value       = module.database.application_secret_arn
}

output "application_url" {
  description = "URL of the student records application."
  value       = module.application.application_url
}

output "application_autoscaling_group_name" {
  description = "Name of the application Auto Scaling Group."
  value       = module.application.autoscaling_group_name
}

output "alert_topic_arn" {
  description = "ARN of the SNS topic receiving operational alerts."
  value       = module.observability.alert_topic_arn
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch operational dashboard."
  value       = module.observability.dashboard_name
}
