
resource "aws_cloudwatch_log_group" "cluster" {
  name              = local.cluster_log_group_name
  retention_in_days = var.cluster_log_retention_in_days
  kms_key_id        = var.cluster_log_group_kms_key_id
  skip_destroy      = var.cluster_log_group_skip_destroy

  tags = merge(
    local.common_tags,
    {
      Name = local.cluster_log_group_name
    }
  )
}
