
resource "aws_security_group" "this" {
  name        = local.security_group_name
  description = "Controls network access to RDS instance ${var.identifier}"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = local.security_group_name
    }
  )

  lifecycle {
    precondition {
      condition = (
        length(var.allowed_security_group_ids) > 0 ||
        length(var.allowed_cidr_blocks) > 0
      )
      error_message = "Provide at least one allowed security group ID or CIDR block to configure database ingress."
    }
  }
}

resource "aws_vpc_security_group_ingress_rule" "from_security_groups" {
  for_each = var.allowed_security_group_ids

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = local.effective_port
  to_port                      = local.effective_port

  description = "Allow database access from approved application security groups"
}

resource "aws_vpc_security_group_ingress_rule" "from_cidr_blocks" {
  for_each = var.allowed_cidr_blocks

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = local.effective_port
  to_port           = local.effective_port

  description = "Allow database access from explicitly approved IPv4 CIDR blocks"
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  description = "Allow outbound traffic from the database security group"
}
