# Internet Gateway
 resource "aws_internet_gateway" "WebServer_InternetGateway" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "WebServer Internet Gateway"
    }
}

# Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "WebServer Public route table"
  }
}

# ipv6 and ipv4 route
resource "aws_route" "publicIGWipv4" {
  route_table_id = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.proxy_IGW.id
}

# resource "aws_route" "publicIGWipv6" {
#   route_table_id = aws_route_table.proxy_route_table.id
#   destination_ipv6_cidr_block = "::/0"
#   gateway_id = aws_internet_gateway.proxy_IGW.id
# }

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
#   assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "WebServer-VPC"
  }
}

# Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/28"
  map_public_ip_on_launch = true
  tags = {
    Name = "WebServer-Subnet"
  }
}

# # Subnet Route Table association
# resource "aws_route_table_association" "subnet_route_association" {
#   subnet_id = aws_subnet.subnet.id
#   route_table_id = aws_route_table.route_table.id
# }

# Security Group
resource "aws_security_group" "WebServer_SecGrp" {
  name = "WebServer Security Group"
  vpc_id = aws_vpc.main.id
  description = "Allow ssh, http and https inbound traffic and all outbound traffic"
  tags = {
    Name = "SSH, HTTP, HTTPS"
  }
}

# Security Group rules
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.WebServer_SecGrp.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.WebServer_SecGrp.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.WebServer_SecGrp.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.WebServer_SecGrp.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # equivalent to all protocols
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

  # # Egress all any ports
  # resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  #   security_group_id = aws_security_group.allow_traffic.id
  #   cidr_ipv6         = "::/0"
  #   ip_protocol       = "-1" # equivalent to all protocols
  # }