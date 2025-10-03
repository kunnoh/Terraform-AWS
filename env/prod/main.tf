provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project = var.project_name
      ManagedBy = "Terraform"
    }
  }

  endpoints {
    
  }
}

# Security
module "security" {
  source = "../../modules/security"

  environment = var.environment
  project_name = var.project_name
  save_private_key_locally = var.save_private_key_locally
}

# Network
module "network" {
  source = "../../modules/network"

  environment = var.environment
  project_name = var.project_name
  vpc_cidr = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnet_cidr = var.public_subnet_cidrs
  private_subnet_cidr = var.private_subnet_cidrs
}

# Compute
module "compute" {
  source = "../../modules/compute"

  environment = var.environment
  project_name = var.project_name
  vpc_id = module.network.vpc_id
  public_subnets_ids = module.network.public_subnet_ids
  private_subnets_ids = module.network.private_subnet_ids
  instance_type = var.instance_type
  key_name = module.security.key_pair_name
}

# Data
module "data" {
  source = "../../modules/data"

  environment = var.environment
  project_name = var.project_name
  bucket_prefix = var.bucket_prefix
}