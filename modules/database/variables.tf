variable "project_name" {
  description = "Name used to identify resources belonging to this project."
  type        = string
  nullable    = false
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  nullable    = false
}

variable "vpc_id" {
  description = "ID of the VPC where the database is deployed."
  type        = string
  nullable    = false
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the RDS DB subnet group."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "RDS requires private subnets in at least two Availability Zones."
  }
}

variable "availability_zone" {
  description = "Availability Zone where the Single-AZ RDS instance is deployed."
  type        = string
  nullable    = false
}

variable "db_instance_class" {
  description = "RDS DB instance class."
  type        = string
  nullable    = false
}

variable "db_name" {
  description = "Initial MySQL database name."
  type        = string
  default     = "STUDENTS"
}

variable "db_username" {
  description = "RDS master username."
  type        = string
  default     = "nodeapp"
}

variable "db_password_version" {
  description = "Version number used to intentionally rotate the database password."
  type        = number
  default     = 1
}
