variable "aws_region" {
  description = "AWS Region where project resources are deployed."
  type        = string
  nullable    = false
}

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

variable "vpc_cidr" {
  description = "CIDR block assigned to the project VPC."
  type        = string
  nullable    = false
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to the public subnets."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnet CIDRs must be provided."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to the private subnets."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Exactly two private subnet CIDRs must be provided."
  }
}

variable "db_instance_class" {
  description = "RDS instance class used by the development database."
  type        = string
  nullable    = false
}

variable "app_instance_type" {
  description = "EC2 instance type used by the application."
  type        = string
  default     = "t3.micro"
}

variable "app_min_size" {
  description = "Minimum number of application instances."
  type        = number
  default     = 2
}

variable "app_max_size" {
  description = "Maximum number of application instances."
  type        = number
  default     = 4
}

variable "app_target_cpu_utilization" {
  description = "Average CPU utilization target for application Auto Scaling."
  type        = number
  default     = 50
}
