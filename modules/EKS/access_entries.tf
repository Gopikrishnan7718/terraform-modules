
resource "aws_eks_access_entry" "this" {
  for_each = var.cluster_access_entries

  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = each.value.kubernetes_groups

  type = "STANDARD"

  tags = local.common_tags

  lifecycle {
    precondition {
      condition     = can(regex("^arn:[^:]+:iam::[0-9]{12}:(role|user)/.+$", each.value.principal_arn))
      error_message = "Each access entry principal_arn must be an IAM role or user ARN."
    }
  }
}

resource "aws_eks_access_policy_association" "this" {
  for_each = {
    for item in flatten([
      for entry_key, entry in var.cluster_access_entries : [
        for policy_key, association in entry.policy_associations : {
          key        = "${entry_key}/${policy_key}"
          entry_key  = entry_key
          policy_arn = association.policy_arn
          scope_type = association.access_scope.type
          namespaces = association.access_scope.namespaces
        }
      ]
    ]) : item.key => item
  }

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.cluster_access_entries[each.value.entry_key].principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.scope_type
    namespaces = each.value.scope_type == "namespace" ? each.value.namespaces : null
  }

  depends_on = [
    aws_eks_access_entry.this
  ]

  lifecycle {
    precondition {
      condition     = contains(["cluster", "namespace"], each.value.scope_type)
      error_message = "EKS access policy scope type must be cluster or namespace."
    }

    precondition {
      condition = (
        each.value.scope_type != "namespace" ||
        length(each.value.namespaces) > 0
      )
      error_message = "Namespace-scoped EKS access policies must specify at least one namespace."
    }
  }
}
