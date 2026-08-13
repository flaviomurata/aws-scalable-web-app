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
  description = "CIDR block assigned to the VPC."
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
}
