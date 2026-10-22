resource "aws_security_group" "alb" {
  name        = local.security_group_names.alb
  description = "Security group for the Application Load Balancer."
  vpc_id      = var.vpc_id

  ingress = []
  egress  = []

  tags = merge(
    local.common_tags,
    {
      Name = local.security_group_names.alb
      Tier = "load-balancer"
    }
  )
}

resource "aws_security_group" "application" {
  name        = local.security_group_names.application
  description = "Security group for application workloads."
  vpc_id      = var.vpc_id

  ingress = []
  egress  = []

  tags = merge(
    local.common_tags,
    {
      Name = local.security_group_names.application
      Tier = "application"
    }
  )
}

resource "aws_security_group" "database" {
  name        = local.security_group_names.database
  description = "Security group for database workloads."
  vpc_id      = var.vpc_id

  ingress = []
  egress  = []

  tags = merge(
    local.common_tags,
    {
      Name = local.security_group_names.database
      Tier = "database"
    }
  )
}