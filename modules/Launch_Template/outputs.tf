output "launch_template_id" {
  description = "ID of the EC2 Launch Template."
  value       = aws_launch_template.this.id
}

output "launch_template_arn" {
  description = "ARN of the EC2 Launch Template."
  value       = aws_launch_template.this.arn
}

output "launch_template_name" {
  description = "Name of the EC2 Launch Template."
  value       = aws_launch_template.this.name
}

output "latest_version" {
  description = "Latest version number of the Launch Template."
  value       = aws_launch_template.this.latest_version
}

output "default_version" {
  description = "Default version number of the Launch Template."
  value       = aws_launch_template.this.default_version
}