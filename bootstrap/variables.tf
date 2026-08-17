variable "aws_region" {
  description = "AWS Region where the Terraform state bucket is created."
  type        = string
  nullable    = false
}

variable "project_name" {
  description = "Name used to identify project resources."
  type        = string
  nullable    = false
}
