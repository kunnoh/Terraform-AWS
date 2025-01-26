variable "proxy_ssh_key" {
  description = "socks5 proxy ssh private key"
  type = string
  default = ".terraform/local/proxy_priv_key"
}

variable "ec2_instance_type" {
  description = "type of instance"
  type = string
  default = "t2.micro"
}

variable "ec2_instance_ami" {
  description = "type of instance ami"
  type = string
  default = "ami-064519b8c76274859"
}

variable "ec2_username" {
  description = "server username"
  type = string
  default = "admin"
}

variable "availability_zone" {
  description = "availability region for the proxy server ec2"
  type = string
  default = "us-east-1b"
}
