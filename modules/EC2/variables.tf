variable "name" {
  description = "Base name used for naming EC2 resources."
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

variable "ami_id" {
  description = "AMI ID used to launch the EC2 instance."
  type        = string

  validation {
    condition     = can(regex("^ami-[a-zA-Z0-9]+$", var.ami_id))
    error_message = "ami_id must be a valid-looking AWS AMI ID such as ami-0123456789abcdef0."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]+\\.[a-zA-Z0-9]+$", var.instance_type))
    error_message = "instance_type must use a valid-looking EC2 format such as t3.micro or m6i.large."
  }
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched."
  type        = string

  validation {
    condition     = can(regex("^subnet-[a-zA-Z0-9]+$", var.subnet_id))
    error_message = "subnet_id must be a valid-looking AWS subnet ID."
  }
}

variable "security_group_ids" {
  description = "Security group IDs attached to the EC2 instance."
  type        = set(string)

  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security group ID must be provided."
  }
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile attached to the EC2 instance."
  type        = string

  validation {
    condition     = length(trimspace(var.iam_instance_profile_name)) > 0
    error_message = "iam_instance_profile_name must not be empty."
  }
}

variable "common_tags" {
  description = "Common tags applied to EC2 resources."
  type        = map(string)
  default     = {}
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GiB."
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size >= 8
    error_message = "root_volume_size must be at least 8 GiB."
  }
}

variable "root_volume_type" {
  description = "EBS volume type for the root volume."
  type        = string
  default     = "gp3"

  validation {
    condition = contains(
      ["gp3", "io1", "io2", "sc1", "st1", "standard"],
      var.root_volume_type
    )
    error_message = "root_volume_type must be one of gp3, io1, io2, sc1, st1, or standard."
  }
}

variable "root_volume_encrypted" {
  description = "Whether the root EBS volume is encrypted."
  type        = bool
  default     = true
}

variable "root_volume_kms_key_id" {
  description = "Optional KMS key ID or ARN used to encrypt the root EBS volume."
  type        = string
  default     = null
}

variable "metadata_http_tokens" {
  description = "Whether EC2 Instance Metadata Service requires session tokens."
  type        = string
  default     = "required"

  validation {
    condition     = contains(["required", "optional"], var.metadata_http_tokens)
    error_message = "metadata_http_tokens must be either required or optional."
  }
}

variable "metadata_http_endpoint" {
  description = "Whether the EC2 Instance Metadata Service HTTP endpoint is enabled."
  type        = string
  default     = "enabled"

  validation {
    condition     = contains(["enabled", "disabled"], var.metadata_http_endpoint)
    error_message = "metadata_http_endpoint must be either enabled or disabled."
  }
}

variable "enable_detailed_monitoring" {
  description = "Whether detailed EC2 monitoring is enabled."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "Optional user data script executed during instance initialization."
  type        = string
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "Behavior when the operating system initiates shutdown."
  type        = string
  default     = "stop"

  validation {
    condition = contains(
      ["stop", "terminate"],
      var.instance_initiated_shutdown_behavior
    )
    error_message = "instance_initiated_shutdown_behavior must be either stop or terminate."
  }
}