
output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group."
  value       = aws_autoscaling_group.this.id
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group."
  value       = aws_autoscaling_group.this.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group."
  value       = aws_autoscaling_group.this.name
}

output "min_size" {
  description = "Minimum number of instances configured for the Auto Scaling Group."
  value       = aws_autoscaling_group.this.min_size
}

output "max_size" {
  description = "Maximum number of instances configured for the Auto Scaling Group."
  value       = aws_autoscaling_group.this.max_size
}

output "desired_capacity" {
  description = "Desired number of instances configured for the Auto Scaling Group."
  value       = aws_autoscaling_group.this.desired_capacity
}

output "availability_zones" {
  description = "Availability Zones in which the Auto Scaling Group can launch instances."
  value       = aws_autoscaling_group.this.availability_zones
}

output "target_group_arns" {
  description = "Target group ARNs associated with the Auto Scaling Group."
  value       = aws_autoscaling_group.this.target_group_arns
}

output "launch_template_id" {
  description = "Launch Template ID used by the Auto Scaling Group."
  value       = var.launch_template_id
}

output "launch_template_version" {
  description = "Launch Template version configured for the Auto Scaling Group."
  value       = var.launch_template_version
}
