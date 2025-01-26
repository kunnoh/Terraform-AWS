terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.84.0"
        }
    }
}

# Key pair
resource "tls_private_key" "proxy_ed25519" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "proxy_ssh_keys" {
  key_name = var.proxy_ssh_key
  public_key = tls_private_key.proxy_ed25519.public_key_openssh
}

# Save key on host
resource "local_file" "private_key" {
  content = tls_private_key.proxy_ed25519.private_key_openssh
  filename = var.proxy_ssh_key
}

# VPC
resource "aws_vpc" "proxy_server_vpc" {
  cidr_block = "10.6.9.0/28"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true
  tags = {
    Name = "proxy_vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "proxy_IGW" {
  vpc_id = aws_vpc.proxy_server_vpc.id
}

# Route Table
resource "aws_route_table" "proxy_route_table" {
  vpc_id = aws_vpc.proxy_server_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proxy_IGW.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.proxy_IGW.id
  }

  tags = {
    Name = "SOCKS5 server route table"
  }
}

# Subnet
resource "aws_subnet" "proxy_server_subnet" {
  vpc_id = aws_vpc.proxy_server_vpc.id
  cidr_block = aws_vpc.proxy_server_vpc.cidr_block
  ipv6_cidr_block = aws_vpc.proxy_server_vpc.ipv6_cidr_block
  # availability_zone = var.availability_zone
  tags = {
    Name = "proxy server subnet"
  }
}

# Subnet Route Table association
resource "aws_route_table_association" "subnet_route_association" {
  subnet_id = aws_subnet.proxy_server_subnet.id
  route_table_id = aws_route_table.proxy_route_table.id
}

# Security Group
resource "aws_security_group" "allow_traffic" {
  name = "SOCKS5-SecGrp"
  description = "Allow ssh, http and https inbound traffic and all outbound traffic"
  vpc_id = aws_vpc.proxy_server_vpc.id
  
  tags = {
    Name = "allow ssh, web"
  }

  ingress {
    description = "allow HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group rules
## ipv6 Ingress
# resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
#   security_group_id = aws_security_group.allow_traffic.id
#   cidr_ipv6         = "::/0"
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
#   security_group_id = aws_security_group.allow_traffic.id
#   cidr_ipv6         = "::/0"
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
#   security_group_id = aws_security_group.allow_traffic.id
#   cidr_ipv6         = "::/0"
#   from_port         = 22
#   ip_protocol       = "tcp"
#   to_port           = 22
# }

# ## ipv4 Ingress
# resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
#   security_group_id = aws_security_group.allow_traffic.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
#   security_group_id = aws_security_group.allow_traffic.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
#   security_group_id = aws_security_group.allow_traffic.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 22
#   ip_protocol       = "tcp"
#   to_port           = 22
# }

# # Egress all ports
# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.allow_traffic.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # equivalent to all ports
# }

# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
#   security_group_id = aws_security_group.allow_traffic.id
#   cidr_ipv6         = "::/0"
#   ip_protocol       = "-1" # equivalent to all ports
# }

# ec2 instance
resource "aws_instance" "proxy_server" {
  ami = var.ec2_instance_ami
  instance_type = var.ec2_instance_type
  key_name = aws_key_pair.proxy_ssh_keys.key_name
  associate_public_ip_address = true
  # availability_zone = var.availability_zone

  # Set key permissions
  provisioner "local-exec" {
    command = "chmod 400 ${var.proxy_ssh_key}"
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt update",
  #     "sudo apt upgrade -y",
  #     "sudo apt install nginx -y"
  #   ]

  #   connection {
  #     type        = "ssh"
  #     user        = var.ec2_username
  #     private_key = file("${var.proxy_ssh_key}")
  #     host        = self.public_ip
  #   }
  # }

  tags = {
    Name = "SOCKS5 Server"
  }
}
