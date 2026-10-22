variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string

  validation {
    condition = (
      length(var.cluster_name) >= 1 &&
      length(var.cluster_name) <= 100 &&
      can(regex("^[0-9A-Za-z][0-9A-Za-z_-]*$", var.cluster_name))
    )
    error_message = "cluster_name must be 1-100 characters and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version must use the major.minor format, for example 1.34."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS control plane and managed node groups. Use subnets in at least two Availability Zones."
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

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the Kubernetes API endpoint."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the Kubernetes API endpoint. Restrict public access with an allowlist."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "IPv4 CIDR allowlist for public Kubernetes API endpoint access."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.cluster_endpoint_public_access_cidrs :
      can(cidrnetmask(cidr))
    ])
    error_message = "Every cluster_endpoint_public_access_cidrs entry must be a valid IPv4 CIDR block."
  }
}

variable "cluster_service_ipv4_cidr" {
  description = "Optional IPv4 CIDR block for Kubernetes Services."
  type        = string
  default     = null

  validation {
    condition = var.cluster_service_ipv4_cidr == null ? true : (
      can(cidrnetmask(var.cluster_service_ipv4_cidr))
    )
    error_message = "cluster_service_ipv4_cidr must be null or a valid IPv4 CIDR block."
  }
}

variable "cluster_enabled_log_types" {
  description = "EKS control-plane log types to publish to CloudWatch Logs."
  type        = set(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  validation {
    condition = alltrue([
      for log_type in var.cluster_enabled_log_types :
      contains(
        ["api", "audit", "authenticator", "controllerManager", "scheduler"],
        log_type
      )
    ])
    error_message = "cluster_enabled_log_types contains an unsupported EKS control-plane log type."
  }
}

variable "cluster_encryption_enabled" {
  description = "Whether to configure envelope encryption for Kubernetes API data using a KMS key."
  type        = bool
  default     = true
}

variable "cluster_encryption_kms_key_arn" {
  description = "Optional existing KMS key ARN for EKS Kubernetes API encryption. Required when cluster_encryption_enabled is true."
  type        = string
  default     = null

  validation {
    condition = (
      var.cluster_encryption_kms_key_arn == null
      ? true
      : can(regex("^arn:[^:]+:kms:[^:]+:[0-9]{12}:key/.+$", var.cluster_encryption_kms_key_arn))
    )
    error_message = "cluster_encryption_kms_key_arn must be null or a valid KMS key ARN."
  }
}

variable "cluster_role_name" {
  description = "Optional name for the EKS cluster IAM role. A generated name is used when null."
  type        = string
  default     = null
}

variable "cluster_role_arn" {
  description = "Optional existing IAM role ARN for the EKS cluster. When provided, the module will not create the cluster role."
  type        = string
  default     = null
}

variable "node_role_name" {
  description = "Optional name for the managed node group IAM role. A generated name is used when null."
  type        = string
  default     = null
}

variable "node_role_arn" {
  description = "Optional existing IAM role ARN for managed node groups. When provided, the module will not create the node role."
  type        = string
  default     = null
}

variable "node_group_name" {
  description = "Name of the EKS managed node group."
  type        = string
  default     = "default"

  validation {
    condition = (
      length(var.node_group_name) >= 1 &&
      length(var.node_group_name) <= 63 &&
      can(regex("^[0-9A-Za-z][0-9A-Za-z_-]*$", var.node_group_name))
    )
    error_message = "node_group_name must be 1-63 characters and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "node_capacity_type" {
  description = "Capacity type for managed nodes."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_instance_types" {
  description = "EC2 instance types used by the managed node group."
  type        = list(string)
  default     = ["t3.medium"]

  validation {
    condition = (
      length(var.node_instance_types) > 0 &&
      alltrue([for instance_type in var.node_instance_types : length(trimspace(instance_type)) > 0])
    )
    error_message = "node_instance_types must contain at least one non-empty instance type."
  }
}

variable "node_ami_type" {
  description = "AMI type for the managed node group."
  type        = string
  default     = "AL2023_x86_64_STANDARD"

  validation {
    condition = contains([
      "AL2023_x86_64_STANDARD",
      "AL2023_ARM_64_STANDARD",
      "AL2023_x86_64_NVIDIA",
      "AL2023_ARM_64_NVIDIA",
      "AL2_x86_64",
      "AL2_x86_64_GPU",
      "AL2_ARM_64"
    ], var.node_ami_type)
    error_message = "node_ami_type must be a supported EKS managed node group AMI type."
  }
}

variable "node_disk_size" {
  description = "Node root volume size in GiB. Applicable to supported managed node group AMI configurations."
  type        = number
  default     = 50

  validation {
    condition = (
      var.node_disk_size >= 1 &&
      floor(var.node_disk_size) == var.node_disk_size
    )
    error_message = "node_disk_size must be a positive integer."
  }
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2

  validation {
    condition     = var.node_desired_size >= 0 && floor(var.node_desired_size) == var.node_desired_size
    error_message = "node_desired_size must be a non-negative integer."
  }
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 2

  validation {
    condition     = var.node_min_size >= 0 && floor(var.node_min_size) == var.node_min_size
    error_message = "node_min_size must be a non-negative integer."
  }
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 4

  validation {
    condition     = var.node_max_size >= 1 && floor(var.node_max_size) == var.node_max_size
    error_message = "node_max_size must be a positive integer."
  }
}

variable "node_group_update_max_unavailable" {
  description = "Maximum number of unavailable nodes during managed node group updates."
  type        = number
  default     = 1

  validation {
    condition = (
      var.node_group_update_max_unavailable >= 1 &&
      floor(var.node_group_update_max_unavailable) == var.node_group_update_max_unavailable
    )
    error_message = "node_group_update_max_unavailable must be a positive integer."
  }
}

variable "node_labels" {
  description = "Kubernetes labels applied to nodes in the managed node group."
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "Kubernetes taints applied to nodes in the managed node group."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []

  validation {
    condition = alltrue([
      for taint in var.node_taints :
      contains(["NO_SCHEDULE", "NO_EXECUTE", "PREFER_NO_SCHEDULE"], taint.effect)
    ])
    error_message = "Each node taint effect must be NO_SCHEDULE, NO_EXECUTE, or PREFER_NO_SCHEDULE."
  }
}

variable "cluster_security_group_ids" {
  description = "Additional existing security group IDs to associate with the EKS cluster."
  type        = set(string)
  default     = []
}

variable "node_security_group_ids" {
  description = "Additional existing security group IDs to associate with managed node groups."
  type        = set(string)
  default     = []
}

variable "cluster_security_group_name" {
  description = "Optional name for the additional cluster security group created by this module."
  type        = string
  default     = null
}

variable "node_security_group_name" {
  description = "Optional name for the additional node security group created by this module."
  type        = string
  default     = null
}

/*variable "cluster_security_group_additional_rules" {
  description = "Additional ingress rules for the module-created cluster security group."
  type = map(object({
    description              = string
    protocol                 = string
    from_port                = number
    to_port                  = number
    source_security_group_id = optional(string)
    source_cidr_block        = optional(string)
  }))
  default = {}
}

variable "node_security_group_additional_rules" {
  description = "Additional ingress rules for the module-created node security group."
  type = map(object({
    description              = string
    protocol                 = string
    from_port                = number
    to_port                  = number
    source_security_group_id = optional(string)
    source_cidr_block        = optional(string)
  }))
  default = {}
}*/

variable "cluster_log_retention_in_days" {
  description = "CloudWatch Logs retention period for EKS control-plane logs."
  type        = number
  default     = 90

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180,
      365, 400, 545, 731, 1827, 3653
    ], var.cluster_log_retention_in_days)
    error_message = "cluster_log_retention_in_days must be a supported CloudWatch Logs retention value."
  }
}

variable "cluster_log_group_kms_key_id" {
  description = "Optional KMS key ARN for encrypting the EKS control-plane CloudWatch log group."
  type        = string
  default     = null
}

variable "cluster_log_group_name" {
  description = "Optional custom CloudWatch log group name. A name derived from cluster_name is used when null."
  type        = string
  default     = null
}

variable "cluster_log_group_skip_destroy" {
  description = "Whether to retain the control-plane log group when Terraform destroys it."
  type        = bool
  default     = true
}

variable "cluster_enabled_cluster_creator_admin_permissions" {
  description = "Whether to grant the cluster creator administrator access through the EKS access entry mechanism."
  type        = bool
  default     = true
}

variable "cluster_authentication_mode" {
  description = "EKS authentication mode."
  type        = string
  default     = "API_AND_CONFIG_MAP"

  validation {
    condition = contains([
      "API",
      "API_AND_CONFIG_MAP",
      "CONFIG_MAP"
    ], var.cluster_authentication_mode)
    error_message = "cluster_authentication_mode must be API, API_AND_CONFIG_MAP, or CONFIG_MAP."
  }
}

variable "cluster_access_entries" {
  description = "Additional EKS access entries keyed by a unique logical name."
  type = map(object({
    principal_arn     = string
    kubernetes_groups = optional(list(string), [])
    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string), [])
      })
    })), {})
  }))
  default = {}
}

variable "cluster_upgrade_policy_support_type" {
  description = "EKS cluster upgrade policy support type."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXTENDED"], var.cluster_upgrade_policy_support_type)
    error_message = "cluster_upgrade_policy_support_type must be STANDARD or EXTENDED."
  }
}

variable "cluster_zonal_shift_enabled" {
  description = "Whether to enable zonal shift support for the EKS cluster."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to EKS resources."
  type        = map(string)
  default     = {}
}

variable "environment_tags" {
  description = "Standard environment tags merged into resource tags."
  type        = map(string)
  default     = {}
}


variable "cluster_security_group_ingress_rules" {
  description = "Additional ingress rules for the EKS cluster security group."
  type = map(object({
    description              = string
    ip_protocol              = string
    from_port                = number
    to_port                  = number
    source_cidr_block        = optional(string)
    source_security_group_id = optional(string)
  }))
  default = {}
}

variable "node_security_group_ingress_rules" {
  description = "Additional ingress rules for the EKS node security group."
  type = map(object({
    description              = string
    ip_protocol              = string
    from_port                = number
    to_port                  = number
    source_cidr_block        = optional(string)
    source_security_group_id = optional(string)
  }))
  default = {}
}
