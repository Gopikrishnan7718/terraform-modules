output "record_name" {
  description = "Normalized DNS record name managed by this module."
  value       = local.record_name
}

output "record_fqdn" {
  description = "Fully qualified DNS name of the A alias record."
  value       = aws_route53_record.alb_a.fqdn
}

output "record_zone_id" {
  description = "Hosted zone ID containing the managed DNS records."
  value       = aws_route53_record.alb_a.zone_id
}

output "a_record_id" {
  description = "Terraform resource ID of the A alias record."
  value       = aws_route53_record.alb_a.id
}

output "aaaa_record_fqdn" {
  description = "Fully qualified DNS name of the AAAA alias record, or null when IPv6 record creation is disabled."
  value       = var.create_aaaa_record ? aws_route53_record.alb_aaaa[0].fqdn : null
}

output "aaaa_record_id" {
  description = "Terraform resource ID of the AAAA alias record, or null when IPv6 record creation is disabled."
  value       = var.create_aaaa_record ? aws_route53_record.alb_aaaa[0].id : null
}