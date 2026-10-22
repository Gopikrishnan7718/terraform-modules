locals {
  bucket_name = format(
    "%s-%s-%s-an",
    var.name,
    data.aws_caller_identity.current.account_id,
    data.aws_region.current.region
  )

  common_tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
    }
  )
}