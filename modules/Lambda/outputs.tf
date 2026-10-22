output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function."
  value       = aws_lambda_function.this.arn
}

output "function_invoke_arn" {
  description = "Invocation ARN of the Lambda function for API Gateway integrations."
  value       = aws_lambda_function.this.invoke_arn
}

output "function_version" {
  description = "Published version of the Lambda function, or $LATEST when publishing is disabled."
  value       = aws_lambda_function.this.version
}

output "function_qualified_arn" {
  description = "Qualified ARN of the Lambda function."
  value       = aws_lambda_function.this.qualified_arn
}

output "execution_role_arn" {
  description = "ARN of the Lambda execution role, whether created or reused."
  value       = local.effective_execution_role_arn
}

output "execution_role_name" {
  description = "Name of the Lambda execution role when available."
  value = (
    var.execution_role_arn == null
    ? aws_iam_role.this[0].name
    : element(reverse(split("/", var.execution_role_arn)), 0)
  )
}

output "log_group_name" {
  description = "CloudWatch log group name, if managed by this module."
  value       = var.logging_enabled ? aws_cloudwatch_log_group.lambda[0].name : null
}

output "log_group_arn" {
  description = "CloudWatch log group ARN, if managed by this module."
  value       = var.logging_enabled ? aws_cloudwatch_log_group.lambda[0].arn : null
}