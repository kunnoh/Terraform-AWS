variable "key_name" {
  description = "SSH key name for EC2 instance"
  type = string
  default = ".terraform/local/proxy_privkey"
}