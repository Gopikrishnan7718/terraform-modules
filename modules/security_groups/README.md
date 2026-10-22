# AWS Security Groups Terraform Module

## Overview

This module creates three AWS security groups within an existing VPC to control traffic between the load balancer, application workloads, and database.

## Resources Created

| Security Group | Purpose |
|---|---|
| ALB Security Group | Controls incoming HTTP/HTTPS traffic to the Application Load Balancer. |
| Application Security Group | Allows application traffic from the ALB and approved outbound HTTPS connections. |
| Database Security Group | Allows database connections from application workloads. |

## Traffic Rules

### 1. ALB Security Group
- Allows inbound HTTP traffic on port `80` from configured IPv4 CIDR blocks.
- Allows inbound HTTPS traffic on port `443` from configured IPv4 CIDR blocks.
- Allows outbound traffic to application workloads on the configured application port.

### 2. Application Security Group
- Allows inbound application traffic only from the ALB security group.
- Allows outbound database connections to the database security group.
- Allows outbound HTTPS traffic on port `443` to configured IPv4 CIDR blocks.

### 3. Database Security Group
- Allows inbound database connections only from the application security group on the configured database port.
- The default database port is `5432`, commonly used by PostgreSQL.

**Note:** This module creates security groups with explicit ingress and egress rules. It does not configure the ALB, application servers, database, VPC, or NAT Gateway themselves.

## Prerequisites

- An existing AWS VPC.
- A valid VPC ID.
- Appropriate AWS credentials and permissions.
- Terraform `>= 1.9.0, < 2.0.0`.
- AWS provider `>= 6.0.0, < 7.0.0`.

## Input Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `name` | Yes | None | Base name used for security group names. |
| `vpc_id` | Yes | None | Existing VPC ID. |
| `alb_ingress_cidr_blocks` | Yes | None | IPv4 CIDRs allowed to access the ALB. |
| `application_port` | Yes | None | Application listening port. |
| `application_egress_cidr_blocks` | Yes | None | IPv4 CIDRs allowed for outbound application HTTPS traffic. |
| `alb_http_port` | No | `80` | ALB HTTP port. |
| `alb_https_port` | No | `443` | ALB HTTPS port. |
| `database_port` | No | `5432` | Database listening port. |
| `application_https_port` | No | `443` | Outbound application HTTPS port. |
| `common_tags` | No | `{}` | Common tags applied to security groups. |

## Example Usage

```hcl
module "security_groups" {
  source = "../../modules/security_groups"

  name   = "dev-app"
  vpc_id = module.vpc.vpc_id

  alb_ingress_cidr_blocks = [
    "10.0.0.0/8"
  ]

  application_port = 3000

  application_egress_cidr_blocks = [
    "0.0.0.0/0"
  ]

  database_port = 5432

  common_tags = {
    Environment = "dev"
    Project     = "terraform-aws-infrastructure"
  }
}
```

**Security consideration:** The example permits ALB access from the private IPv4 range `10.0.0.0/8` and application HTTPS egress to `0.0.0.0/0`. Adjust these CIDRs to match the intended network access policy. The outbound HTTPS rule permits connections to any IPv4 destination when `0.0.0.0/0` is configured; it does not restrict access to specific external services.

## Outputs

| Output | Description |
|---|---|
| `alb_security_group_id` | ID of the ALB security group. |
| `application_security_group_id` | ID of the application security group. |
| `database_security_group_id` | ID of the database security group. |
| `security_group_ids` | Map containing all three security group IDs. |

## Validation

Run the following commands from the repository root:

```bash
terraform -chdir=modules/security_groups init
terraform -chdir=modules/security_groups validate
terraform fmt -check -recursive modules
```

These commands initialize the module directory, validate the Terraform configuration, and check formatting. They do not create AWS infrastructure.

## File Structure

```text
modules/security_groups/
├── locals.tf
├── main.tf
├── outputs.tf
├── rules.tf
├── variables.tf
├── versions.tf
└── README.md
```
