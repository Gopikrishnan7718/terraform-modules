
data "aws_partition" "current" {}

data "aws_iam_policy_document" "rds_monitoring_assume_role" {
  count = local.create_monitoring_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_monitoring" {
  count = local.create_monitoring_role ? 1 : 0

  name               = "${substr(var.identifier, 0, 50)}-rds-monitoring"
  description        = "Enhanced Monitoring role for RDS instance ${var.identifier}"
  assume_role_policy = data.aws_iam_policy_document.rds_monitoring_assume_role[0].json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = local.create_monitoring_role ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count = var.cloudwatch_alarms_enabled ? 1 : 0

  alarm_name        = local.cpu_alarm_name
  alarm_description = "RDS CPU utilization is above the configured threshold."

  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = var.cpu_alarm_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }

  treat_missing_data = "missing"
  alarm_actions      = var.alarm_actions
  ok_actions         = var.alarm_actions

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "free_storage" {
  count = var.cloudwatch_alarms_enabled ? 1 : 0

  alarm_name        = local.storage_alarm_name
  alarm_description = "RDS free storage is below the configured threshold."

  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = var.free_storage_alarm_threshold_bytes
  comparison_operator = "LessThanOrEqualToThreshold"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }

  treat_missing_data = "missing"
  alarm_actions      = var.alarm_actions
  ok_actions         = var.alarm_actions

  tags = local.common_tags
}
