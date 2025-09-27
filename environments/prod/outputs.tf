output "key_pair_name" {
  description = "Name of the generated key pair"
  value       = module.security.key_pair_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.network.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.network.private_subnet_ids
}

output "web_server_public_ips" {
  description = "Public IP addresses of web servers"
  value       = module.compute.web_server_public_ips
}

output "app_server_private_ips" {
  description = "Private IP addresses of app servers"
  value       = module.compute.app_server_private_ips
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.data.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.data.s3_bucket_arn
}
