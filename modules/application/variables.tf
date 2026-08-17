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
  description = "Private subnets used by application instances across Availability Zones."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets are required for the multi-AZ Auto Scaling Group."
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

variable "min_size" {
  description = "Minimum number of application instances maintained by the Auto Scaling Group."
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 1
    error_message = "min_size must be at least 1."
  }
}

variable "max_size" {
  description = "Maximum number of application instances allowed by the Auto Scaling Group."
  type        = number
  default     = 4
}

variable "target_cpu_utilization" {
  description = "Average CPU utilization target maintained by the Auto Scaling Group."
  type        = number
  default     = 50

  validation {
    condition = (
      var.target_cpu_utilization > 0 &&
      var.target_cpu_utilization <= 100
    )

    error_message = "target_cpu_utilization must be greater than 0 and at most 100."
  }
}
