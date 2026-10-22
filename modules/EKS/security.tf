
# Retrieve every subnet supplied to the EKS module.
# This allows the module to validate that all subnets belong to one VPC.
data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)

  id = each.value
}

locals {
  eks_subnet_vpc_ids = toset([
    for subnet in data.aws_subnet.selected : subnet.vpc_id
  ])
}

# Additional security group for the EKS control plane.
resource "aws_security_group" "cluster" {
  name        = local.cluster_security_group_name
  description = "Additional security group for EKS cluster ${var.cluster_name}"
  vpc_id      = data.aws_subnet.selected[var.subnet_ids[0]].vpc_id

  tags = merge(local.common_tags, {
    Name = local.cluster_security_group_name
  })

  lifecycle {
    precondition {
      condition     = length(var.subnet_ids) >= 2
      error_message = "At least two subnet IDs are required for the EKS cluster."
    }

    precondition {
      condition     = length(local.eks_subnet_vpc_ids) == 1
      error_message = "All subnet_ids supplied to the EKS module must belong to the same VPC."
    }
  }
}

# Additional security group for EKS worker nodes.
resource "aws_security_group" "node" {
  name        = local.node_security_group_name
  description = "Additional security group for EKS worker nodes ${var.cluster_name}"
  vpc_id      = data.aws_subnet.selected[var.subnet_ids[0]].vpc_id

  tags = merge(local.common_tags, {
    Name = local.node_security_group_name
  })

  lifecycle {
    precondition {
      condition     = length(local.eks_subnet_vpc_ids) == 1
      error_message = "All subnet_ids supplied to the EKS module must belong to the same VPC."
    }
  }
}

# Configurable ingress rules for the cluster security group.
resource "aws_vpc_security_group_ingress_rule" "cluster_custom" {
  for_each = var.cluster_security_group_ingress_rules

  security_group_id = aws_security_group.cluster.id
  description       = each.value.description
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port

  cidr_ipv4 = each.value.source_cidr_block
  referenced_security_group_id = (
    each.value.source_security_group_id
  )

  lifecycle {
    precondition {
      condition = (
        (each.value.source_security_group_id != null) !=
        (each.value.source_cidr_block != null)
      )
      error_message = "Each cluster ingress rule must specify exactly one source: source_security_group_id or source_cidr_block."
    }
  }
}

# Configurable ingress rules for the node security group.
resource "aws_vpc_security_group_ingress_rule" "node_custom" {
  for_each = var.node_security_group_ingress_rules

  security_group_id = aws_security_group.node.id
  description       = each.value.description
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port

  cidr_ipv4 = each.value.source_cidr_block
  referenced_security_group_id = (
    each.value.source_security_group_id
  )

  lifecycle {
    precondition {
      condition = (
        (each.value.source_security_group_id != null) !=
        (each.value.source_cidr_block != null)
      )
      error_message = "Each node ingress rule must specify exactly one source: source_security_group_id or source_cidr_block."
    }
  }
}

# Allow the module's additional cluster security group to reach the node kubelet.
resource "aws_vpc_security_group_ingress_rule" "node_from_cluster" {
  security_group_id            = aws_security_group.node.id
  referenced_security_group_id = aws_security_group.cluster.id

  description = "Allow additional cluster security group to reach the node kubelet"
  ip_protocol = "tcp"
  from_port   = 10250
  to_port     = 10250
}

# Allow the EKS-managed cluster security group to reach the node kubelet.
resource "aws_vpc_security_group_ingress_rule" "node_from_eks_cluster" {
  security_group_id = aws_security_group.node.id
  referenced_security_group_id = (
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  )

  description = "Allow EKS-managed cluster security group to reach the node kubelet"
  ip_protocol = "tcp"
  from_port   = 10250
  to_port     = 10250
}

# Allow communication between nodes.
resource "aws_vpc_security_group_ingress_rule" "node_self" {
  security_group_id            = aws_security_group.node.id
  referenced_security_group_id = aws_security_group.node.id

  description = "Allow communication between EKS worker nodes"
  ip_protocol = "-1"
}

# Allow worker nodes to reach the cluster endpoint over HTTPS.
resource "aws_vpc_security_group_ingress_rule" "cluster_from_node" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.node.id

  description = "Allow worker nodes to reach the EKS cluster endpoint"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

# Allow outbound IPv4 traffic from the cluster security group.
resource "aws_vpc_security_group_egress_rule" "cluster_all_ipv4" {
  security_group_id = aws_security_group.cluster.id
  description       = "Allow outbound IPv4 traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Allow outbound IPv4 traffic from the node security group.
resource "aws_vpc_security_group_egress_rule" "node_all_ipv4" {
  security_group_id = aws_security_group.node.id
  description       = "Allow outbound IPv4 traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
