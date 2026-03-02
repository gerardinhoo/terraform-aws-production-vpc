resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-${each.key}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

moved {
  from = aws_subnet.public
  to   = aws_subnet.public["subnet-a"]
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.name}-private-${each.key}"
  }
}

locals {
  az_to_public_subnet_id = {
    for k, s in aws_subnet.public : s.availability_zone => s.id
  }

  private_azs = toset([
    for k, s in aws_subnet.private : s.availability_zone
  ])
}

resource "aws_eip" "nat" {
  for_each = local.private_azs
  domain   = "vpc"

  tags = {
    Name = "${var.name}-nat-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "this" {
  for_each = local.private_azs

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = local.az_to_public_subnet_id[each.key] # NAT must be in PUBLIC subnet
  depends_on    = [aws_internet_gateway.this]

  tags = {
    Name = "${var.name}-nat-${each.key}"
  }
}

resource "aws_route_table" "private" {
  for_each = local.private_azs

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = {
    Name = "${var.name}-private-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.value.availability_zone].id
}
