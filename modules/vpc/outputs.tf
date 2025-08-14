# Output the VPC ID and CIDR block for reference
output "vpc_id" {
  description = "ID of the datacenter VPC"
  value       = aws_vpc.datacenter_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the datacenter VPC"
  value       = aws_vpc.datacenter_vpc.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.datacenter_igw.id
}

