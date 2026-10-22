# S3 Module

Creates a secure, reusable Amazon S3 bucket for infrastructure workloads.

## Responsibilities

This module manages:

- S3 bucket
- Account-regional bucket naming
- Bucket ownership controls
- Public access blocking
- Versioning
- Server-side encryption
- Lifecycle management
- Common resource tags

The module provides a secure baseline and does not create application-specific IAM permissions.

## Resources

The module creates:

- `aws_s3_bucket.this`
- `aws_s3_bucket_ownership_controls.this`
- `aws_s3_bucket_public_access_block.this`
- `aws_s3_bucket_versioning.this`
- `aws_s3_bucket_server_side_encryption_configuration.this`
- `aws_s3_bucket_lifecycle_configuration.this`

## Bucket Naming

The module constructs an account-regional S3 bucket name using:

```text
<name>-<account-id>-<region>-an