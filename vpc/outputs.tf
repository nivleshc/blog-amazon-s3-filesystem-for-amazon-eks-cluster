output "private_subnets" {
  description = "A list of all private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnets" {
  description = "A list of all pubilc subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "nat_gw_eip" {
  description = "The public ip address of the elastic ip attached to the NAT Gateway"
  value       = aws_eip.natgw.public_ip
}
