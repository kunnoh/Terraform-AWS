terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.84.0"
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
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "Proxy server VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "proxy_IGW" {
  vpc_id = aws_vpc.proxy_server_vpc.id
  tags = {
    Name = "Proxy Internet Gateway"
  }
}

# Route Table
resource "aws_route_table" "proxy_route_table" {
  vpc_id = aws_vpc.proxy_server_vpc.id

  tags = {
    Name = "SOCKS5 Public route table"
  }
}

resource "aws_egress_only_internet_gateway" "ipv6_egress_IGW" {
  vpc_id = aws_vpc.proxy_server_vpc.id

  tags = {
    "Name" = "VPC-IPv6-Egress-Only-IGW"
  }
}

# ipv6 and ipv4 route
resource "aws_route" "publicIGWipv4" {
  route_table_id = aws_route_table.proxy_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.proxy_IGW.id
}

resource "aws_route" "publicIGWipv6" {
  route_table_id = aws_route_table.proxy_route_table.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id = aws_internet_gateway.proxy_IGW.id
}

# Subnet with IPv4 and IPv6
resource "aws_subnet" "proxy_server_subnet" {
  vpc_id = aws_vpc.proxy_server_vpc.id
  availability_zone = var.availability_zone
  cidr_block = cidrsubnet(aws_vpc.proxy_server_vpc.cidr_block, 4, 1)
  ipv6_cidr_block = cidrsubnet(aws_vpc.proxy_server_vpc.ipv6_cidr_block, 8, 0)
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch = true
  tags = {
    Name = "SOCKS5 server subnet A"
  }
}

# Subnet Routing Table association
resource "aws_route_table_association" "subnet_route_association" {
  subnet_id = aws_subnet.proxy_server_subnet.id
  route_table_id = aws_route_table.proxy_route_table.id
}

# Security Group
resource "aws_security_group" "allow_traffic" {
  name = "SOCKS5 Security Group"
  description = "Allow ssh, http and https inbound traffic and all outbound traffic"
  vpc_id = aws_vpc.proxy_server_vpc.id
  tags = {
    Name = "Inbound SSH, HTTP, HTTPS"
  }
}

# Security Group rules
## ipv6 Ingress
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv6         = "::/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv6         = "::/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

## ipv4 Ingress
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_shadowsocks" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8022
  ip_protocol       = "tcp"
  to_port           = 8022
}

resource "aws_vpc_security_group_ingress_rule" "allow_shadowsocks_udp" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8022
  ip_protocol       = "udp"
  to_port           = 8022
}

# Egress all any ports
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # equivalent to all protocols
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # equivalent to all protocols
}

# ec2 instance
resource "aws_instance" "proxy_server" {
  ami = var.ec2_instance_ami
  instance_type = var.ec2_instance_type
  key_name = aws_key_pair.proxy_ssh_keys.key_name
  vpc_security_group_ids = [ aws_security_group.allow_traffic.id ]
  subnet_id = aws_subnet.proxy_server_subnet.id
  associate_public_ip_address = true
  ipv6_address_count = 1
  
  tags = {
    Name = "SOCKS5 Server"
  }

  depends_on = [ aws_internet_gateway.proxy_IGW ]

  # Set key permissions locally
  provisioner "local-exec" {
    command = "chmod 400 ${var.proxy_ssh_key}"
  }

  # Update and install nginx
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /var/log/nginx/kun.zapto.org",
      "sudo mkdir /var/www/kun.zapto.org",
      "sudo chown $USER:$USER /var/www/kun.zapto.org",
      "sudo apt update",
      "sudo apt install nginx certbot shadowsocks-libev -y",
      "certbot certonly --standalone --preferred-challenges http -d kun.zapto.org",
      "sudo cp -f ./nginx/nginx.conf /etc/nginx/nginx.conf",
      "sudo cp ./nginx/site/kun.zapto.org.conf /etc/nginx/sites-available/kun.zapto.org.conf",
      "sudo ln -s /etc/nginx/sites-available/kun.zapto.org.conf /etc/nginx/sites-enabled/kun.zapto.org.conf",
      "sudo cp ./nginx/site/index.html /var/www/kun.zapto.org/index.html",
      "sudo systemctl restart nginx"
    ]

    connection {
      type        = "ssh"
      user        = var.ec2_username
      private_key = file("${var.proxy_ssh_key}")
      host        = self.public_ip
    }
  }

  timeouts {
    create = "2m"
    update = "3m"
    delete = "5m"
  }
}
