# CloudWatch Terraform Module

## Purpose

This reusable module creates Amazon CloudWatch log groups and metric alarms. Project-specific settings are supplied through input variables rather than hardcoded into the module.

## Features

- Multiple log groups with configurable retention periods.
- Optional KMS encryption using an existing key.
- Configurable metric alarms, thresholds, dimensions, and evaluation periods.
- Explicit missing-data policies.
- Configurable alarm, OK, and insufficient-data notification actions.
- Consistent resource tags and useful outputs.
- No automatic creation of IAM roles, SNS topics, log agents, or application-specific metrics.

## Directory Structure

```text
modules/CloudWatch/
├── versions.tf
├── variables.tf
├── locals.tf
├── log_groups.tf
├── alarms.tf
├── outputs.tf
└── README.md
```

## Example Usage

```hcl
module "cloudwatch" {
  source = "../../modules/CloudWatch"

  name = "gis-dev"

  common_tags = {
    Environment = "dev"
    Owner       = "platform-team"
  }

  log_groups = {
    application = {
      name              = "/company/gis/dev/application"
      retention_in_days = 30
    }

    platform = {
      name              = "/company/gis/dev/platform"
      retention_in_days = 90
      kms_key_id        = var.cloudwatch_kms_key_arn
    }
  }

  default_alarm_actions = [var.alerts_sns_topic_arn]

  alarms = {
    ec2_cpu_high = {
      alarm_name          = "gis-dev-ec2-cpu-high"
      alarm_description   = "Investigate sustained high CPU utilization on the selected EC2 instance."
      namespace           = "AWS/EC2"
      metric_name         = "CPUUtilization"
      dimensions          = { InstanceId = var.monitored_instance_id }
      statistic           = "Average"
      period              = 300
      evaluation_periods  = 3
      datapoints_to_alarm = 2
      threshold           = 80
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "missing"
    }
  }
}
```

This example assumes that the KMS key, SNS topic, and EC2 instance already exist and that their values are supplied by the calling environment.

## Input Variables

| Variable | Purpose |
|---|---|
| `name` | Project or workload identifier |
| `common_tags` | Common resource tags |
| `log_groups` | Log group names, retention, optional KMS key, and destruction behavior |
| `alarms` | Metric definitions, dimensions, thresholds, and evaluation settings |
| `default_alarm_actions` | Default alarm action ARNs |
| `default_ok_actions` | Default OK action ARNs |
| `default_insufficient_data_actions` | Default insufficient-data action ARNs |

## Outputs

- `log_group_names`
- `log_group_arns`
- `alarm_names`
- `alarm_arns`

## Operational Considerations

1. **KMS permissions:** The selected KMS key policy and permissions must allow CloudWatch Logs to use the key. This module does not create or modify KMS key policies.
2. **Notifications:** Action targets must already exist and support the configured CloudWatch alarm action. This module does not create SNS topics or subscriptions.
3. **Metrics:** Alarm dimensions must match the actual metric dimensions published by the monitored AWS service or application.
4. **Retention:** Choose retention according to operational, compliance, and cost requirements.
5. **Missing data:** Choose a missing-data policy appropriate to the metric. Missing telemetry does not always mean the monitored system is healthy or unhealthy.
6. **Destruction:** Setting `skip_destroy = true` preserves a log group when Terraform attempts to destroy it. The resource may require manual import or reconciliation later.
7. **State management:** Use separate state and environment configuration for independently managed projects and environments.
8. **Validation:** `terraform validate` checks configuration structure; it does not prove that live AWS permissions, metrics, KMS access, or notification delivery work.

## Formatting and Validation

From the repository root:

```bash
terraform fmt -recursive modules/CloudWatch
terraform fmt -check -recursive modules/CloudWatch
```

Then validate the module:

```bash
cd modules/CloudWatch
terraform init
terraform validate
```

After module validation passes, integrate it into the appropriate environment and review the resulting Terraform plan before applying changes.