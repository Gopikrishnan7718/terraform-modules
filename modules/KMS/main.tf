resource "aws_kms_key" "this" {
  description = var.description

  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

  bypass_policy_lockout_safety_check = false

  policy = data.aws_iam_policy_document.this.json

  tags = merge(
    local.common_tags,
    {
      Name = local.key_name
      Tier = "security"
    }
  )
}

resource "aws_kms_alias" "this" {
  name          = local.alias_name
  target_key_id = aws_kms_key.this.key_id
}