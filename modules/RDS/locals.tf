
locals {
  # Engine-specific default listener ports.
  default_ports = {
    postgres = 5432
    mysql    = 3306
    mariadb  = 3306
  }

  effective_port = (
    var.port != null
    ? var.port
    : local.default_ports[var.engine]
  )

  # Merge common tags with environment-specific overrides.
  common_tags = merge(
    var.tags,
    var.environment_tags,
    {
      ManagedBy   = "Terraform"
      Name        = var.identifier
      Environment = lookup(var.environment_tags, "Environment", "unspecified")
    }
  )

  # Names for related resources.
  subnet_group_name   = "${var.identifier}-subnet-group"
  security_group_name = "${var.identifier}-sg"
  cpu_alarm_name      = "${var.identifier}-cpu-utilization"
  storage_alarm_name  = "${var.identifier}-free-storage"

  # Monitoring configuration.
  enhanced_monitoring_enabled = var.monitoring_interval > 0

  create_monitoring_role = (
    local.enhanced_monitoring_enabled &&
    var.monitoring_role_arn == null
  )

  effective_monitoring_role_arn = (
    var.monitoring_role_arn != null
    ? var.monitoring_role_arn
    : try(aws_iam_role.rds_monitoring[0].arn, null)
  )

  # Storage autoscaling configuration.
  storage_autoscaling_enabled = var.max_allocated_storage > 0
}
