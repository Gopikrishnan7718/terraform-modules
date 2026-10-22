variable "name" {
  description = "Base name used to generate ALB and target group names."
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 28
    error_message = "The name must contain between 1 and 28 characters so generated ALB and target group names remain within AWS naming limits."
  }

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]*$", var.name))
    error_message = "The name must start with an alphanumeric character and contain only alphanumeric characters and hyphens."
  }
}

variable "vpc_id" {
  description = "VPC ID where the ALB target group will be created."
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-zA-Z0-9]+$", var.vpc_id))
    error_message = "vpc_id must be a validly formatted AWS VPC ID."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs used by the ALB across multiple Availability Zones."
  type        = set(string)

  validation {
    condition = (
      length(var.subnet_ids) >= 2 &&
      alltrue([
        for subnet_id in var.subnet_ids :
        can(regex("^subnet-[a-zA-Z0-9]+$", subnet_id))
      ])
    )
    error_message = "Provide at least two validly formatted subnet IDs."
  }
}

variable "security_group_ids" {
  description = "Security group IDs attached to the ALB."
  type        = set(string)

  validation {
    condition = (
      length(var.security_group_ids) > 0 &&
      alltrue([
        for security_group_id in var.security_group_ids :
        can(regex("^sg-[a-zA-Z0-9]+$", security_group_id))
      ])
    )
    error_message = "Provide at least one validly formatted security group ID."
  }
}

variable "target_port" {
  description = "Port on which application targets receive traffic."
  type        = number
  default     = 3000

  validation {
    condition = (
      var.target_port >= 1 &&
      var.target_port <= 65535 &&
      var.target_port == floor(var.target_port)
    )
    error_message = "target_port must be a whole number between 1 and 65535."
  }
}

variable "target_protocol" {
  description = "Protocol used to communicate with targets."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_protocol)
    error_message = "target_protocol must be HTTP or HTTPS."
  }
}

variable "health_check_path" {
  description = "HTTP path used for target health checks."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "health_check_path must start with /."
  }
}

variable "health_check_interval" {
  description = "Interval between target health checks in seconds."
  type        = number
  default     = 30

  validation {
    condition = (
      var.health_check_interval >= 5 &&
      var.health_check_interval <= 300 &&
      var.health_check_interval == floor(var.health_check_interval)
    )
    error_message = "health_check_interval must be a whole number between 5 and 300 seconds."
  }
}

variable "health_check_timeout" {
  description = "Timeout for each target health check in seconds."
  type        = number
  default     = 5

  validation {
    condition = (
      var.health_check_timeout >= 2 &&
      var.health_check_timeout <= 120 &&
      var.health_check_timeout == floor(var.health_check_timeout)
    )
    error_message = "health_check_timeout must be a whole number between 2 and 120 seconds."
  }
}

variable "healthy_threshold" {
  description = "Consecutive successful checks required to mark a target healthy."
  type        = number
  default     = 3

  validation {
    condition = (
      var.healthy_threshold >= 2 &&
      var.healthy_threshold <= 10 &&
      var.healthy_threshold == floor(var.healthy_threshold)
    )
    error_message = "healthy_threshold must be a whole number between 2 and 10."
  }
}

variable "unhealthy_threshold" {
  description = "Consecutive failed checks required to mark a target unhealthy."
  type        = number
  default     = 3

  validation {
    condition = (
      var.unhealthy_threshold >= 2 &&
      var.unhealthy_threshold <= 10 &&
      var.unhealthy_threshold == floor(var.unhealthy_threshold)
    )
    error_message = "unhealthy_threshold must be a whole number between 2 and 10."
  }
}

variable "enable_https" {
  description = "Whether the HTTPS listener is enabled."
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener."
  type        = string
  default     = null
  nullable    = true
}

variable "ssl_policy" {
  description = "TLS security policy for the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "enable_deletion_protection" {
  description = "Whether deletion protection is enabled for the ALB."
  type        = bool
  default     = true
}

variable "access_logs_enabled" {
  description = "Whether ALB access logging is enabled."
  type        = bool
  default     = true
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs."
  type        = string
  default     = null
  nullable    = true
}

variable "access_logs_prefix" {
  description = "Optional prefix for ALB access logs."
  type        = string
  default     = null
  nullable    = true
}

variable "common_tags" {
  description = "Common organizational tags applied to ALB resources."
  type        = map(string)
  default     = {}
}