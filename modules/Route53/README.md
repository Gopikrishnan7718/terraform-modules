# Route 53 DNS Records Module

## 1. Overview

This reusable Terraform module creates Route 53 alias records for an existing
Application Load Balancer (ALB) in an existing public hosted zone.

It supports:
- An alias A record for IPv4 DNS resolution.
- An optional alias AAAA record for IPv6 DNS resolution.
- Route 53 alias target-health evaluation.
- Reusable inputs for different environments and application domains.

This module manages DNS records only. It does not create a hosted zone, register
a domain, configure domain delegation, or create an ALB.

## 2. Architecture

Application DNS name
        |
        v
Route 53 alias A record
        |
        v
Application Load Balancer
        |
        v
Application targets

An optional AAAA record can be created when IPv6 is enabled and supported by
the ALB configuration.

## 3. Directory Structure

modules/Route53/
├── versions.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
└── README.md

## 4. Requirements

- Terraform >= 1.9.0 and < 2.0.0.
- AWS provider >= 6.0.0 and < 7.0.0.
- An existing public Route 53 hosted zone.
- An existing Application Load Balancer.
- The ALB DNS name and its canonical hosted-zone ID.
- An application DNS name within the hosted zone.
- Appropriate IAM permissions to manage Route 53 records.

Provider configuration belongs to the root configuration.

## 5. Resources

| Resource | Purpose |
|---|---|
| aws_route53_record.alb_a | Creates the A alias record |
| aws_route53_record.alb_aaaa | Optionally creates the AAAA alias record |

## 6. Input Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| hosted_zone_id | string | Required | Existing public hosted zone ID |
| record_name | string | Required | Application DNS name |
| alb_dns_name | string | Required | ALB DNS name |
| alb_canonical_hosted_zone_id | string | Required | ALB canonical hosted-zone ID |
| create_aaaa_record | bool | false | Whether to create an AAAA alias record |
| evaluate_target_health | bool | true | Whether Route 53 evaluates alias target health |

## 7. Outputs

| Output | Description |
|---|---|
| record_name | Normalized record name |
| record_fqdn | Fully qualified A-record DNS name |
| record_zone_id | Hosted zone containing the record |
| a_record_id | A-record resource ID |
| aaaa_record_fqdn | AAAA-record FQDN, or null when disabled |
| aaaa_record_id | AAAA-record resource ID, or null when disabled |

## 8. Security and Operational Considerations

- Use a hosted zone that you own or are authorized to manage.
- Confirm that public DNS delegation is configured correctly outside this module.
- Restrict Terraform execution permissions to the required hosted zone.
- Do not create duplicate records for the same name and record type.
- Enable AAAA record creation only when the ALB is configured for IPv6.
- Verify that the ALB listeners, certificates, security groups, and target health
  are configured independently.
- DNS resolution does not guarantee application availability.

## 9. Validation and Integration

Formatting can be checked with:

terraform fmt -check -recursive modules/Route53

Terraform validation must be performed through an initialized Terraform root
configuration that references this module.

During the planned integration stage:
1. Obtain the hosted-zone ID from the existing hosted zone.
2. Pass the ALB DNS name and canonical hosted-zone ID from the ALB module outputs.
3. Review the Terraform plan.
4. Confirm the record name and destination before applying changes.

Do not apply changes until the DNS configuration and plan have been reviewed.