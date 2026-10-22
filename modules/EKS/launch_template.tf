
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.cluster_name}-node-"
  description = "Launch template for EKS managed node group ${var.node_group_name}."

  # The EKS managed node group selects and manages the AMI.
  # Do not specify image_id or iam_instance_profile here.

  vpc_security_group_ids = sort(tolist(
    setunion(
      var.node_security_group_ids,
      toset([aws_security_group.node.id])
    )
  ))

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.cluster_name}-${var.node_group_name}-node"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.cluster_name}-${var.node_group_name}-root-volume"
      }
    )
  }

  tags = local.common_tags
}
