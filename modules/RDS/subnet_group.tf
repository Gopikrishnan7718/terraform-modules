
resource "aws_db_subnet_group" "this" {
  name        = local.subnet_group_name
  description = "Private subnet group for RDS instance ${var.identifier}"

  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = local.subnet_group_name
    }
  )

  lifecycle {
    precondition {
      condition     = length(var.subnet_ids) >= 2
      error_message = "The RDS DB subnet group must contain at least two subnet IDs."
    }
  }
}
