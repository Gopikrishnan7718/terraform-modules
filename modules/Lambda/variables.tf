variable "function_name" {
  description = "Name of the Lambda function."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]{1,64}$", var.function_name))
    error_message = "function_name must contain 1-64 letters, numbers, underscores, or hyphens."
  }
}

variable "description" {
  description = "Description of the Lambda function."
  type        = string
  default     = "Managed by Terraform"
}

variable "runtime" {
  description = "AWS Lambda runtime identifier."
  type        = string

  validation {
    condition     = length(trimspace(var.runtime)) > 0
    error_message = "runtime must not be empty."
  }
}

variable "handler" {
  description = "Function handler, such as app.handler."
  type        = string

  validation {
    condition     = length(trimspace(var.handler)) > 0
    error_message = "handler must not be empty."
  }
}

variable "architecture" {
  description = "Instruction-set architecture used by the Lambda function."
  type        = string
  default     = "arm64"

  validation {
    condition     = contains(["arm64", "x86_64"], var.architecture)
    error_message = "architecture must be arm64 or x86_64."
  }
}

variable "package_type" {
  description = "Lambda deployment package type. This module supports ZIP packages."
  type        = string
  default     = "Zip"

  validation {
    condition     = var.package_type == "Zip"
    error_message = "This module supports ZIP deployment packages only."
  }
}

variable "filename" {
  description = "Path to a local ZIP deployment package."
  type        = string
  default     = null

  validation {
    condition = (
      var.filename == null ||
      length(trimspace(var.filename)) > 0
    )
    error_message = "filename must be null or a non-empty path."
  }
}

variable "source_code_hash" {
  description = "Optional Base64-encoded SHA-256 hash of the local deployment package."
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the deployment package."
  type        = string
  default     = null

  validation {
    condition = (
      var.s3_bucket == null ||
      length(trimspace(var.s3_bucket)) > 0
    )
    error_message = "s3_bucket must be null or a non-empty bucket name."
  }
}

variable "s3_key" {
  description = "S3 object key for the deployment package."
  type        = string
  default     = null

  validation {
    condition = (
      var.s3_key == null ||
      length(trimspace(var.s3_key)) > 0
    )
    error_message = "s3_key must be null or a non-empty object key."
  }
}

variable "s3_object_version" {
  description = "Optional version ID of the S3 deployment package."
  type        = string
  default     = null
}

variable "memory_size" {
  description = "Lambda memory allocation in MB."
  type        = number
  default     = 256

  validation {
    condition = (
      var.memory_size >= 128 &&
      var.memory_size <= 10240 &&
      floor(var.memory_size) == var.memory_size
    )
    error_message = "memory_size must be a whole number between 128 and 10240 MB."
  }
}

variable "timeout" {
  description = "Maximum execution time in seconds."
  type        = number
  default     = 30

  validation {
    condition = (
      var.timeout >= 1 &&
      var.timeout <= 900 &&
      floor(var.timeout) == var.timeout
    )
    error_message = "timeout must be a whole number between 1 and 900 seconds."
  }
}

variable "publish" {
  description = "Whether to publish a new Lambda function version."
  type        = bool
  default     = true
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrency limit. Use -1 for unreserved concurrency or null for provider default."
  type        = number
  default     = null

  validation {
    condition = (
      var.reserved_concurrent_executions == null ||
      var.reserved_concurrent_executions == -1 ||
      (
        var.reserved_concurrent_executions >= 0 &&
        floor(var.reserved_concurrent_executions) == var.reserved_concurrent_executions
      )
    )
    error_message = "reserved_concurrent_executions must be null, -1, or a non-negative whole number."
  }
}

variable "environment_variables" {
  description = "Non-secret environment variables for the function."
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "Optional customer-managed KMS key ARN for Lambda environment-variable encryption."
  type        = string
  default     = null
}

variable "enable_vpc_config" {
  description = "Whether to attach the Lambda function to a VPC."
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Private subnet IDs for VPC-enabled Lambda functions."
  type        = list(string)
  default     = []

  validation {
    condition     = length(distinct(var.subnet_ids)) == length(var.subnet_ids)
    error_message = "subnet_ids must not contain duplicates."
  }

  validation {
    condition = alltrue([
      for id in var.subnet_ids : length(trimspace(id)) > 0
    ])
    error_message = "subnet_ids must not contain empty values."
  }
}

variable "security_group_ids" {
  description = "Security group IDs for VPC-enabled Lambda functions."
  type        = list(string)
  default     = []

  validation {
    condition     = length(distinct(var.security_group_ids)) == length(var.security_group_ids)
    error_message = "security_group_ids must not contain duplicates."
  }

  validation {
    condition = alltrue([
      for id in var.security_group_ids : length(trimspace(id)) > 0
    ])
    error_message = "security_group_ids must not contain empty values."
  }
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention period in days."
  type        = number
  default     = 30

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180,
      365, 400, 545, 731, 1096, 1827, 2192, 2557,
      2922, 3288, 3653
    ], var.log_retention_in_days)
    error_message = "log_retention_in_days must be a supported CloudWatch Logs retention value."
  }
}

variable "log_group_kms_key_id" {
  description = "Optional KMS key ARN for CloudWatch log group encryption."
  type        = string
  default     = null
}

variable "enable_xray_tracing" {
  description = "Whether to enable active AWS X-Ray tracing."
  type        = bool
  default     = false
}

variable "additional_policy_arns" {
  description = "Additional managed IAM policy ARNs attached to the Lambda execution role."
  type        = set(string)
  default     = []
}

variable "additional_policy_json" {
  description = "Optional additional least-privilege IAM policy document in JSON format."
  type        = string
  default     = null

  validation {
    condition = (
      var.additional_policy_json == null ||
      can(jsondecode(var.additional_policy_json))
    )
    error_message = "additional_policy_json must be valid JSON when provided."
  }
}

variable "role_name" {
  description = "Optional custom IAM execution role name when the module creates the role."
  type        = string
  default     = null

  validation {
    condition = (
      var.role_name == null ||
      (
        length(trimspace(var.role_name)) > 0 &&
        can(regex("^[A-Za-z0-9+=,.@_-]{1,64}$", var.role_name))
      )
    )
    error_message = "role_name must be null or contain 1-64 valid IAM role-name characters."
  }
}

variable "execution_role_arn" {
  description = "ARN of an existing Lambda execution role. When provided, the module reuses it instead of creating a role."
  type        = string
  default     = null

  validation {
    condition = (
      var.execution_role_arn == null ||
      can(regex(
        "^arn:[^:]+:iam::[0-9]{12}:role/.+$",
        var.execution_role_arn
      ))
    )
    error_message = "execution_role_arn must be null or a valid IAM role ARN."
  }
}

variable "common_tags" {
  description = "Tags applied to taggable Lambda resources."
  type        = map(string)
  default     = {}
}

variable "extra_environment_tags" {
  description = "Additional tags applied to the Lambda function and related resources."
  type        = map(string)
  default     = {}
}

variable "logging_enabled" {
  description = "Whether to create and manage the function's CloudWatch log group."
  type        = bool
  default     = true
}