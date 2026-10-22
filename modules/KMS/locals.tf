locals {
  key_name = "${var.name}-kms-key"

  alias_name = "alias/${var.name}-kms-key"

  common_tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
    }
  )
}