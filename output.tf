# public IP
output "instance_public_ip" {
  description = "Public IP of the SOCKS5 proxy EC2 instance"
  value       = aws_instance.proxy_server.public_ip
}

# public dns
output "instance_public_dns" {
  description = "PublicDNS of the SOCKS5 proxy EC2 instance"
  value       = aws_instance.proxy_server.public_dns
}
