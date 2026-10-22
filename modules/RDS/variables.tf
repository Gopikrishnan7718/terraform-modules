
variable "identifier" {
  description = "Unique RDS DB instance identifier."
  type        = string

  validation {
    condition = (
      length(var.identifier) >= 1 &&
      length(var.identifier) <= 63 &&
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.identifier)) &&
      !strcontains(var.identifier, "--")
    )
    error_message = "identifier must be 1-63 characters, start with a lowercase letter, contain only lowercase letters, numbers, or hyphens, and have no consecutive or trailing hyphens."
  }
}

variable "engine" {
  description = "Database engine supported by this module."
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.engine)
    error_message = "engine must be postgres, mysql, or mariadb."
  }
}

variable "engine_version" {
  description = "Database engine version compatible with the selected AWS Region and instance class."
  type        = string
}

variable "instance_class" {
  description = "RDS DB instance class."
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.instance_class))
    error_message = "instance_class must use a format such as db.t3.micro."
  }
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
  default     = 20

  validation {
    condition = (
      var.allocated_storage >= 20 &&
      floor(var.allocated_storage) == var.allocated_storage
    )
    error_message = "allocated_storage must be an integer of at least 20 GiB."
  }
}

variable "max_allocated_storage" {
  description = "Maximum storage in GiB for storage autoscaling. Set to 0 to disable autoscaling."
  type        = number
  default     = 100

  validation {
    condition = (
      var.max_allocated_storage == 0 ||
      (
        var.max_allocated_storage >= 20 &&
        floor(var.max_allocated_storage) == var.max_allocated_storage
      )
    )
    error_message = "max_allocated_storage must be 0 or an integer of at least 20 GiB."
  }
}

variable "storage_type" {
  description = "RDS storage type."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.storage_type)
    error_message = "storage_type must be gp2, gp3, io1, or io2."
  }
}

variable "storage_encrypted" {
  description = "Whether to encrypt RDS storage."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Optional KMS key ARN or ID for storage encryption. When null, RDS uses the applicable AWS-managed key."
  type        = string
  default     = null
}

variable "database_name" {
  description = "Optional initial database name. Engine-specific naming rules apply."
  type        = string
  default     = null

  validation {
    condition = var.database_name == null ? true : (
      length(var.database_name) >= 1 &&
      length(var.database_name) <= 63 &&
      can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.database_name))
    )
    error_message = "database_name must start with a letter and contain only letters, numbers, or underscores, with a maximum length of 63 characters."
  }
}

variable "master_username" {
  description = "Master database username. Do not store a password in this variable."
  type        = string
  default     = "dbadmin"

  validation {
    condition = (
      length(var.master_username) >= 1 &&
      length(var.master_username) <= 63 &&
      can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.master_username))
    )
    error_message = "master_username must start with a letter and contain only letters, numbers, or underscores, with a maximum length of 63 characters."
  }
}

variable "manage_master_user_password" {
  description = "This module requires RDS to manage the master password through AWS Secrets Manager."
  type        = bool
  default     = true

  validation {
    condition     = var.manage_master_user_password
    error_message = "This module requires manage_master_user_password = true so credentials are managed securely by AWS Secrets Manager."
  }
}

variable "master_user_secret_kms_key_id" {
  description = "Optional KMS key ID or ARN for the RDS-managed master secret."
  type        = string
  default     = null
}

variable "port" {
  description = "Database listener port. Defaults are engine-specific."
  type        = number
  default     = null

  validation {
    condition = var.port == null ? true : (
      var.port >= 1 &&
      var.port <= 65535 &&
      floor(var.port) == var.port
    )
    error_message = "port must be null or an integer between 1 and 65535."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs for the DB subnet group. Use private subnets in at least two Availability Zones."
  type        = list(string)

  validation {
    condition = (
      length(var.subnet_ids) >= 2 &&
      length(distinct(var.subnet_ids)) == length(var.subnet_ids) &&
      alltrue([for id in var.subnet_ids : length(trimspace(id)) > 0])
    )
    error_message = "subnet_ids must contain at least two unique, non-empty subnet IDs."
  }
}

variable "vpc_id" {
  description = "VPC ID in which the RDS security group will be created."
  type        = string

  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "allowed_security_group_ids" {
  description = "Security group IDs permitted to connect to the database."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for id in var.allowed_security_group_ids : length(trimspace(id)) > 0])
    error_message = "allowed_security_group_ids must not contain empty values."
  }
}

variable "allowed_cidr_blocks" {
  description = "Explicit IPv4 CIDR blocks permitted to connect to the database."
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks :
      can(cidrnetmask(cidr))
    ])
    error_message = "Every allowed_cidr_blocks entry must be a valid IPv4 CIDR block."
  }
}

variable "publicly_accessible" {
  description = "Whether the DB instance receives a public IP address. Keep false for private databases."
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Whether to deploy a Multi-AZ DB instance for high availability."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Automated backup retention in days. Use 0 to disable automated backups."
  type        = number
  default     = 7

  validation {
    condition = (
      var.backup_retention_period >= 0 &&
      var.backup_retention_period <= 35 &&
      floor(var.backup_retention_period) == var.backup_retention_period
    )
    error_message = "backup_retention_period must be an integer between 0 and 35."
  }
}

variable "backup_window" {
  description = "Preferred daily backup window in UTC, formatted as hh24:mi-hh24:mi."
  type        = string
  default     = "18:00-18:30"

  validation {
    condition     = can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]-([01][0-9]|2[0-3]):[0-5][0-9]$", var.backup_window))
    error_message = "backup_window must use the UTC format hh24:mi-hh24:mi."
  }
}

variable "maintenance_window" {
  description = "Preferred weekly maintenance window in UTC."
  type        = string
  default     = "sun:19:00-sun:19:30"

  validation {
    condition     = can(regex("^(mon|tue|wed|thu|fri|sat|sun):([01][0-9]|2[0-3]):[0-5][0-9]-(mon|tue|wed|thu|fri|sat|sun):([01][0-9]|2[0-3]):[0-5][0-9]$", var.maintenance_window))
    error_message = "maintenance_window must use the format ddd:hh24:mi-ddd:hh24:mi."
  }
}

variable "auto_minor_version_upgrade" {
  description = "Whether to allow automatic minor engine version upgrades."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Whether supported modifications are applied immediately instead of during the maintenance window."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for the DB instance."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the DB instance. Keep false for production."
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Optional explicit identifier for the final snapshot."
  type        = string
  default     = null

  validation {
    condition = var.final_snapshot_identifier == null ? true : (
      length(var.final_snapshot_identifier) >= 1 &&
      length(var.final_snapshot_identifier) <= 255 &&
      can(regex("^[A-Za-z][A-Za-z0-9-]*$", var.final_snapshot_identifier)) &&
      !endswith(var.final_snapshot_identifier, "-") &&
      !strcontains(var.final_snapshot_identifier, "--")
    )
    error_message = "final_snapshot_identifier must be 1-255 characters, start with a letter, contain only letters, numbers, or hyphens, and not contain consecutive or trailing hyphens."
  }
}

variable "copy_tags_to_snapshot" {
  description = "Whether to copy DB instance tags to snapshots."
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights where supported."
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention in days, subject to AWS-supported values and engine compatibility."
  type        = number
  default     = 7

  validation {
    condition     = contains([7, 31, 93, 186, 279, 372, 465, 558, 651, 744, 837, 930], var.performance_insights_retention_period)
    error_message = "Use a supported Performance Insights retention period."
  }
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds. Use 0 to disable Enhanced Monitoring."
  type        = number
  default     = 60

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "monitoring_interval must be 0, 1, 5, 10, 15, 30, or 60 seconds."
  }
}

variable "monitoring_role_arn" {
  description = "Optional existing IAM role ARN used by RDS Enhanced Monitoring."
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Database engine log types to export to CloudWatch Logs. Valid values depend on the selected engine."
  type        = set(string)
  default     = []
}

variable "cloudwatch_alarms_enabled" {
  description = "Whether to create basic CloudWatch alarms for CPU utilization and free storage."
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "SNS topic or other supported CloudWatch alarm action ARNs."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for arn in var.alarm_actions : length(trimspace(arn)) > 0])
    error_message = "alarm_actions must not contain empty values."
  }
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers the alarm."
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_alarm_threshold >= 0 && var.cpu_alarm_threshold <= 100
    error_message = "cpu_alarm_threshold must be between 0 and 100."
  }
}

variable "free_storage_alarm_threshold_bytes" {
  description = "Free storage threshold in bytes that triggers the low-storage alarm."
  type        = number
  default     = 5000000000

  validation {
    condition     = var.free_storage_alarm_threshold_bytes >= 0
    error_message = "free_storage_alarm_threshold_bytes must be zero or greater."
  }
}

variable "parameter_group_name" {
  description = "Optional DB parameter group name."
  type        = string
  default     = null
}

variable "option_group_name" {
  description = "Optional DB option group name where supported by the engine."
  type        = string
  default     = null
}

variable "license_model" {
  description = "Optional database license model where applicable."
  type        = string
  default     = null
}

variable "ca_cert_identifier" {
  description = "Optional CA certificate identifier for database TLS."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to RDS resources."
  type        = map(string)
  default     = {}
}

variable "environment_tags" {
  description = "Standard environment tags merged into the resource tags."
  type        = map(string)
  default     = {}
}
