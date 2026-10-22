# Launch Template Module

## Overview

Creates a reusable Amazon EC2 Launch Template for use with Auto Scaling
Groups and other EC2 provisioning workflows.

The module defines instance launch configuration. It does not create EC2
instances or manage Auto Scaling capacity.

## Responsibilities

- Configure the approved AMI and instance type.
- Attach security groups and an IAM instance profile.
- Configure root EBS volume size, type, and encryption.
- Support an optional customer-managed KMS key.
- Require IMDSv2 by default.
- Configure detailed monitoring.
- Support optional user data.
- Configure instance and volume tags.
- Expose Launch Template identifiers and version information.

## Non-Responsibilities

This module does not create or manage:

- VPCs or subnets
- Security groups
- IAM roles or instance profiles
- KMS keys
- EC2 instances directly
- Auto Scaling Groups
- Load balancers

These are managed by separate modules.

## Dependencies

The environment supplies:

- Approved AMI ID
- Instance type
- Security group IDs
- IAM instance profile name
- Optional KMS key ID or ARN
- Root device name for the selected AMI

## Security Defaults

- IMDSv2 is required by default.
- Root EBS encryption is enabled by default.
- Detailed monitoring is enabled by default.
- The metadata response hop limit is set to 1.
- Instance metadata tags are disabled.
- IAM and security groups are supplied externally.

## Version Management

The module exposes the latest and default Launch Template versions.

A new default version does not automatically guarantee that existing
instances will be replaced. Instance refresh and rollout controls belong
to the Auto Scaling Group configuration.

## Outputs

- `launch_template_id`
- `launch_template_arn`
- `launch_template_name`
- `latest_version`
- `default_version`

## Usage

The environment should instantiate this module and pass its outputs to
the Auto Scaling Group module when that module is implemented.