
variable "name" {
  description = "Base name used to generate the Auto Scaling Group name."
  type        = string

  validation {
    condition = (
      length(var.name) >= 1 &&
      length(var.name) <= 251 &&
      can(regex("^[A-Za-z0-9][A-Za-z0-9-]*$", var.name)) &&
      can(regex("[A-Za-z0-9]$", var.name))
    )
    error_message = "The name must start and end with an alphanumeric character, contain only alphanumeric characters and hyphens, and be at most 251 characters long."
  }
}

variable "launch_template_id" {
  description = "ID of the existing EC2 Launch Template."
  type        = string

  validation {
    condition     = can(regex("^lt-[0-9a-fA-F]+$", var.launch_template_id))
    error_message = "launch_template_id must be a validly formatted EC2 Launch Template ID."
  }
}

variable "launch_template_version" {
  description = "Explicit numeric version of the existing Launch Template to deploy."
  type        = string

  validation {
    condition     = can(regex("^[1-9][0-9]*$", var.launch_template_version))
    error_message = "launch_template_version must be a positive integer expressed as a string. Use an explicit version for controlled deployments."
  }
}

variable "subnet_ids" {
  description = "Set of private subnet IDs across the intended Availability Zones."
  type        = set(string)

  validation {
    condition = (
      length(var.subnet_ids) >= 2 &&
      alltrue([
        for subnet_id in var.subnet_ids :
        can(regex("^subnet-[0-9a-fA-F]+$", subnet_id))
      ])
    )
    error_message = "Provide at least two validly formatted subnet IDs."
  }
}

variable "target_group_arns" {
  description = "Set of ALB target group ARNs associated with the Auto Scaling Group."
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for arn in var.target_group_arns :
      can(regex(
        "^arn:[^:]+:elasticloadbalancing:[^:]+:[0-9]{12}:targetgroup/.+/.+$",
        arn
      ))
    ])
    error_message = "Each entry must be a validly formatted ELB target group ARN."
  }
}

variable "min_size" {
  description = "Minimum number of instances maintained by the Auto Scaling Group."
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 0 && var.min_size == floor(var.min_size)
    error_message = "min_size must be a non-negative integer."
  }
}

variable "max_size" {
  description = "Maximum number of instances permitted in the Auto Scaling Group."
  type        = number
  default     = 6

  validation {
    condition     = var.max_size >= 1 && var.max_size == floor(var.max_size)
    error_message = "max_size must be a positive integer."
  }
}

variable "desired_capacity" {
  description = "Desired number of instances maintained by the Auto Scaling Group."
  type        = number
  default     = 2

  validation {
    condition     = var.desired_capacity >= 0 && var.desired_capacity == floor(var.desired_capacity)
    error_message = "desired_capacity must be a non-negative integer."
  }
}

variable "health_check_type" {
  description = "Health check type used by the Auto Scaling Group."
  type        = string
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "health_check_type must be either EC2 or ELB."
  }
}

variable "health_check_grace_period" {
  description = "Seconds to wait after instance launch before acting on failed health checks."
  type        = number
  default     = 300

  validation {
    condition     = var.health_check_grace_period >= 0 && var.health_check_grace_period == floor(var.health_check_grace_period)
    error_message = "health_check_grace_period must be a non-negative integer."
  }
}

variable "protect_from_scale_in" {
  description = "Whether to protect instances from scale-in termination."
  type        = bool
  default     = false
}

variable "termination_policies" {
  description = "Ordered list of termination policies for the Auto Scaling Group."
  type        = list(string)
  default     = ["Default"]

  validation {
    condition     = length(var.termination_policies) > 0
    error_message = "termination_policies must contain at least one policy."
  }
}

variable "enable_instance_refresh" {
  description = "Whether to enable rolling instance refresh configuration."
  type        = bool
  default     = true
}

variable "instance_refresh_min_healthy_percentage" {
  description = "Minimum percentage of instances that must remain healthy during refresh."
  type        = number
  default     = 100

  validation {
    condition = (
      var.instance_refresh_min_healthy_percentage >= 0 &&
      var.instance_refresh_min_healthy_percentage <= 100 &&
      var.instance_refresh_min_healthy_percentage == floor(var.instance_refresh_min_healthy_percentage)
    )
    error_message = "instance_refresh_min_healthy_percentage must be an integer between 0 and 100."
  }
}

variable "instance_refresh_max_healthy_percentage" {
  description = "Maximum percentage of instances permitted during refresh."
  type        = number
  default     = 200

  validation {
    condition = (
      var.instance_refresh_max_healthy_percentage >= 100 &&
      var.instance_refresh_max_healthy_percentage <= 200 &&
      var.instance_refresh_max_healthy_percentage == floor(var.instance_refresh_max_healthy_percentage)
    )
    error_message = "instance_refresh_max_healthy_percentage must be an integer between 100 and 200."
  }
}

variable "instance_refresh_warmup_seconds" {
  description = "Seconds to wait for a newly launched instance to warm up during instance refresh."
  type        = number
  default     = 300

  validation {
    condition     = var.instance_refresh_warmup_seconds >= 0 && var.instance_refresh_warmup_seconds == floor(var.instance_refresh_warmup_seconds)
    error_message = "instance_refresh_warmup_seconds must be a non-negative integer."
  }
}

variable "common_tags" {
  description = "Additional tags applied to the Auto Scaling Group and propagated to launched instances."
  type        = map(string)
  default     = {}
}
