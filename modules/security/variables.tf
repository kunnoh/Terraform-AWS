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
  type        = string
}

variable "key_name" {
  description = "SSH key name for EC2 instance"
  type = string
  default = ".terraform/local/privkey"
}

variable "save_private_key_locally" {
  description = "Save private key locally"
  type = bool
  default = false
}
