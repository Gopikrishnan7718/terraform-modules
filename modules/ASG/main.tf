
resource "aws_autoscaling_group" "this" {
  name = local.autoscaling_group_name

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = sort(tolist(var.subnet_ids))
  target_group_arns   = sort(tolist(var.target_group_arns))

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  protect_from_scale_in = var.protect_from_scale_in
  termination_policies  = var.termination_policies

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  dynamic "instance_refresh" {
    for_each = var.enable_instance_refresh ? [1] : []

    content {
      strategy = "Rolling"

      preferences {
        min_healthy_percentage = var.instance_refresh_min_healthy_percentage
        max_healthy_percentage = var.instance_refresh_max_healthy_percentage
        instance_warmup        = var.instance_refresh_warmup_seconds
        skip_matching          = true
        auto_rollback          = true
      }
    }
  }

  dynamic "tag" {
    for_each = local.common_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    precondition {
      condition = (
        var.min_size <= var.desired_capacity &&
        var.desired_capacity <= var.max_size
      )
      error_message = "Capacity must satisfy min_size <= desired_capacity <= max_size."
    }

    precondition {
      condition = (
        var.instance_refresh_min_healthy_percentage <=
        var.instance_refresh_max_healthy_percentage &&
        (
          var.instance_refresh_max_healthy_percentage -
          var.instance_refresh_min_healthy_percentage
        ) <= 100
      )
      error_message = "The maximum healthy percentage must be greater than or equal to the minimum, and their difference must not exceed 100 percentage points."
    }

    precondition {
      condition = (
        var.health_check_type != "ELB" ||
        length(var.target_group_arns) > 0
      )
      error_message = "At least one target group ARN must be provided when health_check_type is ELB."
    }
  }
}
