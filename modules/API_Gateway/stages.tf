
resource "aws_apigatewayv2_deployment" "this" {
  count = var.auto_deploy ? 0 : 1

  api_id = aws_apigatewayv2_api.this.id

  triggers = {
    redeployment = sha1(jsonencode({
      routes = {
        for key, route in local.routes : key => {
          route_key              = route.route_key
          authorization_type     = route.authorization_type
          authorizer_id          = route.authorizer_id
          payload_format_version = route.payload_format_version
          timeout_milliseconds   = route.timeout_milliseconds
          lambda_invoke_arn      = route.lambda_invoke_arn
          throttling_burst_limit = route.throttling_burst_limit
          throttling_rate_limit  = route.throttling_rate_limit
        }
      }
    }))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_route.this,
    aws_apigatewayv2_integration.lambda
  ]
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = var.auto_deploy

  deployment_id = var.auto_deploy ? null : aws_apigatewayv2_deployment.this[0].id

  dynamic "access_log_settings" {
    for_each = local.access_log_enabled ? [1] : []

    content {
      destination_arn = var.access_log_destination_arn
      format          = var.access_log_format
    }
  }

  dynamic "route_settings" {
    for_each = {
      for key, route in local.routes : key => route
      if route.throttling_burst_limit != null ||
      route.throttling_rate_limit != null
    }

    content {
      route_key              = route_settings.value.route_key
      throttling_burst_limit = route_settings.value.throttling_burst_limit
      throttling_rate_limit  = route_settings.value.throttling_rate_limit
    }
  }

  tags = local.common_tags

  depends_on = [
    aws_apigatewayv2_route.this
  ]
}
