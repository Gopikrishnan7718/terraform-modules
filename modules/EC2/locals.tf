locals {
  common_tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
      Name      = var.name
      Tier      = "compute"
    }
  )
}