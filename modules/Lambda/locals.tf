locals {
  common_tags = merge(var.common_tags, var.extra_environment_tags, {
    ManagedBy = "Terraform"
    Project   = var.function_name
  })

  use_local_package = var.filename != null
  use_s3_package    = var.s3_bucket != null || var.s3_key != null

  create_execution_role = var.execution_role_arn == null

  effective_role_name = (
    var.role_name != null
    ? var.role_name
    : "${substr(var.function_name, 0, 47)}-execution-role"
  )

  effective_execution_role_arn = (
    var.execution_role_arn != null
    ? var.execution_role_arn
    : aws_iam_role.this[0].arn
  )

  log_group_name = "/aws/lambda/${var.function_name}"
}