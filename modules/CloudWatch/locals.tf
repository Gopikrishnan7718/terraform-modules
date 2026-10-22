locals {
  common_tags = merge(var.common_tags, {
    ManagedBy = "Terraform"
    Project   = var.name
  })

  alarms = {
    for key, alarm in var.alarms : key => merge(alarm, {
      resolved_alarm_actions = length(alarm.alarm_actions) > 0 ? alarm.alarm_actions : var.default_alarm_actions

      resolved_ok_actions = length(alarm.ok_actions) > 0 ? alarm.ok_actions : var.default_ok_actions

      resolved_insufficient_data_actions = length(alarm.insufficient_data_actions) > 0 ? alarm.insufficient_data_actions : var.default_insufficient_data_actions
    })
  }
}