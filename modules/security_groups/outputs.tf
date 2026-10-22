output "alb_security_group_id" {
  description = "ID of the Application Load Balancer security group."
  value       = aws_security_group.alb.id
}

output "application_security_group_id" {
  description = "ID of the application security group."
  value       = aws_security_group.application.id
}

output "database_security_group_id" {
  description = "ID of the database security group."
  value       = aws_security_group.database.id
}

output "security_group_ids" {
  description = "Map of security group tier names to their IDs."
  value = {
    alb         = aws_security_group.alb.id
    application = aws_security_group.application.id
    database    = aws_security_group.database.id
  }
}