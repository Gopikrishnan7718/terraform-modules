# API Gateway Module

## 1. Overview

This Terraform module provisions an Amazon API Gateway HTTP API with configurable Lambda proxy integrations, HTTP routes, authorization settings, stage configuration, optional CORS, throttling, and optional CloudWatch access logging.

The module integrates with existing Lambda functions or the reusable Lambda module in this repository. It does not create Lambda functions itself.

## 2. Features

- Amazon API Gateway HTTP API.
- Multiple Lambda proxy integrations.
- Configurable HTTP routes and authorization.
- Lambda invocation permissions scoped to the API.
- `NONE`, `AWS_IAM`, and `JWT` authorization types.
- Optional Cross-Origin Resource Sharing (CORS).
- Configurable stage name and automatic deployment.
- Optional per-route throttling.
- Optional CloudWatch access logging.
- Configurable resource tags.
- Terraform-managed API deployment when automatic deployment is disabled.

## 3. Requirements

- Terraform `>= 1.9.0, < 2.0.0`.
- AWS provider `>= 6.0.0, < 7.0.0`.
- An existing Lambda function for each configured route.
- An existing CloudWatch log group if access logging is enabled.
- A compatible JWT authorizer when using JWT authorization.
- Appropriate AWS IAM permissions to create API Gateway resources and Lambda invocation permissions.

## 4. Usage

### Example A: Integrate existing Lambda functions

The following example assumes that the Lambda functions already exist in the Terraform configuration.

```hcl
module "api_gateway" {
  source = "../../modules/API_Gateway"

  name        = "devops-http-api"
  description = "HTTP API for application endpoints"

  protocol_type                 = "HTTP"
  disable_execute_api_endpoint  = false
  auto_deploy                   = true
  stage_name                    = "$default"

  routes = {
    get_health = {
      route_key           = "GET /health"
      lambda_function_arn = aws_lambda_function.health.arn
      lambda_invoke_arn   = aws_lambda_function.health.invoke_arn
      authorization_type  = "NONE"
    }

    get_users = {
      route_key           = "GET /users"
      lambda_function_arn = aws_lambda_function.users.arn
      lambda_invoke_arn   = aws_lambda_function.users.invoke_arn
      authorization_type  = "AWS_IAM"
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "devops-platform"
  }
}
```

### Example B: Integrate the Lambda module from this repository

When Lambda functions are provisioned through the reusable Lambda module, pass its outputs to API Gateway.

```hcl
module "api_gateway" {
  source = "../../modules/API_Gateway"

  name        = "devops-http-api"
  description = "HTTP API for application endpoints"

  auto_deploy = true
  stage_name  = "$default"

  routes = {
    get_health = {
      route_key           = "GET /health"
      lambda_function_arn = module.lambda.function_arn
      lambda_invoke_arn   = module.lambda.function_invoke_arn
      authorization_type  = "NONE"
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "devops-platform"
  }
}
```

The `module.lambda` reference must match the actual module label used in the calling Terraform configuration.

## 5. Lambda ARN distinction

The route configuration requires two separate ARN values.

| Argument | Purpose |
|---|---|
| `lambda_function_arn` | Identifies the Lambda function for the `aws_lambda_permission` resource. |
| `lambda_invoke_arn` | Supplies the invocation URI used by the API Gateway Lambda integration. |

For a Lambda function created directly through the AWS provider, use:

```hcl
lambda_function_arn = aws_lambda_function.health.arn
lambda_invoke_arn   = aws_lambda_function.health.invoke_arn
```

For a Lambda function created through this repository's Lambda module, use:

```hcl
lambda_function_arn = module.lambda.function_arn
lambda_invoke_arn   = module.lambda.function_invoke_arn
```

Do not substitute the function ARN for the invocation ARN. They serve different purposes.

## 6. Input variables

### General configuration

| Variable | Description | Default |
|---|---|---|
| `name` | Name of the HTTP API. | Required |
| `description` | API description. | `null` |
| `protocol_type` | API protocol type. This module supports HTTP. | `"HTTP"` |
| `disable_execute_api_endpoint` | Disables the default execute-api endpoint when enabled. | `false` |
| `tags` | Tags applied to supported API Gateway resources. | `{}` |

### Route configuration

The `routes` variable is a map of route objects. Each map key should be a stable Terraform identifier.

| Field | Description | Default |
|---|---|---|
| `route_key` | HTTP method and path, such as `GET /health`. | Required |
| `lambda