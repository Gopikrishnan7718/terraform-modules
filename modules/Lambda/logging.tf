resource "aws_cloudwatch_log_group" "lambda" {
  count = var.logging_enabled ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.log_group_kms_key_id

  tags = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}