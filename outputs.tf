output "vpc_id" {
  description = "ID of the project VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "IDs of the public subnets."
  value       = module.networking.public_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.networking.private_subnet_ids
}
