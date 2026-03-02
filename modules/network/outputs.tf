output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = { for k, subnet in aws_subnet.public : k => subnet.id }
}


output "private_subnet_ids" {
  value = { for k, s in aws_subnet.private : k => s.id }
}

output "nat_gateway_ids" {
  value = { for az, nat in aws_nat_gateway.this : az => nat.id }
}
