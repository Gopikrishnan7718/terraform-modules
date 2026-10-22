
output "db_instance_id" {
  description = "Identifier of the RDS DB instance."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "ARN of the RDS DB instance."
  value       = aws_db_instance.this.arn
}

output "db_instance_endpoint" {
  description = "Connection endpoint, including the port, for the RDS DB instance."
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "DNS address of the RDS DB instance."
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "Database listener port."
  value       = aws_db_instance.this.port
}

output "db_instance_engine" {
  description = "Database engine."
  value       = aws_db_instance.this.engine
}

output "db_instance_engine_version" {
  description = "Database engine version."
  value       = aws_db_instance.this.engine_version
}

output "db_instance_status" {
  description = "Current status reported for the RDS DB instance."
  value       = aws_db_instance.this.status
}

output "db_instance_resource_id" {
  description = "AWS resource ID used by certain RDS integrations."
  value       = aws_db_instance.this.resource_id
}

output "db_subnet_group_name" {
  description = "Name of the RDS DB subnet group."
  value       = aws_db_subnet_group.this.name
}

output "db_security_group_id" {
  description = "Security group ID attached to the RDS DB instance."
  value       = aws_security_group.this.id
}

output "monitoring_role_arn" {
  description = "IAM role ARN used for RDS Enhanced Monitoring, or null when Enhanced Monitoring is disabled."
  value       = local.enhanced_monitoring_enabled ? local.effective_monitoring_role_arn : null
}

output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm, or null when CloudWatch alarms are disabled."
  value       = var.cloudwatch_alarms_enabled ? aws_cloudwatch_metric_alarm.cpu_utilization[0].arn : null
}

output "free_storage_alarm_arn" {
  description = "ARN of the free storage alarm, or null when CloudWatch alarms are disabled."
  value       = var.cloudwatch_alarms_enabled ? aws_cloudwatch_metric_alarm.free_storage[0].arn : null
}
