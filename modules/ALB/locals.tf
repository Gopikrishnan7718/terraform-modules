locals {
  alb_name          = "${var.name}-alb"
  target_group_name = "${var.name}-tg"

  common_tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
      Name      = local.alb_name
      Tier      = "network"
    }
  )
}
