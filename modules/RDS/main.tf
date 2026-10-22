
resource "aws_db_instance" "this" {
  identifier     = var.identifier
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  db_name        = var.database_name
  username       = var.master_username
  port           = local.effective_port

  allocated_storage     = var.allocated_storage
  max_allocated_storage = local.storage_autoscaling_enabled ? var.max_allocated_storage : 0
  storage_type          = var.storage_type

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.storage_encrypted ? var.kms_key_id : null

  manage_master_user_password = var.manage_master_user_password

  master_user_secret_kms_key_id = (
    var.manage_master_user_password
    ? var.master_user_secret_kms_key_id
    : null
  )

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  publicly_accessible = var.publicly_accessible
  multi_az            = var.multi_az

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  deletion_protection   = var.deletion_protection
  skip_final_snapshot   = var.skip_final_snapshot

  final_snapshot_identifier = (
    var.skip_final_snapshot
    ? null
    : coalesce(var.final_snapshot_identifier, "${var.identifier}-final-snapshot")
  )

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  parameter_group_name = var.parameter_group_name
  option_group_name    = var.option_group_name
  license_model        = var.license_model
  ca_cert_identifier   = var.ca_cert_identifier

  performance_insights_enabled = var.performance_insights_enabled

  performance_insights_retention_period = (
    var.performance_insights_enabled
    ? var.performance_insights_retention_period
    : null
  )

  monitoring_interval = var.monitoring_interval

  monitoring_role_arn = (
    local.enhanced_monitoring_enabled
    ? local.effective_monitoring_role_arn
    : null
  )

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = local.common_tags

  lifecycle {
    precondition {
      condition = (
        local.storage_autoscaling_enabled
        ? var.max_allocated_storage >= var.allocated_storage
        : true
      )
      error_message = "max_allocated_storage must be greater than or equal to allocated_storage when storage autoscaling is enabled."
    }

    precondition {
      condition     = var.storage_encrypted || var.kms_key_id == null
      error_message = "kms_key_id can only be specified when storage_encrypted is true."
    }

    precondition {
      condition     = var.manage_master_user_password
      error_message = "This module requires RDS-managed master credentials through AWS Secrets Manager."
    }

    precondition {
      condition = (
        var.manage_master_user_password ||
        var.master_user_secret_kms_key_id == null
      )
      error_message = "master_user_secret_kms_key_id can only be specified when manage_master_user_password is true."
    }

    precondition {
      condition = (
        var.monitoring_interval == 0 ||
        local.effective_monitoring_role_arn != null
      )
      error_message = "Enhanced Monitoring requires a valid monitoring_role_arn or a monitoring role created by this module."
    }

    precondition {
      condition     = !var.publicly_accessible
      error_message = "This module is designed for private RDS deployments. Set publicly_accessible to false."
    }
  }

  depends_on = [
    aws_db_subnet_group.this,
    aws_security_group.this,
    aws_iam_role_policy_attachment.rds_monitoring
  ]
}
