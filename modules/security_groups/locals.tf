locals {
  security_group_names = {
    alb         = "${var.name}-alb-sg"
    application = "${var.name}-application-sg"
    database    = "${var.name}-database-sg"
  }

  common_tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
    }
  )
}