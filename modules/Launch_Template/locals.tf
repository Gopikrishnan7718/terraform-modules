locals {
  launch_template_name = "${var.name}-launch-template"

  common_tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
      Name      = local.launch_template_name
      Tier      = "compute"
    }
  )
}