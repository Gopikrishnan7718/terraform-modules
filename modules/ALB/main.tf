
resource "aws_lb" "this" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"

  subnets         = sort(tolist(var.subnet_ids))
  security_groups = sort(tolist(var.security_group_ids))

  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = var.access_logs_enabled ? [1] : []

    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = local.common_tags

  lifecycle {
    precondition {
      condition = (
        !var.access_logs_enabled ||
        (
          var.access_logs_bucket != null &&
          length(trimspace(var.access_logs_bucket)) > 0
        )
      )
      error_message = "access_logs_bucket must be provided when ALB access logging is enabled."
    }

    precondition {
      condition = (
        !var.enable_https ||
        (
          var.certificate_arn != null &&
          length(trimspace(var.certificate_arn)) > 0
        )
      )
      error_message = "certificate_arn must be provided when HTTPS is enabled."
    }
  }
}

resource "aws_lb_target_group" "this" {
  name        = local.target_group_name
  port        = var.target_port
  protocol    = var.target_protocol
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    protocol            = var.target_protocol
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = "200-399"
  }

  tags = local.common_tags

  lifecycle {
    precondition {
      condition     = var.health_check_timeout < var.health_check_interval
      error_message = "health_check_timeout must be less than health_check_interval."
    }
  }
}
