locals {
  common_tags = merge(
    var.tags,
    var.environment_tags,
    {
      ManagedBy   = "Terraform"
      Name        = var.cluster_name
      Environment = lookup(var.environment_tags, "Environment", "unspecified")
    }
  )

  cluster_role_name = (
    var.cluster_role_name != null
    ? var.cluster_role_name
    : "${var.cluster_name}-cluster-role"
  )

  node_role_name = (
    var.node_role_name != null
    ? var.node_role_name
    : "${var.cluster_name}-node-role"
  )

  cluster_security_group_name = (
    var.cluster_security_group_name != null
    ? var.cluster_security_group_name
    : "${var.cluster_name}-cluster-sg"
  )

  node_security_group_name = (
    var.node_security_group_name != null
    ? var.node_security_group_name
    : "${var.cluster_name}-node-sg"
  )

  cluster_log_group_name = (
    var.cluster_log_group_name != null
    ? var.cluster_log_group_name
    : "/aws/eks/${var.cluster_name}/cluster"
  )

  cluster_encryption_resources = (
    var.cluster_encryption_enabled
    ? ["secrets"]
    : []
  )

  create_cluster_role = var.cluster_role_arn == null
  create_node_role    = var.node_role_arn == null

  effective_cluster_role_arn = (
    var.cluster_role_arn != null
    ? var.cluster_role_arn
    : try(aws_iam_role.cluster[0].arn, null)
  )

  effective_node_role_arn = (
    var.node_role_arn != null
    ? var.node_role_arn
    : try(aws_iam_role.node[0].arn, null)
  )

  cluster_endpoint_public_access_cidrs = (
    var.cluster_endpoint_public_access
    ? var.cluster_endpoint_public_access_cidrs
    : []
  )
}