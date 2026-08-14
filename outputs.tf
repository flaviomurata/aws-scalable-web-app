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

output "application_instance_id" {
  description = "ID of the standalone application instance."
  value       = module.application.instance_id
}
