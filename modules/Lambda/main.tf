resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description

  package_type = var.package_type
  runtime      = var.runtime
  handler      = var.handler

  filename         = var.filename
  source_code_hash = var.source_code_hash

  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version

  role          = local.effective_execution_role_arn
  architectures = [var.architecture]

  memory_size = var.memory_size
  timeout     = var.timeout
  publish     = var.publish

  reserved_concurrent_executions = var.reserved_concurrent_executions

  kms_key_arn = var.kms_key_arn

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [var.environment_variables] : []

    content {
      variables = environment.value
    }
  }

  dynamic "vpc_config" {
    for_each = var.enable_vpc_config ? [1] : []

    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  dynamic "tracing_config" {
    for_each = var.enable_xray_tracing ? [1] : []

    content {
      mode = "Active"
    }
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.basic_execution,
    aws_iam_role_policy_attachment.vpc_access,
    aws_iam_role_policy_attachment.additional,
    aws_iam_role_policy.additional_inline,
    aws_cloudwatch_log_group.lambda
  ]

  lifecycle {
    precondition {
      condition = (
        local.use_local_package != local.use_s3_package &&
        (
          local.use_local_package ||
          (
            var.s3_bucket != null &&
            var.s3_key != null
          )
        )
      )
      error_message = "Specify exactly one deployment source: filename, or both s3_bucket and s3_key."
    }

    precondition {
      condition = (
        !var.enable_vpc_config ||
        (
          length(var.subnet_ids) > 0 &&
          length(var.security_group_ids) > 0
        )
      )
      error_message = "When VPC configuration is enabled, provide at least one subnet ID and one security group ID."
    }
  }
}