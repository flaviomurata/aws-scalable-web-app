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
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to the private subnets."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Exactly two private database subnet CIDRs must be provided."
  }
}
