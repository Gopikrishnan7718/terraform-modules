locals {
  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    var.availability_zone_count
  )

  common_tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
    }
  )

  subnet_cidrs = concat(
    var.public_subnet_cidrs,
    var.private_subnet_cidrs,
    var.database_subnet_cidrs
  )

  public_subnets = {
    for index, az in local.availability_zones :
    az => {
      cidr = var.public_subnet_cidrs[index]
      name = "${var.name}-public-${az}"
    }
  }

  private_subnets = {
    for index, az in local.availability_zones :
    az => {
      cidr = var.private_subnet_cidrs[index]
      name = "${var.name}-private-${az}"
    }
  }

  database_subnets = {
    for index, az in local.availability_zones :
    az => {
      cidr = var.database_subnet_cidrs[index]
      name = "${var.name}-database-${az}"
    }
  }

  private_route_tables = {
    for az in local.availability_zones :
    az => "${var.name}-private-rt-${az}"
  }

  nat_gateway_azs = (
    var.enable_nat_gateway && var.nat_gateway_strategy == "one_per_az"
    ? local.availability_zones
    : var.enable_nat_gateway && var.nat_gateway_strategy == "single"
    ? [local.availability_zones[0]]
    : []
  )
}