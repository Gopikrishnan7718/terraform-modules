variable "name" {
  description = "Short project or workload name used in resource naming and tags."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9_-]{1,39}$", var.name))
    error_message = "name must be 2-40 characters and contain only letters, numbers, underscores, or hyphens."
  }
}

variable "common_tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "log_groups" {
  description = "Log groups to create, keyed by stable Terraform identifiers."
  type = map(object({
    name              = string
    retention_in_days = number
    kms_key_id        = optional(string)
    skip_destroy      = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for group in values(var.log_groups) :
      length(trimspace(group.name)) > 0 &&
      group.retention_in_days >= 1 &&
      floor(group.retention_in_days) == group.retention_in_days &&
      contains([
        1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545,
        731, 1827, 2192, 2557, 2922, 3288, 3653
      ], group.retention_in_days)
    ])
    error_message = "Each log group needs a non-empty name and a supported integer CloudWatch retention period."
  }

  validation {
    condition = length(distinct([
      for group in values(var.log_groups) : group.name
    ])) == length(var.log_groups)
    error_message = "Each log group must have a unique CloudWatch log group name."
  }
}

variable "alarms" {
  description = "Metric alarms to create, keyed by stable Terraform identifiers."
  type = map(object({
    alarm_name                = string
    alarm_description         = string
    namespace                 = string
    metric_name               = string
    dimensions                = optional(map(string), {})
    statistic                 = optional(string, "Average")
    period                    = number
    evaluation_periods        = number
    datapoints_to_alarm       = optional(number)
    threshold                 = number
    comparison_operator       = string
    treat_missing_data        = optional(string, "missing")
    actions_enabled           = optional(bool, true)
    alarm_actions             = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for alarm in values(var.alarms) :
      length(trimspace(alarm.alarm_name)) > 0 &&
      length(trimspace(alarm.namespace)) > 0 &&
      length(trimspace(alarm.metric_name)) > 0 &&
      length(alarm.alarm_description) <= 1024 &&
      floor(alarm.period) == alarm.period &&
      (contains([10, 20, 30], alarm.period) || (alarm.period >= 60 && alarm.period % 60 == 0)) &&
      alarm.evaluation_periods >= 1 &&
      floor(alarm.evaluation_periods) == alarm.evaluation_periods &&
      (alarm.datapoints_to_alarm == null || (
        alarm.datapoints_to_alarm >= 1 &&
        floor(alarm.datapoints_to_alarm) == alarm.datapoints_to_alarm &&
        alarm.datapoints_to_alarm <= alarm.evaluation_periods
      )) &&
      contains([
        "GreaterThanOrEqualToThreshold",
        "GreaterThanThreshold",
        "LessThanOrEqualToThreshold",
        "LessThanThreshold"
      ], alarm.comparison_operator) &&
      contains(["missing", "ignore", "breaching", "notBreaching"], alarm.treat_missing_data) &&
      contains(["SampleCount", "Average", "Sum", "Minimum", "Maximum"], alarm.statistic)
    ])
    error_message = "Alarm configuration contains invalid names, period/evaluation values, comparison operator, statistic, or missing-data policy."
  }

  validation {
    condition = length(distinct([
      for alarm in values(var.alarms) : alarm.alarm_name
    ])) == length(var.alarms)
    error_message = "Each CloudWatch alarm must have a unique alarm_name."
  }
}

variable "default_alarm_actions" {
  description = "Default action ARNs used when an alarm has no per-alarm alarm_actions."
  type        = list(string)
  default     = []
}

variable "default_ok_actions" {
  description = "Default action ARNs used when an alarm has no per-alarm ok_actions."
  type        = list(string)
  default     = []
}

variable "default_insufficient_data_actions" {
  description = "Default action ARNs used when an alarm has no per-alarm insufficient_data_actions."
  type        = list(string)
  default     = []
}