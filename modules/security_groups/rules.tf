resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each = var.alb_ingress_cidr_blocks

  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = each.value
  from_port   = var.alb_http_port
  to_port     = var.alb_http_port
  ip_protocol = "tcp"

  description = "Allow HTTP traffic from approved IPv4 sources to the Application Load Balancer."
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each = var.alb_ingress_cidr_blocks

  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = each.value
  from_port   = var.alb_https_port
  to_port     = var.alb_https_port
  ip_protocol = "tcp"

  description = "Allow HTTPS traffic from approved IPv4 sources to the Application Load Balancer."
}

resource "aws_vpc_security_group_ingress_rule" "application_from_alb" {
  security_group_id = aws_security_group.application.id

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.application_port
  to_port                      = var.application_port
  ip_protocol                  = "tcp"

  description = "Allow application traffic only from the Application Load Balancer."
}

resource "aws_vpc_security_group_ingress_rule" "database_from_application" {
  security_group_id = aws_security_group.database.id

  referenced_security_group_id = aws_security_group.application.id
  from_port                    = var.database_port
  to_port                      = var.database_port
  ip_protocol                  = "tcp"

  description = "Allow database connections only from application workloads."
}

resource "aws_vpc_security_group_egress_rule" "alb_to_application" {
  security_group_id = aws_security_group.alb.id

  referenced_security_group_id = aws_security_group.application.id
  from_port                    = var.application_port
  to_port                      = var.application_port
  ip_protocol                  = "tcp"

  description = "Allow the Application Load Balancer to reach application workloads."
}

resource "aws_vpc_security_group_egress_rule" "application_to_database" {
  security_group_id = aws_security_group.application.id

  referenced_security_group_id = aws_security_group.database.id
  from_port                    = var.database_port
  to_port                      = var.database_port
  ip_protocol                  = "tcp"

  description = "Allow application workloads to connect to the database."
}


resource "aws_vpc_security_group_egress_rule" "application_https" {
  for_each = var.application_egress_cidr_blocks

  security_group_id = aws_security_group.application.id

  cidr_ipv4   = each.value
  from_port   = var.application_https_port
  to_port     = var.application_https_port
  ip_protocol = "tcp"

  description = "Allow application workloads to access approved external HTTPS endpoints through NAT."
}