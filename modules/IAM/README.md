# IAM Module

Creates IAM roles and instance profiles required by infrastructure workloads.

## Responsibilities

This module manages:

- EC2 application IAM role
- EC2 instance profile
- Least-privilege access to the application artifact S3 bucket

The module does not create service-specific IAM roles that belong to other infrastructure modules.

## Resources

The module creates:

- `aws_iam_role.ec2`
- `aws_iam_instance_profile.ec2`
- `aws_iam_role_policy.ec2`

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | `string` | Yes | Base name used for IAM resources |
| `artifact_bucket_arn` | `string` | Yes | ARN of the S3 bucket used for application artifacts |
| `common_tags` | `map(string)` | No | Common tags applied to IAM resources |

## Permissions

The EC2 role is granted only the permissions required to access application artifacts:

- `s3:GetObject`
- `s3:PutObject`
- `s3:DeleteObject`
- `s3:ListBucket`

Object-level permissions apply to objects within the specified artifact bucket.

Bucket-level listing permission applies only to the specified bucket.

## Outputs

| Name | Description |
|------|-------------|
| `ec2_role_name` | Name of the EC2 IAM role |
| `ec2_role_arn` | ARN of the EC2 IAM role |
| `ec2_instance_profile_name` | Name of the EC2 instance profile |
| `ec2_instance_profile_arn` | ARN of the EC2 instance profile |

## Security Design

The EC2 role follows least-privilege principles.

The role:

- Can be assumed only by the EC2 service.
- Does not receive `AdministratorAccess`.
- Does not use `Resource = "*"` for S3 permissions.
- Is restricted to the explicitly supplied artifact bucket.
- Separates bucket-level and object-level S3 permissions.

## Dependencies

The artifact S3 bucket is owned by the S3 module.

The environment layer passes the S3 bucket ARN to this module.

```text
S3 Module
    |
    | artifact_bucket_arn
    v
Environment
    |
    v
IAM Module
    |
    v
EC2 Role