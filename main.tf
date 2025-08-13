# {
  # resource "aws_egress_only_internet_gateway" "ipv6_egress_IGW" {
  #   vpc_id = aws_vpc.proxy_server_vpc.id

  #   tags = {
  #     "Name" = "VPC-IPv6-Egress-Only-IGW"
  #   }
  # }

  # # Subnet with IPv4 and IPv6
  # resource "aws_subnet" "proxy_server_subnet" {
  #   vpc_id = aws_vpc.proxy_server_vpc.id
  #   availability_zone = var.availability_zone
  #   cidr_block = cidrsubnet(aws_vpc.proxy_server_vpc.cidr_block, 4, 1)
  #   ipv6_cidr_block = cidrsubnet(aws_vpc.proxy_server_vpc.ipv6_cidr_block, 8, 0)
  #   assign_ipv6_address_on_creation = true
  #   map_public_ip_on_launch = true
  #   tags = {
  #     Name = "SOCKS5 server subnet A"
  #   }
  # }

  # # ec2 instance
  # resource "aws_instance" "proxy_server" {
  #   ami = var.ami_id
  #   instance_type = var.instance_type
  #   key_name = aws_key_pair.proxy_ssh_keys.key_name
  #   vpc_security_group_ids = [ aws_security_group.allow_traffic.id ]
  #   subnet_id = aws_subnet.proxy_server_subnet.id
  #   associate_public_ip_address = true
  #   ipv6_address_count = 1
  #   # security_groups = [ aw ]
  #   tags = {
  #     Name = "SOCKS5 Server"
  #   }

  #   depends_on = [ aws_internet_gateway.proxy_IGW ]

  #   # Set key permissions locally
  #   provisioner "local-exec" {
  #     command = "chmod 400 ${var.key_name}"
  #   }

  #   # Update and install nginx
  #   provisioner "remote-exec" {
  #     inline = [
  #       "sudo apt update && sudo upgrade -y",
  #       "sudo apt install nginx rsync iptables shadowsocks-libev -y",
  #     ]

  #     connection {
  #       type        = "ssh"
  #       user        = var.ec2_username
  #       private_key = file("${var.key_name}")
  #       host        = self.public_ip
  #     }
  #   }

  #   timeouts {
  #     create = "2m"
  #     update = "2m"
  #     delete = "3m"
  #   }
  # }
# }



module "network" {
  source = "./modules/network"
}

module "compute" {
  source            = "./modules/compute"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  key_name         = var.key_name
  subnet_id        = module.network.subnet_id
  security_group_id = module.network.security_group_id
}
