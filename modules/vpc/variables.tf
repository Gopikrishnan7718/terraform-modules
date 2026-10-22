variable "name" {
  description = "Base name used for naming VPC resources."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]*$", var.name))
    error_message = "The name must start with an alphanumeric character and may contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The vpc_cidr value must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr value must represent a valid IPv4 network."
  }
}

variable "availability_zone_count" {
  description = "Number of Availability Zones to use for the VPC."
  type        = number
  default     = 3

  validation {
    condition     = var.availability_zone_count >= 2
    error_message = "At least two Availability Zones are required for high availability."
  }

  validation {
    condition     = var.availability_zone_count <= 6
    error_message = "availability_zone_count must not exceed 6."
  }
}
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets. One CIDR must be provided for each Availability Zone."
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))
    ])
    error_message = "Every public subnet CIDR must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = length(var.public_subnet_cidrs) == var.availability_zone_count
    error_message = "The number of public subnet CIDRs must match availability_zone_count."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private application subnets. One CIDR must be provided for each Availability Zone."
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))
    ])
    error_message = "Every private subnet CIDR must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = length(var.private_subnet_cidrs) == var.availability_zone_count
    error_message = "The number of private subnet CIDRs must match availability_zone_count."
  }
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for private database subnets. One CIDR must be provided for each Availability Zone."
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.database_subnet_cidrs : can(cidrnetmask(cidr))
    ])
    error_message = "Every database subnet CIDR must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = length(var.database_subnet_cidrs) == var.availability_zone_count
    error_message = "The number of database subnet CIDRs must match availability_zone_count."
  }
}

variable "enable_dns_support" {
  description = "Whether DNS resolution is enabled within the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether DNS hostnames are enabled within the VPC."
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Whether NAT Gateways should be created for private subnet outbound connectivity."
  type        = bool
  default     = true
}

variable "nat_gateway_strategy" {
  description = "NAT Gateway deployment strategy. Use 'single' for one NAT Gateway or 'one_per_az' for one NAT Gateway per Availability Zone."
  type        = string
  default     = "one_per_az"

  validation {
    condition     = contains(["single", "one_per_az"], var.nat_gateway_strategy)
    error_message = "nat_gateway_strategy must be either 'single' or 'one_per_az'."
  }
}

variable "enable_vpc_flow_logs" {
  description = "Whether VPC Flow Logs should be enabled."
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch Logs."
  type        = number
  default     = 30

  validation {
    condition     = var.flow_logs_retention_days >= 1
    error_message = "flow_logs_retention_days must be at least 1."
  }
}

variable "flow_log_max_aggregation_interval" {
  description = "Maximum interval in seconds for aggregating VPC Flow Log records."
  type        = number
  default     = 60

  validation {
    condition     = contains([60, 600], var.flow_log_max_aggregation_interval)
    error_message = "flow_log_max_aggregation_interval must be either 60 or 600 seconds."
  }
}


variable "common_tags" {
  description = "Common tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}