resource "aws_launch_template" "this" {
  name        = local.launch_template_name
  description = "Reusable EC2 launch template for ${var.name}."

  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  update_default_version = var.update_default_version

  user_data = var.user_data == null ? null : base64encode(var.user_data)

  metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  block_device_mappings {
    device_name = var.root_device_name

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      encrypted             = var.root_volume_encrypted
      kms_key_id            = var.root_volume_kms_key_id
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name      = "${var.name}-instance"
        ManagedBy = "Terraform"
        Tier      = "compute"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.common_tags,
      {
        Name      = "${var.name}-root-volume"
        ManagedBy = "Terraform"
        Tier      = "compute"
      }
    )
  }

  tags = local.common_tags
}