# public IP
output "instance_public_ipv4" {
  description = "Public IPv4 for the SOCKS5 proxy EC2"
  value       = aws_instance.proxy_server.public_ip
}

# public dns
output "instance_public_dns" {
  description = "PublicDNS of the SOCKS5 proxy EC2 instance"
  value       = aws_instance.proxy_server.public_dns
}
