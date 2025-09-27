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

variable "vpc_id" {
  description = "ID of the VPC"
  type = string
}

variable "public_subnets_ids" {
  description = "Public subnets IDs"
  type = list(string)
}

variable "private_subnets_ids" {
  description = "Private subnets IDs"
  type = list(string)
}

variable "key_name" {
  description = "SSH key pair name"
  type = string
}

variable "instance_type" {
  description = "Instance type"
  type = string
  default = "micro"
}
