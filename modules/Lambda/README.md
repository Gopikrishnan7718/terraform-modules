# AWS Lambda Module

## Overview

This module provisions an AWS Lambda function with a dedicated IAM execution role and optional CloudWatch logging, VPC networking, KMS encryption, and X-Ray tracing.

## Features

- ZIP deployment packages from a local file or S3
- Dedicated Lambda execution role
- AWS-managed basic execution policy
- Optional additional managed and inline IAM policies
- Configurable runtime, handler, architecture, memory, and timeout
- Optional environment variables and KMS encryption
- Optional VPC attachment
- Configurable reserved concurrency
- Optional published versions
- CloudWatch log group with configurable retention
- Optional CloudWatch log encryption
- Optional active X-Ray tracing
- Standard resource tagging

## Architecture

```text
Deployment ZIP
     |
     v
AWS Lambda Function
     |
     +---- IAM Execution Role
     |        |
     |        +---- CloudWatch permissions
     |        +---- Optional application permissions
     |
     +---- Optional VPC networking
     |
     +---- CloudWatch Log Group
     |
     +---- Optional X-Ray tracing
```

## Usage: Local ZIP package

```hcl
module "lambda" {
  source = "../../modules/Lambda"

  function_name = "geo-dev-health"
  description   = "Health endpoint handler"

  runtime      = "python3.12"
  handler      = "app.handler"
  architecture = "arm64"

  filename         = "${path.module}/artifacts/health.zip"
  source_code_hash = filebase64sha256("${path.module}/artifacts/health.zip")

  memory_size = 256
  timeout     = 10
  publish     = true

  environment_variables = {
    ENVIRONMENT = "dev"
  }

  log_retention_in_days = 30
  logging_enabled       = true
  enable_xray_tracing   = false

  common_tags = {
    Environment = "dev"
    Project     = "GeoNode"
    Owner       = "Platform"
  }
}
```

Choose a runtime that AWS Lambda currently supports and that matches the code in your package.

## Usage: S3 deployment package

```hcl
module "lambda" {
  source = "../../modules/Lambda"

  function_name = "geo-dev-api-handler"
  runtime       = "python3.12"
  handler       = "app.handler"

  s3_bucket         = "example-lambda-artifacts"
  s3_key            = "geo/dev/api-handler.zip"
  s3_object_version = "example-object-version-id"

  memory_size = 512
  timeout     = 30

  logging_enabled = true
}
```

The example bucket, object key, and object version are placeholders. The S3 object must exist and be accessible to the deployment identity.

## Inputs

| Input | Description |
|---|---|
| `function_name` | Lambda function name |
| `description` | Function description |
| `runtime` | Lambda runtime |
| `handler` | Function handler |
| `architecture` | `arm64` or `x86_64` |
| `filename` | Local ZIP package path |
| `source_code_hash` | Hash used to detect package changes |
| `s3_bucket` | S3 deployment package bucket |
| `s3_key` | S3 deployment package object key |
| `s3_object_version` | Optional S3 object version |
| `memory_size` | Memory allocation in MB |
| `timeout` | Function timeout in seconds |
| `publish` | Whether to publish a version |
| `reserved_concurrent_executions` | Reserved concurrency setting |
| `environment_variables` | Non-secret environment variables |
| `kms_key_arn` | Optional environment-variable encryption key |
| `enable_vpc_config` | Enables VPC attachment |
| `subnet_ids` | VPC subnet IDs |
| `security_group_ids` | VPC security group IDs |
| `log_retention_in_days` | CloudWatch log retention |
| `log_group_kms_key_id` | Optional CloudWatch log encryption key |
| `enable_xray_tracing` | Enables active X-Ray tracing |
| `additional_policy_arns` | Additional managed IAM policy ARNs |
| `additional_policy_json` | Additional inline IAM policy JSON |
| `role_name` | Optional custom execution role name |
| `logging_enabled` | Creates or manages the function's log group |
| `common_tags` | Standard tags |
| `extra_environment_tags` | Additional tags |

## Outputs

| Output | Description |
|---|---|
| `function_name` | Lambda function name |
| `function_arn` | Function ARN |
| `function_invoke_arn` | API Gateway integration ARN |
| `function_version` | Published version or `$LATEST` |
| `function_qualified_arn` | Version-qualified function ARN |
| `execution_role_name` | IAM execution role name |
| `execution_role_arn` | IAM execution role ARN |
| `log_group_name` | Managed CloudWatch log group name |
| `log_group_arn` | Managed CloudWatch log group ARN |

## Security considerations

1. Follow least privilege when granting application permissions.
2. Do not store secrets directly in Terraform-managed environment variables.
3. Use Secrets Manager or Systems Manager Parameter Store for application secrets.
4. Scope KMS permissions to the required keys.
5. When VPC networking is enabled, provide suitable subnet and security group IDs and the required network-interface permissions.
6. Protect deployment artifacts and restrict who can update them.
7. Set suitable concurrency and timeout limits for the workload.
8. Configure CloudWatch log retention to meet operational and compliance requirements.

## Important limitations

- This module supports ZIP deployment packages, not container-image packages.
- Lambda execution roles are created by this module.
- VPC infrastructure, application-specific IAM permissions, and deployment artifacts must be managed separately.
- API Gateway invocation permissions are managed by the API Gateway module.
- Runtime support must be checked against current AWS Lambda runtime availability.
- Validate configuration and review the execution plan before deployment.