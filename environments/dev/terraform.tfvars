aws_region = "ap-south-1"

name = "geonode-dev"

vpc_cidr = "10.0.0.0/16"

availability_zone_count = 3

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24",
  "10.0.13.0/24"
]

database_subnet_cidrs = [
  "10.0.21.0/24",
  "10.0.22.0/24",
  "10.0.23.0/24"
]

enable_dns_support   = true
enable_dns_hostnames = true

enable_nat_gateway   = true
nat_gateway_strategy = "one_per_az"

enable_vpc_flow_logs              = true
flow_logs_retention_days          = 30
flow_log_max_aggregation_interval = 60

common_tags = {
  Environment = "dev"
  Project     = "geonode"
  Owner       = "devops"
}

#Security Groups Variables

alb_ingress_cidr_blocks = [
  "0.0.0.0/0"
]

alb_http_port  = 80
alb_https_port = 443

application_port = 8000
database_port    = 5432

application_egress_cidr_blocks = [
  "0.0.0.0/0"
]

#S3 Bucket Variables

s3_bucket_name = "geonode-dev-artifacts"

s3_force_destroy = false

s3_enable_versioning = true

s3_noncurrent_version_expiration_days = 90

s3_abort_incomplete_multipart_upload_days = 7

#KMS Variables

kms_description = "Customer-managed KMS key for geonode-dev infrastructure encryption"

kms_deletion_window_in_days = 30

kms_enable_key_rotation = true