variable "hosted_zone_id" {
  description = "ID of the existing public Route 53 hosted zone."
  type        = string

  validation {
    condition     = can(regex("^Z[A-Z0-9]+$", var.hosted_zone_id))
    error_message = "hosted_zone_id must be a validly formatted Route 53 hosted zone ID."
  }
}

variable "record_name" {
  description = "DNS name to associate with the ALB, such as app.example.com."
  type        = string

  validation {
    condition = (
      length(trimsuffix(var.record_name, ".")) >= 1 &&
      length(trimsuffix(var.record_name, ".")) <= 253 &&
      can(regex(
        "^\\*?([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?\\.)*[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$",
        trimsuffix(var.record_name, ".")
      ))
    )
    error_message = "record_name must be a valid DNS name, optionally ending with a trailing dot."
  }
}

variable "alb_dns_name" {
  description = "DNS name of the existing Application Load Balancer."
  type        = string

  validation {
    condition = (
      length(trimsuffix(var.alb_dns_name, ".")) > 0 &&
      !strcontains(var.alb_dns_name, "://") &&
      !strcontains(var.alb_dns_name, "/")
    )
    error_message = "alb_dns_name must be a DNS name, not a URL."
  }
}

variable "alb_canonical_hosted_zone_id" {
  description = "Canonical Route 53 hosted zone ID associated with the ALB."
  type        = string

  validation {
    condition     = can(regex("^Z[A-Z0-9]+$", var.alb_canonical_hosted_zone_id))
    error_message = "alb_canonical_hosted_zone_id must be a validly formatted hosted zone ID."
  }
}

variable "create_aaaa_record" {
  description = "Whether to create an IPv6 AAAA alias record for the ALB."
  type        = bool
  default     = false
}

variable "evaluate_target_health" {
  description = "Whether Route 53 evaluates the ALB target health for the alias record."
  type        = bool
  default     = true
}