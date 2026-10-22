
output "cluster_id" {
  description = "EKS cluster name and identifier."
  value       = aws_eks_cluster.this.id
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the Kubernetes API server."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version reported by the EKS cluster."
  value       = aws_eks_cluster.this.version
}

output "cluster_status" {
  description = "Current EKS cluster status."
  value       = aws_eks_cluster.this.status
}

output "cluster_platform_version" {
  description = "EKS platform version."
  value       = aws_eks_cluster.this.platform_version
}

output "cluster_security_group_id" {
  description = "Security group ID managed by EKS for the cluster."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_additional_security_group_id" {
  description = "Additional cluster security group created by this module."
  value       = aws_security_group.cluster.id
}

output "node_additional_security_group_id" {
  description = "Additional worker-node security group created by this module."
  value       = aws_security_group.node.id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN used by the EKS control plane."
  value       = local.effective_cluster_role_arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN used by the managed worker nodes."
  value       = local.effective_node_role_arn
}

output "node_group_arn" {
  description = "ARN of the EKS managed node group."
  value       = aws_eks_node_group.this.arn
}

output "node_group_status" {
  description = "Current managed node group status."
  value       = aws_eks_node_group.this.status
}

output "node_group_resources" {
  description = "Underlying AWS resources associated with the managed node group."
  value       = aws_eks_node_group.this.resources
}

output "cluster_log_group_name" {
  description = "CloudWatch log group name for EKS control-plane logs."
  value       = aws_cloudwatch_log_group.cluster.name
}

output "cluster_log_group_arn" {
  description = "ARN of the CloudWatch log group for EKS control-plane logs."
  value       = aws_cloudwatch_log_group.cluster.arn
}

output "cluster_access_entry_arns" {
  description = "Map of configured EKS access entry ARNs."
  value = {
    for key, entry in aws_eks_access_entry.this :
    key => entry.arn
  }
}

output "cluster_access_policy_associations" {
  description = "Map of configured EKS access policy association IDs."
  value = {
    for key, association in aws_eks_access_policy_association.this :
    key => association.id
  }
}
