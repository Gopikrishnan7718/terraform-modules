variable "name" {
  description = "Base name used for the Launch Template."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_.]*$", var.name))
    error_message = "The name must start with an alphanumeric character and contain only alphanumeric characters, hyphens, underscores, or periods."
  }

  validation {
    condition     = length(var.name) <= 128
    error_message = "The name must not exceed 128 characters."
  }
}

variable "ami_id" {
  description = "Approved AMI ID used to launch EC2 instances."
  type        = string

  validation {
    condition     = can(regex("^ami-[a-zA-Z0-9]+$", var.ami_id))
    error_message = "ami_id must be a valid-looking AWS AMI ID."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]+\\.[a-zA-Z0-9]+$", var.instance_type))
    error_message = "Provide an instance type such as t3.medium or m6i.large."
  }
}

variable "security_group_ids" {
  description = "Security group IDs attached to instances launched from this template."
  type        = set(string)

  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security group ID must be provided."
  }
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile attached to launched instances."
  type        = string

  validation {
    condition     = length(trimspace(var.iam_instance_profile_name)) > 0
    error_message = "The IAM instance profile name must not be empty."
  }
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size == floor(var.root_volume_size)
    error_message = "root_volume_size must be a whole number of at least 8 GiB."
  }
}

variable "root_volume_type" {
  description = "Root EBS volume type."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp3", "io1", "io2", "sc1", "st1", "standard"], var.root_volume_type)
    error_message = "Unsupported root EBS volume type."
  }
}

variable "root_volume_encrypted" {
  description = "Whether the root EBS volume is encrypted."
  type        = bool
  default     = true
}

variable "root_volume_kms_key_id" {
  description = "Optional customer-managed KMS key ID or ARN for root volume encryption."
  type        = string
  default     = null
  nullable    = true
}

variable "metadata_http_tokens" {
  description = "IMDS token requirement."
  type        = string
  default     = "required"

  validation {
    condition     = contains(["required", "optional"], var.metadata_http_tokens)
    error_message = "metadata_http_tokens must be required or optional."
  }
}

variable "metadata_http_endpoint" {
  description = "Whether the instance metadata HTTP endpoint is enabled."
  type        = string
  default     = "enabled"

  validation {
    condition = contains(
      ["enabled", "disabled"],
      var.metadata_http_endpoint
    )

    error_message = "metadata_http_endpoint must be enabled or disabled."
  }
}

variable "root_device_name" {
  description = "Root device name for the selected AMI."
  type        = string

  validation {
    condition     = length(trimspace(var.root_device_name)) > 0
    error_message = "root_device_name must not be empty."
  }
}

variable "user_data" {
  description = "Optional user data script for instance initialization."
  type        = string
  default     = null
  nullable    = true
}

variable "enable_detailed_monitoring" {
  description = "Whether detailed EC2 monitoring is enabled."
  type        = bool
  default     = true
}

variable "update_default_version" {
  description = "Whether a new Launch Template version becomes the default version."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common organizational tags applied to the Launch Template."
  type        = map(string)
  default     = {}
}