output "log_group_names" {
  description = "Map of Terraform log-group keys to CloudWatch log group names."
  value       = { for key, group in aws_cloudwatch_log_group.this : key => group.name }
}

output "log_group_arns" {
  description = "Map of Terraform log-group keys to CloudWatch log group ARNs."
  value       = { for key, group in aws_cloudwatch_log_group.this : key => group.arn }
}

output "alarm_names" {
  description = "Map of Terraform alarm keys to CloudWatch alarm names."
  value       = { for key, alarm in aws_cloudwatch_metric_alarm.this : key => alarm.alarm_name }
}

output "alarm_arns" {
  description = "Map of Terraform alarm keys to CloudWatch alarm ARNs."
  value       = { for key, alarm in aws_cloudwatch_metric_alarm.this : key => alarm.arn }
}