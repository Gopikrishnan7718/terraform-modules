variable "name" {
  description = "Base name used for naming the KMS key and alias."
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

variable "description" {
  description = "Description of the KMS customer-managed key."
  type        = string

  validation {
    condition     = length(trimspace(var.description)) > 0
    error_message = "The description must not be empty."
  }
}

variable "deletion_window_in_days" {
  description = "Waiting period in days before a scheduled KMS key deletion takes effect."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30 days."
  }
}

variable "enable_key_rotation" {
  description = "Whether automatic annual rotation is enabled for the KMS key."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags applied to KMS resources."
  type        = map(string)
  default     = {}
}