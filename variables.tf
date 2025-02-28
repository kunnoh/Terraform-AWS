variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "ami_id" {
  description = "type of instance AMI ID"
  type = string
  default = "ami-064519b8c76274859"
}

variable "key_name" {
  description = "SSH key name for EC2 instance"
  type = string
  default = ".terraform/local/proxy_privkey"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}



# variable "subnet_A_cidr_ipv4" {
#   default = "10.6.9.0/28"
#   type = string
# }

variable "ec2_username" {
  description = "server username"
  type = string
  default = "admin"
}

# variable "availability_zone" {
#   description = "availability region for the proxy server ec2"
#   type = string
#   default = "us-east-1b"
# }
