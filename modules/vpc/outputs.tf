output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the VPC."
  value       = aws_internet_gateway.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs of the private application subnets."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "database_subnet_ids" {
  description = "IDs of the database subnets."
  value       = [for subnet in aws_subnet.database : subnet.id]
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways."
  value       = [for nat_gateway in aws_nat_gateway.this : nat_gateway.id]
}

output "public_subnet_ids_by_az" {
  description = "Map of Availability Zone to public subnet ID."
  value = {
    for az, subnet in aws_subnet.public :
    az => subnet.id
  }
}

output "private_subnet_ids_by_az" {
  description = "Map of Availability Zone to private subnet ID."
  value = {
    for az, subnet in aws_subnet.private :
    az => subnet.id
  }
}

output "database_subnet_ids_by_az" {
  description = "Map of Availability Zone to database subnet ID."
  value = {
    for az, subnet in aws_subnet.database :
    az => subnet.id
  }
}

output "nat_gateway_ids_by_az" {
  description = "Map of Availability Zone to NAT Gateway ID."
  value = {
    for az, nat_gateway in aws_nat_gateway.this :
    az => nat_gateway.id
  }
}

output "default_security_group_id" {
  description = "ID of the VPC default security group."
  value       = aws_default_security_group.this.id
}