
locals {
  autoscaling_group_name = "${var.name}-asg"

  common_tags = merge(var.common_tags, {
    ManagedBy = "Terraform"
    Name      = local.autoscaling_group_name
    Tier      = "compute"
  })
}
