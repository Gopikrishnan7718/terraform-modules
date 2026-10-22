# RDS Terraform Module

## 1. Overview

This module provisions an Amazon RDS DB instance with configurable database engine settings, storage, subnet placement, security group rules, encryption, backups, availability, and monitoring.

It is designed for reuse across Terraform environments such as development, testing, and production.

## 2. Features

- PostgreSQL, MySQL, and MariaDB engine selection
- Configurable engine version and DB instance class
- Configurable storage allocation and autoscaling
- Storage encryption with optional customer-managed AWS KMS key
- RDS-managed master password through AWS Secrets Manager
- DB subnet group using supplied subnet IDs
- Dedicated database security group
- Ingress from approved security groups or IPv4 CIDR blocks
- Configurable Multi-AZ deployment
- Automated backup retention and maintenance windows
- Deletion protection and final snapshot configuration
- Optional Performance Insights
- Optional RDS Enhanced Monitoring
- CloudWatch alarms for CPU utilization and free storage
- Configurable resource tags

## 3. Requirements

- Terraform `>= 1.9.0, < 2.0.0`
- AWS provider `>= 6.0.0, < 7.0.0`
- An existing VPC
- At least two appropriate subnet IDs for the DB subnet group
- Appropriate AWS IAM permissions for RDS, EC2 security groups, IAM, CloudWatch, and KMS resources as applicable

The selected engine version, DB instance class, storage type, monitoring options, and other settings must be supported by the target AWS Region.

## 4. Usage

The following is an example configuration for a PostgreSQL database. The engine version is an example and must be confirmed as supported in the target Region before deployment.

```hcl
module "rds" {
  source = "../../modules/RDS"

  identifier     = "devops-postgres-dev"
  engine         = "postgres"
  engine_version = "16.4"
  instance_class = "db.t3.micro"

  database_name  = "applicationdb"
  master_username = "dbadmin"

  manage_master_user_password = true

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  subnet_ids = module.vpc.private_db_subnet_ids
  vpc_id     = module.vpc.vpc_id

  allowed_security_group_ids = [
    module.security_groups.app_security_group_id
  ]

  publicly_accessible = false
  multi_az            = true

  backup_retention_period = 7
  deletion_protection     = true
  skip_final_snapshot     = false

  monitoring_interval       = 60
  cloudwatch_alarms_enabled = true

  tags = {
    Environment = "dev"
    Project     = "devops-platform"
    ManagedBy   = "Terraform"
  }

  environment_tags = {
    Environment = "dev"
  }
}
```

The module and output names in this example must match the actual outputs exposed by your VPC and security group modules. Confirm these references when integrating the modules in `environments/dev`.

## 5. Input variables

### Database configuration

| Variable | Description | Default |
|---|---|---|
| `identifier` | Unique RDS DB instance identifier. | Required |
| `engine` | Supported engine: `postgres`, `mysql`, or `mariadb`. | `"postgres"` |
| `engine_version` | Database engine version. | Required |
| `instance_class` | RDS DB instance class. | `"db.t3.micro"` |
| `database_name` | Optional initial database name. | `null` |
| `master_username` | Master database username. | `"dbadmin"` |
| `port` | Database listener port. | Engine-specific default |

### Storage and encryption

| Variable | Description | Default |
|---|---|---|
| `allocated_storage` | Initial storage in GiB. | `20` |
| `max_allocated_storage` | Maximum storage allocation for autoscaling; zero disables it. | `100` |
| `storage_type` | Storage type. | `"gp3"` |
| `storage_encrypted` | Enables storage encryption. | `true` |
| `kms_key_id` | Optional KMS key ARN or ID for storage encryption. | `null` |

### Credentials

| Variable | Description | Default |
|---|---|---|
| `manage_master_user_password` | Lets RDS manage the master password through Secrets Manager. | `true` |
| `master_user_secret_kms_key_id` | Optional KMS key for the RDS-managed secret. | `null` |

Do not place database passwords in source control or hardcode them in Terraform configuration.

### Network configuration

| Variable | Description | Default |
|---|---|---|
| `vpc_id` | Existing VPC ID. | Required |
| `subnet_ids` | Subnets used by the DB subnet group. | Required |
| `allowed_security_group_ids` | Approved source security groups. | `[]` |
| `allowed_cidr_blocks` | Approved IPv4 CIDR ranges. | `[]` |
| `publicly_accessible` | Whether the database is publicly accessible. | `false` |

Prefer security group references over CIDR-based database ingress. The subnet IDs must belong to the specified VPC and satisfy RDS subnet group requirements.

### Availability and backups

| Variable | Description | Default |
|---|---|---|
| `multi_az` | Enables Multi-AZ deployment. | `true` |
| `backup_retention_period` | Automated backup retention in days. | `7` |
| `backup_window` | Preferred daily backup window in UTC. | `"18:00-18:30"` |
| `maintenance_window` | Preferred weekly maintenance window in UTC. | `"sun:19:00-sun:19:30"` |
| `auto_minor_version_upgrade` | Allows automatic minor engine version upgrades. | `true` |
| `apply_immediately` | Applies supported changes immediately. | `false` |
| `deletion_protection` | Prevents deletion of the DB instance. | `true` |
| `skip_final_snapshot` | Skips the final snapshot when deleting the instance. | `false` |
| `final_snapshot_identifier` | Optional explicit final snapshot identifier. | `null` |
| `copy_tags_to_snapshot` | Copies DB instance tags to snapshots. | `true` |

### Monitoring