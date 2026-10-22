variable "name" {
  description = "Base name used for naming security group resources."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]*$", var.name))
    error_message = "The name must start with an alphanumeric character and may contain only alphanumeric characters, hyphens, and underscores."
  }

  validation {
    condition     = length(var.name) <= 200
    error_message = "The name must not exceed 200 characters."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the security groups will be created."
  type        = string

  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "alb_ingress_cidr_blocks" {
  description = "IPv4 CIDR blocks allowed to access the Application Load Balancer."
  type        = set(string)

  validation {
    condition = alltrue([
      for cidr in var.alb_ingress_cidr_blocks :
      can(cidrnetmask(cidr))
    ])

    error_message = "Every value in alb_ingress_cidr_blocks must be a valid IPv4 CIDR block."
  }
}

variable "alb_http_port" {
  description = "HTTP port exposed by the Application Load Balancer."
  type        = number
  default     = 80

  validation {
    condition     = var.alb_http_port >= 1 && var.alb_http_port <= 65535
    error_message = "alb_http_port must be between 1 and 65535."
  }
}

variable "alb_https_port" {
  description = "HTTPS port exposed by the Application Load Balancer."
  type        = number
  default     = 443

  validation {
    condition     = var.alb_https_port >= 1 && var.alb_https_port <= 65535
    error_message = "alb_https_port must be between 1 and 65535."
  }
}

variable "application_port" {
  description = "TCP port on which application workloads receive traffic from the Application Load Balancer."
  type        = number

  validation {
    condition     = var.application_port >= 1 && var.application_port <= 65535
    error_message = "application_port must be between 1 and 65535."
  }
}

variable "database_port" {
  description = "TCP port on which the database accepts connections from application workloads."
  type        = number
  default     = 5432

  validation {
    condition     = var.database_port >= 1 && var.database_port <= 65535
    error_message = "database_port must be between 1 and 65535."
  }
}

variable "application_https_port" {
  description = "HTTPS port used by application workloads for outbound external connections."
  type        = number
  default     = 443

  validation {
    condition     = var.application_https_port >= 1 && var.application_https_port <= 65535
    error_message = "application_https_port must be between 1 and 65535."
  }
}

variable "common_tags" {
  description = "Common tags applied to all security group resources."
  type        = map(string)
  default     = {}
}

variable "application_egress_cidr_blocks" {
  description = "IPv4 CIDR blocks that application workloads are allowed to access for outbound HTTPS connections."
  type        = set(string)

  validation {
    condition = alltrue([
      for cidr in var.application_egress_cidr_blocks :
      can(cidrnetmask(cidr))
    ])

    error_message = "Every value in application_egress_cidr_blocks must be a valid IPv4 CIDR block."
  }
}