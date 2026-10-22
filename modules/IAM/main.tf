resource "aws_iam_role" "ec2" {
  name = local.role_names.ec2

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = local.role_names.ec2
      Tier = "application"
    }
  )
}

resource "aws_iam_instance_profile" "ec2" {
  name = local.instance_profile_names.ec2
  role = aws_iam_role.ec2.name

  tags = merge(
    local.common_tags,
    {
      Name = local.instance_profile_names.ec2
      Tier = "application"
    }
  )
}