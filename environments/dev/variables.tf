variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
}


variable "name" {
  description = "Base name used for naming infrastructure resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
}

variable "availability_zone_count" {
  description = "Number of Availability Zones to use."
  type        = number
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private application subnets."
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets."
  type        = list(string)
}

variable "enable_dns_support" {
  description = "Whether DNS resolution is enabled within the VPC."
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Whether DNS hostnames are enabled within the VPC."
  type        = bool
}

variable "enable_nat_gateway" {
  description = "Whether NAT Gateways should be created."
  type        = bool
}

variable "nat_gateway_strategy" {
  description = "NAT Gateway deployment strategy."
  type        = string
}

variable "enable_vpc_flow_logs" {
  description = "Whether VPC Flow Logs should be enabled."
  type        = bool
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs."
  type        = number
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
  description = "Common tags applied to infrastructure resources."
  type        = map(string)
}

# Security group variables

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

#S3 Bucket variables

variable "s3_bucket_name" {
  description = "Base name used to construct the S3 artifact bucket name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.s3_bucket_name))
    error_message = "s3_bucket_name must contain only lowercase letters, numbers, and hyphens, and must start and end with a letter or number."
  }

  validation {
    condition     = length(var.s3_bucket_name) >= 3 && length(var.s3_bucket_name) <= 30
    error_message = "s3_bucket_name must be between 3 and 30 characters."
  }
}

variable "s3_force_destroy" {
  description = "Whether Terraform may delete objects when destroying the S3 bucket."
  type        = bool
  default     = false
}

variable "s3_enable_versioning" {
  description = "Whether S3 bucket versioning should be enabled."
  type        = bool
  default     = true
}

variable "s3_noncurrent_version_expiration_days" {
  description = "Number of days after which noncurrent S3 object versions are permanently deleted."
  type        = number
  default     = 90

  validation {
    condition     = var.s3_noncurrent_version_expiration_days >= 1
    error_message = "s3_noncurrent_version_expiration_days must be at least 1."
  }
}

variable "s3_abort_incomplete_multipart_upload_days" {
  description = "Number of days after which incomplete S3 multipart uploads are aborted."
  type        = number
  default     = 7

  validation {
    condition     = var.s3_abort_incomplete_multipart_upload_days >= 1
    error_message = "s3_abort_incomplete_multipart_upload_days must be at least 1."
  }
}

#KMS Key variables

variable "kms_description" {
  description = "Description of the customer-managed KMS key."
  type        = string

  validation {
    condition = length(trimspace(var.kms_description)) > 0
    error_message = "kms_description must not be empty."
  }
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period in days before scheduled KMS key deletion takes effect."
  type        = number
  default     = 30

  validation {
    condition = var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    error_message = "kms_deletion_window_in_days must be between 7 and 30 days."
  }
}

variable "kms_enable_key_rotation" {
  description = "Whether automatic KMS key rotation is enabled."
  type        = bool
  default     = true
}