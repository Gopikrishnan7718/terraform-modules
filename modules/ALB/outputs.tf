
output "alb_id" {
  description = "ID of the Application Load Balancer."
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer for CloudWatch metrics."
  value       = aws_lb.this.arn_suffix
}

output "alb_dns_name" {
  description = "DNS name assigned to the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID for Route 53 alias records."
  value       = aws_lb.this.zone_id
}

output "alb_name" {
  description = "Name of the Application Load Balancer."
  value       = aws_lb.this.name
}

output "target_group_arn" {
  description = "ARN of the target group for Auto Scaling Group integration."
  value       = aws_lb_target_group.this.arn
}

output "target_group_arn_suffix" {
  description = "Target group ARN suffix for CloudWatch metrics."
  value       = aws_lb_target_group.this.arn_suffix
}

output "target_group_name" {
  description = "Name of the target group."
  value       = aws_lb_target_group.this.name
}

output "target_group_id" {
  description = "ID of the target group."
  value       = aws_lb_target_group.this.id
}

output "http_listener_arn" {
  description = "ARN of the direct HTTP forwarding listener, or null when HTTPS is enabled."
  value       = var.enable_https ? null : aws_lb_listener.http[0].arn
}

output "http_redirect_listener_arn" {
  description = "ARN of the HTTP-to-HTTPS redirect listener, or null when HTTPS is disabled."
  value       = var.enable_https ? aws_lb_listener.http_redirect[0].arn : null
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener, or null when HTTPS is disabled."
  value       = var.enable_https ? aws_lb_listener.https[0].arn : null
}
