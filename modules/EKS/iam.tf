
data "aws_partition" "current" {}

data "aws_iam_policy_document" "cluster_assume_role" {
  count = local.create_cluster_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  count = local.create_cluster_role ? 1 : 0

  name               = local.cluster_role_name
  description        = "IAM role assumed by the EKS control plane for ${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role[0].json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "cluster" {
  count = local.create_cluster_role ? 1 : 0

  role       = aws_iam_role.cluster[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "node_assume_role" {
  count = local.create_node_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  count = local.create_node_role ? 1 : 0

  name               = local.node_role_name
  description        = "IAM role assumed by EKS worker nodes for ${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role[0].json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  count = local.create_node_role ? 1 : 0

  role       = aws_iam_role.node[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  count = local.create_node_role ? 1 : 0

  role       = aws_iam_role.node[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_readonly" {
  count = local.create_node_role ? 1 : 0

  role       = aws_iam_role.node[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}
