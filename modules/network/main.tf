# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "${var.project_name} - ${var.environment} - VPC"
  }
}

# Internet Gateway
 resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.project_name} - ${var.environment} - IGW"
  }
}

# Public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    Type = "public"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
    Type = "private"
  }
}

# Elastic IPs for NAT Gateways
# resource "aws_eip" "nat" {
#   count = length(var.public_subnet_cidr)

#   domain = "vpc"
#   depends_on = [aws_internet_gateway.main]

#   tags = {
#     Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
#   }
# }

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = length(var.public_subnet_cidr)
  # allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-${var.environment}-NAT-GW-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-route"
  }
}

# Private Route Tables
resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-route-${count.index + 1}"
  }
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}






# # ipv6 and ipv4 route
# resource "aws_route" "publicIGWipv4" {
#   route_table_id = aws_route_table.route_table.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id = aws_internet_gateway.proxy_IGW.id
# }

# # resource "aws_route" "publicIGWipv6" {
# #   route_table_id = aws_route_table.proxy_route_table.id
# #   destination_ipv6_cidr_block = "::/0"
# #   gateway_id = aws_internet_gateway.proxy_IGW.id
# # }
