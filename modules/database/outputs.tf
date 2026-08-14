output "db_instance_id" {
  description = "ID of the RDS DB instance."
  value       = aws_db_instance.main.id
}

output "db_address" {
  description = "DNS address of the RDS DB instance."
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "Port used by the RDS DB instance."
  value       = aws_db_instance.main.port
}

output "database_security_group_id" {
  description = "Security group ID associated with the RDS DB instance."
  value       = aws_security_group.database.id
}

output "application_secret_arn" {
  description = "ARN of the database secret consumed by the application."
  value       = aws_secretsmanager_secret.application_database.arn
}

output "application_secret_name" {
  description = "Name of the database secret consumed by the application."
  value       = aws_secretsmanager_secret.application_database.name
}
