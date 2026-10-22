variable "name" {
  description = "Base name used for naming IAM resources."
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

variable "common_tags" {
  description = "Common tags applied to IAM resources."
  type        = map(string)
  default     = {}
}

variable "artifact_bucket_arn" {
  description = "ARN of the S3 bucket used for application artifacts."
  type        = string

  validation {
    condition     = can(regex("^arn:[^:]+:s3:::[^/]+$", var.artifact_bucket_arn))
    error_message = "artifact_bucket_arn must be a valid S3 bucket ARN."
  }
}