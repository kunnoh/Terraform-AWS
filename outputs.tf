output "WebServer_public_ip" {
  value = module.compute.instance_public_ip
}

output "WebServer_public_DNS" {
  value = module.compute.instance_public_dns
}
