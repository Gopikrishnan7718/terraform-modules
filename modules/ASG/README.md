# Auto Scaling Group (ASG) Module

## 1. Overview

This reusable Terraform module provisions an AWS Auto Scaling Group (ASG) using an existing EC2 Launch Template.

The module manages instance capacity, subnet placement, target group association, health checks, rolling instance refresh, and tag propagation.

It is designed for integration into a reusable AWS infrastructure framework and supports production-oriented configuration through explicit inputs and validation.

## 2. Responsibilities

This module is responsible for:

- Creating an Auto Scaling Group.
- Launching EC2 instances through an existing Launch Template.
- Placing instances in the supplied subnets.
- Associating one or more existing ALB target groups.
- Configuring minimum, maximum, and desired instance capacity.
- Configuring EC2 or ELB health checks.
- Supporting rolling instance refresh.
- Configuring instance refresh health percentages and warmup.
- Requesting automatic rollback when an instance refresh fails.
- Propagating common tags to launched instances.
- Exposing ASG attributes through Terraform outputs.

## 3. Architecture

The intended integration flow is:

```text
Application Load Balancer Module
             |
             v
        Target Group
             |
             | target_group_arns
             v
      Auto Scaling Group
             |
             | launch_template_id
             | launch_template_version
             v
       Launch Template
             |
             v
          EC2 Instances
```

The environment root configuration is responsible for wiring the modules together.

The ASG module does not create a separate Launch Template, ALB, target group, or individually managed EC2 instances.

## 4. Directory Structure

```text
modules/
└── ASG/
    ├── versions.tf
    ├── variables.tf
    ├── locals.tf
    ├── main.tf
    ├── outputs.tf
    └── README.md
```

## 5. Requirements

- Terraform >= 1.9.0 and < 2.0.0.
- AWS provider >= 6.0.0 and < 7.0.0.
- An existing EC2 Launch Template.
- An explicit numeric Launch Template version.
- At least two suitable subnets across the intended Availability Zones.
- Existing target groups when ELB health checks are enabled.
- Appropriate IAM permissions for the Terraform execution identity.
- Sufficient EC2 capacity and account quotas for normal scaling and instance refresh.

The reusable module declares its Terraform and provider requirements but does not configure the AWS provider. Provider configuration and dependency lock-file management belong to the root configuration.

## 6. Resources

| Resource | Purpose |
|---|---|
| `aws_autoscaling_group.this` | Creates and manages the Auto Scaling Group |

The ASG launches and manages EC2 instances using the configured Launch Template.

## 7. Input Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | Required | Base name used to generate the ASG name |
| `launch_template_id` | `string` | Required | ID of the existing Launch Template |
| `launch_template_version` | `string` | Required | Explicit numeric Launch Template version |
| `subnet_ids` | `set(string)` | Required | Subnets where instances can launch |
| `target_group_arns` | `set(string)` | `[]` | Existing target group ARNs associated with the ASG |
| `min_size` | `number` | `2` | Minimum instance capacity |
| `max_size` | `number` | `6` | Maximum instance capacity |
| `desired_capacity` | `number` | `2` | Desired instance capacity |
| `health_check_type` | `string` | `"EC2"` | Health-check mechanism: `EC2` or `ELB` |
| `health_check_grace_period` | `number` | `300` | Seconds to wait after launch before acting on failed health checks |
| `protect_from_scale_in` | `bool` | `false` | Enables protection against scale-in termination |
| `termination_policies` | `list(string)` | `["Default"]` | Ordered list of termination policies |
| `enable_instance_refresh` | `bool` | `true` | Enables rolling instance refresh configuration |
| `instance_refresh_min_healthy_percentage` | `number` | `100` | Minimum healthy percentage during refresh |
| `instance_refresh_max_healthy_percentage` | `number` | `200` | Maximum healthy percentage permitted during refresh |
| `instance_refresh_warmup_seconds` | `number` | `300` | Instance