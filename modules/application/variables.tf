variable "project_name" {
  description = "Name used to identify project resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS Region where resources are deployed."
  type        = string
}

variable "vpc_id" {
  description = "ID of the application VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets used by the Application Load Balancer."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "The ALB requires public subnets in at least two Availability Zones."
  }
}

variable "private_subnet_ids" {
  description = "Private subnets available for application instances."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 1
    error_message = "At least one private subnet is required."
  }
}

variable "database_security_group_id" {
  description = "Security group associated with the RDS database."
  type        = string
}

variable "application_secret_arn" {
  description = "ARN of the Secrets Manager secret consumed by the application."
  type        = string
}

variable "application_secret_name" {
  description = "Name of the Secrets Manager secret consumed by the application."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by the application."
  type        = string
  default     = "t3.micro"
}
