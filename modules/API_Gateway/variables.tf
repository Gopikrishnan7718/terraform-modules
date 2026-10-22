
variable "name" {
  description = "Name of the API Gateway HTTP API."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0 && length(var.name) <= 128
    error_message = "The API name must contain between 1 and 128 characters."
  }
}

variable "description" {
  description = "Description of the HTTP API."
  type        = string
  default     = null
}

variable "protocol_type" {
  description = "API Gateway protocol type."
  type        = string
  default     = "HTTP"

  validation {
    condition     = var.protocol_type == "HTTP"
    error_message = "This module supports HTTP APIs only."
  }
}

variable "cors_configuration" {
  description = "Optional CORS configuration for browser-based clients."
  type = object({
    allow_credentials = optional(bool, false)
    allow_headers     = optional(list(string), [])
    allow_methods     = optional(list(string), [])
    allow_origins     = optional(list(string), [])
    expose_headers    = optional(list(string), [])
    max_age           = optional(number, 0)
  })
  default = null

  validation {
    condition = var.cors_configuration == null ? true : (
      var.cors_configuration.max_age >= 0 &&
      floor(var.cors_configuration.max_age) == var.cors_configuration.max_age
    )
    error_message = "CORS max_age must be a non-negative integer."
  }
}

variable "disable_execute_api_endpoint" {
  description = "Whether to disable the default execute-api endpoint."
  type        = bool
  default     = false
}

variable "routes" {
  description = "HTTP API routes and their Lambda integrations, keyed by stable Terraform identifiers."

  type = map(object({
    route_key              = string
    lambda_function_arn    = string
    lambda_invoke_arn      = string
    authorization_type     = optional(string, "AWS_IAM")
    authorizer_id          = optional(string)
    payload_format_version = optional(string, "2.0")
    timeout_milliseconds   = optional(number, 30000)
    throttling_burst_limit = optional(number)
    throttling_rate_limit  = optional(number)
  }))

  default = {}

  validation {
    condition = alltrue([
      for route in values(var.routes) :
      length(trimspace(route.route_key)) > 0 &&
      can(regex("^(GET|POST|PUT|PATCH|DELETE|OPTIONS|HEAD|ANY) /.+$|^\\$default$", route.route_key)) &&
      can(regex(
        "^arn:[^:]+:lambda:[^:]+:[0-9]{12}:function:[A-Za-z0-9_-]+(:[A-Za-z0-9_-]+)?$",
        route.lambda_function_arn
      )) &&
      can(regex(
        "^arn:[^:]+:apigateway:[^:]+:lambda:path/",
        route.lambda_invoke_arn
      )) &&
      contains(["NONE", "AWS_IAM", "JWT"], route.authorization_type) &&
      contains(["1.0", "2.0"], route.payload_format_version) &&
      route.timeout_milliseconds >= 50 &&
      route.timeout_milliseconds <= 30000 &&
      floor(route.timeout_milliseconds) == route.timeout_milliseconds &&
      (
        route.throttling_burst_limit == null ||
        (
          route.throttling_burst_limit >= 0 &&
          floor(route.throttling_burst_limit) == route.throttling_burst_limit
        )
      ) &&
      (
        route.throttling_rate_limit == null ||
        route.throttling_rate_limit >= 0
      )
    ])

    error_message = "Routes must use valid route keys, Lambda function ARNs, Lambda invocation ARNs, authorization types, payload versions, timeout values, and throttling settings."
  }

  validation {
    condition = length(distinct([
      for route in values(var.routes) : route.route_key
    ])) == length(var.routes)

    error_message = "Each route_key must be unique."
  }
}

variable "auto_deploy" {
  description = "Whether the API stage automatically deploys API changes."
  type        = bool
  default     = true
}

variable "stage_name" {
  description = "Name of the API Gateway stage."
  type        = string
  default     = "$default"

  validation {
    condition = (
      var.stage_name == "$default" ||
      can(regex("^[A-Za-z0-9_-]{1,128}$", var.stage_name))
    )
    error_message = "The stage name must be $default or contain 1 to 128 alphanumeric, underscore, or hyphen characters."
  }
}

variable "access_log_destination_arn" {
  description = "ARN of an existing CloudWatch log group for API access logs."
  type        = string
  default     = null

  validation {
    condition = var.access_log_destination_arn == null ? true : can(regex(
      "^arn:[^:]+:logs:[^:]+:[0-9]{12}:log-group:.+",
      var.access_log_destination_arn
    ))
    error_message = "The access log destination must be a valid CloudWatch Logs log group ARN."
  }
}

variable "access_log_format" {
  description = "JSON access-log format for the API stage."
  type        = string
  default     = "{\"requestId\":\"$context.requestId\",\"ip\":\"$context.identity.sourceIp\",\"requestTime\":\"$context.requestTime\",\"httpMethod\":\"$context.httpMethod\",\"routeKey\":\"$context.routeKey\",\"status\":\"$context.status\",\"protocol\":\"$context.protocol\",\"responseLength\":\"$context.responseLength\",\"integrationError\":\"$context.integrationErrorMessage\"}"
}

variable "tags" {
  description = "Tags applied to supported API Gateway resources."
  type        = map(string)
  default     = {}
}
