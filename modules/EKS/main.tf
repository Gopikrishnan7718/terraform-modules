
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = local.effective_cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = local.cluster_endpoint_public_access_cidrs

    security_group_ids = sort(tolist(
      setunion(
        var.cluster_security_group_ids,
        toset([aws_security_group.cluster.id])
      )
    ))
  }

  enabled_cluster_log_types = tolist(var.cluster_enabled_log_types)

  dynamic "encryption_config" {
    for_each = var.cluster_encryption_enabled ? [1] : []

    content {
      provider {
        key_arn = var.cluster_encryption_kms_key_arn
      }

      resources = local.cluster_encryption_resources
    }
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  upgrade_policy {
    support_type = var.cluster_upgrade_policy_support_type
  }

  zonal_shift_config {
    enabled = var.cluster_zonal_shift_enabled
  }

  access_config {
    authentication_mode                         = var.cluster_authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.cluster_enabled_cluster_creator_admin_permissions
  }

  tags = local.common_tags

  lifecycle {
    precondition {
      condition = (
        !var.cluster_encryption_enabled ||
        var.cluster_encryption_kms_key_arn != null
      )
      error_message = "Provide cluster_encryption_kms_key_arn when cluster_encryption_enabled is true."
    }

    precondition {
      condition = (
        var.cluster_endpoint_public_access ||
        var.cluster_endpoint_private_access
      )
      error_message = "At least one EKS API endpoint access mode must be enabled."
    }

    precondition {
      condition = (
        !var.cluster_endpoint_public_access ||
        length(var.cluster_endpoint_public_access_cidrs) > 0
      )
      error_message = "When public endpoint access is enabled, provide an explicit CIDR allowlist."
    }

    precondition {
      condition = (
        var.cluster_authentication_mode != "CONFIG_MAP" ||
        length(var.cluster_access_entries) == 0
      )
      error_message = "EKS access entries require API or API_AND_CONFIG_MAP authentication mode."
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_cloudwatch_log_group.cluster
  ]
}
