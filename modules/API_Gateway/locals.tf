
locals {
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Project   = var.name
  })

  routes = {
    for key, route in var.routes : key => route
  }

  access_log_enabled = var.access_log_destination_arn != null
}
