
# Application Load Balancer (ALB) Module

## Overview

This module provisions a reusable AWS Application Load Balancer architecture for HTTP/HTTPS application traffic.

It creates:

- An internet-facing Application Load Balancer.
- A target group for EC2 instances.
- An HTTP listener on port 80.
- An optional HTTPS listener on port 443.
- HTTP-to-HTTPS redirection when HTTPS is enabled.
- Configurable target group health checks.
- Optional ALB access logging.
- Configurable deletion protection.
- Consistent resource tagging.

## Architecture

```text
Clients
   |
   v
Application Load Balancer
   |
   +-- HTTP :80
   |     |
   |     +-- HTTPS enabled  --> Redirect to HTTPS :443
   |     |
   |     +-- HTTPS disabled --> Forward to target group
   |
   +-- HTTPS :443 (optional)
         |
         v
    Target Group
         |
         v
    EC2 instances managed by an Auto Scaling Group
```

## Requirements

- Terraform >= 1.9.0 and < 2.0.0.
- AWS provider >= 6.0.0 and < 7.0.0.
- An existing VPC.
- At least two public subnets in different Availability Zones for an internet-facing ALB.
- Existing security groups permitting the intended inbound and outbound traffic.
- An ACM certificate in the same AWS Region when HTTPS is enabled.
- An S3 bucket and appropriate permissions when access logging is enabled.

## Resources

| Resource | Purpose |
|---|---|
| `aws_lb.this` | Application Load Balancer |
| `aws_lb_target_group.this` | EC2 instance target group |
| `aws_lb_listener.http` | HTTP listener when HTTPS is disabled |
| `aws_lb_listener.http_redirect` | HTTP-to-HTTPS redirect listener when HTTPS is enabled |
| `aws_lb_listener.https` | Optional HTTPS listener |

## Inputs

| Variable | Purpose |
|---|---|
| `name` | Base name used for ALB and target group resources |
| `vpc_id` | VPC containing the target group |
| `subnet_ids` | Subnets used by the ALB |
| `security_group_ids` | Security groups attached to the ALB |
| `target_port` | Application port; defaults to 3000 |
| `target_protocol` | Protocol used by the target group |
| `health_check_path` | Application health check path |
| `health_check_interval` | Interval between health checks |
| `health_check_timeout` | Health check timeout |
| `healthy_threshold` | Consecutive successes required for a healthy status |
| `unhealthy_threshold` | Consecutive failures required for an unhealthy status |
| `enable_https` | Enables HTTPS and HTTP redirection |
| `certificate_arn` | ACM certificate ARN for HTTPS |
| `ssl_policy` | TLS security policy |
| `enable_deletion_protection` | Prevents accidental ALB deletion |
| `access_logs_enabled` | Enables ALB access logs |
| `access_logs_bucket` | S3 bucket receiving access logs |
| `access_logs_prefix` | Optional S3 prefix for access logs |
| `common_tags` | Additional resource tags |

Refer to `variables.tf` for defaults, types, and validation rules.

## Outputs

| Output | Purpose |
|---|---|
| `alb_id` | ALB resource ID |
| `alb_arn` | ALB ARN |
| `alb_arn_suffix` | ALB CloudWatch metric identifier |
| `alb_dns_name` | AWS-assigned ALB DNS name |
| `alb_zone_id` | Canonical hosted zone ID for Route 53 aliases |
| `alb_name` | ALB name |
| `target_group_arn` | Target group ARN for ASG integration |
| `target_group_arn_suffix` | Target group CloudWatch metric identifier |
| `target_group_name` | Target group name |
| `target_group_id` | Target group resource ID |
| `http_listener_arn` | HTTP listener ARN when HTTPS is disabled |
| `http_redirect_listener_arn` | HTTP redirect listener ARN when HTTPS is enabled |
| `https_listener_arn` | HTTPS listener ARN when HTTPS is enabled |

## Security Considerations

- Restrict inbound traffic through the ALB security group to approved CIDRs.
- Permit application traffic only from the ALB security group at the instance level.
- Use HTTPS with an ACM certificate for production workloads.
- Keep deletion protection enabled in production.
- Enable access logging and configure S3 bucket permissions correctly.
- Configure the health check path to return a successful response from the application.
- Do not expose EC2 instances directly to the internet when they are intended to receive traffic through the ALB.
- Use the target group ARN to associate the Auto Scaling Group with the load balancer.

## Dependencies and Integration

The ALB module consumes existing VPC, subnet, and security group identifiers.

The intended dependency flow is:

```text
VPC
 |
 +--> Security Groups
 |
 +--> Launch Template
 |
 +--> ALB
        |
        +--> Target Group ARN
                 |
                 v
                ASG
```

The ASG module must accept the target group ARN and pass it to the
`aws_autoscaling_group` resource through `target_group_arns`.

The environment root module is responsible for wiring these dependencies together.

## Operational Notes

- The target group uses instance targets.
- The default application port is 3000.
- The default health check path is `/`.
- The default health check matcher accepts HTTP status codes 200 through 399.
- ALB access logging requires a correctly configured S3 bucket policy.
- HTTPS requires a valid ACM certificate in the ALB's Region.
- Terraform formatting alone does not validate AWS provider schemas or AWS-side requirements.
