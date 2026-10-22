# EKS Terraform Module

## Overview

This module provisions an Amazon Elastic Kubernetes Service (EKS) cluster and one managed node group. It is designed for reusable AWS infrastructure deployments with configurable networking, IAM, security, logging, encryption, and cluster access.

## Features

- Configurable EKS cluster name and Kubernetes version
- Private and optional public Kubernetes API endpoint access
- Subnet configuration across multiple Availability Zones
- EKS control-plane IAM role creation or reuse of an existing role
- Managed worker node IAM role creation or reuse of an existing role
- Managed node group with configurable instance types and scaling
- Configurable node disk size, labels, and taints
- EC2 launch template with encrypted root volumes
- IMDSv2 enforcement and detailed EC2 monitoring
- Additional cluster and node security groups
- Configurable ingress rules for additional security groups
- EKS control-plane logs in CloudWatch Logs
- Configurable CloudWatch Logs retention and optional KMS encryption
- Optional EKS API data encryption using a supplied KMS key
- EKS access entries and access policy associations
- Standard resource tags and environment tags
- Terraform variable validation and lifecycle preconditions

## Requirements

- Terraform `>= 1.9.0, < 2.0.0`
- AWS provider `>= 6.0.0, < 7.0.0`
- An AWS account with permissions to create or use EKS, IAM, EC2 security groups, CloudWatch Logs, and KMS resources as configured
- Existing VPC subnets in at least two Availability Zones
- A compatible Kubernetes version and EC2 instance type for the selected AWS Region
- A KMS key ARN when `cluster_encryption_enabled = true`

## Architecture

The module provisions:

1. An Amazon EKS control plane
2. An EKS managed node group
3. IAM roles and policy attachments when existing role ARNs are not supplied
4. Additional cluster and worker-node security groups
5. An EC2 launch template for managed worker nodes
6. A CloudWatch log group for control-plane logs
7. Optional EKS access entries and access policy associations

The module expects an existing VPC and subnet IDs. VPC creation is handled separately by the VPC module.

## Usage

The following example shows how to use the EKS module with existing VPC subnets and a KMS key.

```hcl
module "eks" {
  source = "../../modules/EKS"

  cluster_name      = "geonode-dev-eks"
  kubernetes_version = "1.34"

  subnet_ids = module.vpc.private_subnet_ids

  cluster