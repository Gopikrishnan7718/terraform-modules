variable "name" {
  description = "Base name used to construct the S3 bucket name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.name))
    error_message = "The name must contain only lowercase letters, numbers, and hyphens, and must start and end with a letter or number."
  }

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 30
    error_message = "The name must be between 3 and 30 characters."
  }
}

variable "force_destroy" {
  description = "Whether to allow Terraform to delete the bucket when it contains objects."
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Whether S3 bucket versioning should be enabled."
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days after which noncurrent object versions are permanently deleted."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days >= 1
    error_message = "noncurrent_version_expiration_days must be at least 1."
  }
}

variable "abort_incomplete_multipart_upload_days" {
  description = "Number of days after which incomplete multipart uploads are aborted."
  type        = number
  default     = 7

  validation {
    condition     = var.abort_incomplete_multipart_upload_days >= 1
    error_message = "abort_incomplete_multipart_upload_days must be at least 1."
  }
}

variable "common_tags" {
  description = "Common tags applied to the S3 bucket."
  type        = map(string)
  default     = {}
}