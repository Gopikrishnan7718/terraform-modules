resource "aws_route53_record" "alb_a" {
  zone_id = var.hosted_zone_id
  name    = local.record_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_canonical_hosted_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

resource "aws_route53_record" "alb_aaaa" {
  count = var.create_aaaa_record ? 1 : 0

  zone_id = var.hosted_zone_id
  name    = local.record_name
  type    = "AAAA"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_canonical_hosted_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}