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

variable "bucket_prefix" {
  description = "S3 bucket prefix"
  type = string
}
