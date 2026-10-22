#VPC Module

module "vpc" {
  source = "../../modules/vpc"

  name = var.name

  vpc_cidr = var.vpc_cidr

  availability_zone_count = var.availability_zone_count

  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs

  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  enable_nat_gateway   = var.enable_nat_gateway
  nat_gateway_strategy = var.nat_gateway_strategy

  enable_vpc_flow_logs              = var.enable_vpc_flow_logs
  flow_logs_retention_days          = var.flow_logs_retention_days
  flow_log_max_aggregation_interval = var.flow_log_max_aggregation_interval

  common_tags = var.common_tags
}

#Security Groups Module

module "security_groups" {
  source = "../../modules/security_groups"

  name   = var.name
  vpc_id = module.vpc.vpc_id

  alb_ingress_cidr_blocks        = var.alb_ingress_cidr_blocks
  alb_http_port                  = var.alb_http_port
  alb_https_port                 = var.alb_https_port
  application_port               = var.application_port
  application_egress_cidr_blocks = var.application_egress_cidr_blocks
  database_port                  = var.database_port

  common_tags = var.common_tags
}

#S3 Bucket Module

module "s3" {
  source = "../../modules/S3"

  name = var.s3_bucket_name

  force_destroy = var.s3_force_destroy

  enable_versioning = var.s3_enable_versioning

  noncurrent_version_expiration_days = var.s3_noncurrent_version_expiration_days

  abort_incomplete_multipart_upload_days = var.s3_abort_incomplete_multipart_upload_days

  common_tags = var.common_tags
}

#IAM Module

module "iam" {
  source = "../../modules/IAM"

  name = var.name

  artifact_bucket_arn = module.s3.bucket_arn

  common_tags = var.common_tags
}

#KMS Module

module "KMS" {
  source = "../../modules/KMS"

  name = var.name

  description = var.kms_description

  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation

  common_tags = var.common_tags
}

