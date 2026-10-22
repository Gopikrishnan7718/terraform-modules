
output "api_id" {
  description = "ID of the API Gateway HTTP API."
  value       = aws_apigatewayv2_api.this.id
}

output "api_arn" {
  description = "ARN of the API Gateway HTTP API."
  value       = aws_apigatewayv2_api.this.arn
}

output "api_endpoint" {
  description = "Default endpoint of the HTTP API."
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "execution_arn" {
  description = "Execution ARN used to scope Lambda invocation permissions."
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "stage_name" {
  description = "Name of the API Gateway stage."
  value       = aws_apigatewayv2_stage.this.name
}

output "invoke_url" {
  description = "Base URL for invoking the configured API stage."
  value       = aws_apigatewayv2_stage.this.invoke_url
}

output "route_ids" {
  description = "Map of configured route identifiers to API Gateway route IDs."
  value = {
    for key, route in aws_apigatewayv2_route.this : key => route.id
  }
}

output "integration_ids" {
  description = "Map of configured route identifiers to API Gateway integration IDs."
  value = {
    for key, integration in aws_apigatewayv2_integration.lambda : key => integration.id
  }
}
