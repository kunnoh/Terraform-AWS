variable "environment" {
  description = "Environment name"
  type = string
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type = string
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default = "10.6.0.0/28"
  type = string
}

variable "availability_zones" { 
  description = "Availability zones"
  type = list(string)
}

variable "public_subnet_cidr" {
  description = "CIDR blocks for public subnets"
  default = ["10.6.9.0/28"]
  type = list(string)
}

variable "private_subnet_cidr" { 
  description = "CIDR blocks for private subnets"
  type = list(string)
}



