output "web_server_ids" {
  description = "IDs of the web servers"
  value       = aws_instance.web[*].id
}

output "web_server_public_ips" {
  description = "Public IP addresses of web servers"
  value       = aws_instance.web[*].public_ip
}

output "web_server_private_ips" {
  description = "Private IP addresses of web servers"
  value       = aws_instance.web[*].private_ip
}

output "app_server_ids" {
  description = "IDs of the app servers"
  value       = aws_instance.app[*].id
}

output "app_server_private_ips" {
  description = "Private IP addresses of app servers"
  value       = aws_instance.app[*].private_ip
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "app_security_group_id" {
  description = "ID of the app security group"
  value       = aws_security_group.app.id
}