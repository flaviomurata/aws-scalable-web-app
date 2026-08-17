output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.id
}

output "github_plan_role_arn" {
  description = "IAM role assumed by GitHub Actions when running Terraform plans."
  value       = aws_iam_role.github_plan.arn
}
