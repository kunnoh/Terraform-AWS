variable "aws_region" {
  description = "AWS region for resources"
  type = string
  default = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type = string
  default = "staging"
}

variable "project_name" {
  description = "Project name for resource naming"
  type = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type = string
}

variable "availability_zones" {
  description = "Availability zones"
  type = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
}

variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type = string
}

variable "bucket_prefix" {
  description = "S3 bucket prefix"
  type = string
}

variable "save_private_key_locally" {
  description = "Whether to save private key locally (use with caution)"
  type = bool
  default = false
}
