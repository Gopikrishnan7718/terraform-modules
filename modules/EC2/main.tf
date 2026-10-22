resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile = var.iam_instance_profile_name

  monitoring = var.enable_detailed_monitoring

  user_data = var.user_data

  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  metadata_options {
    http_endpoint = var.metadata_http_endpoint
    http_tokens   = var.metadata_http_tokens
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = var.root_volume_encrypted
    kms_key_id  = var.root_volume_kms_key_id

    delete_on_termination = true
  }

  tags = local.common_tags
}