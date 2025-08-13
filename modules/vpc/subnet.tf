resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.8.8.0/28"
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