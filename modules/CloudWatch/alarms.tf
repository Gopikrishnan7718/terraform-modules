resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = local.alarms

  alarm_name          = each.value.alarm_name
  alarm_description   = each.value.alarm_description
  namespace           = each.value.namespace
  metric_name         = each.value.metric_name
  dimensions          = each.value.dimensions
  statistic           = each.value.statistic
  period              = each.value.period
  evaluation_periods  = each.value.evaluation_periods
  datapoints_to_alarm = each.value.datapoints_to_alarm
  threshold           = each.value.threshold
  comparison_operator = each.value.comparison_operator

  treat_missing_data = each.value.treat_missing_data
  actions_enabled    = each.value.actions_enabled

  alarm_actions             = each.value.resolved_alarm_actions
  ok_actions                = each.value.resolved_ok_actions
  insufficient_data_actions = each.value.resolved_insufficient_data_actions

  tags = merge(local.common_tags, {
    Name = each.value.alarm_name
    Type = "metric-alarm"
  })
}