variable "project_name" {
  description = "Name used to identify project resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "load_balancer_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the application target group."
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the application Auto Scaling Group."
  type        = string
}

variable "autoscaling_group_min_size" {
  description = "Minimum expected number of in-service application instances."
  type        = number
}

variable "db_instance_id" {
  description = "Identifier of the RDS database instance."
  type        = string
}

variable "rds_cpu_threshold" {
  description = "RDS CPU utilization percentage that triggers an alarm."
  type        = number
  default     = 80
}

variable "rds_free_storage_threshold_bytes" {
  description = "RDS free storage threshold in bytes."
  type        = number
  default     = 2147483648 # 2 GiB
}

variable "aws_region" {
  description = "AWS Region where observability resources are deployed."
  type        = string
}
