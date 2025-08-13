 resource "aws_internet_gateway" "WebServer_InternetGateway" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "WebServer Internet Gateway"
    }
}