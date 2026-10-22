locals {
  common_tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
    }
  )

  role_names = {
    ec2 = "${var.name}-ec2-role"
  }

  instance_profile_names = {
    ec2 = "${var.name}-ec2-instance-profile"
  }
}