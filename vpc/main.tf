resource "aws_vpc" "main" {
  cidr_block           = var.vpc.cidr_block
  instance_tenancy     = var.vpc.tenancy
  enable_dns_hostnames = var.vpc.enable_dns_hostnames
  enable_dns_support   = var.vpc.enable_dns_support

  tags = {
    Name = "${var.vpc.name}"
  }
}

resource "aws_subnet" "private" {
  for_each = var.vpc.private_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "private-${each.value.availability_zone}"
  }
}

resource "aws_subnet" "public" {
  for_each = var.vpc.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.value.availability_zone}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-igw"
  }
}

# we won't be using the main route table.
# create a private route table. This will be associated with the private subnet
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-private-route-table"
  }
}

# create a public route table. This will be associated with the public subnet
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-public-route-table"
  }
}

# associate the private route table with the private subnet
resource "aws_route_table_association" "private-rt" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private-rt.id
}

# associate the public route table with the public subnet
resource "aws_route_table_association" "public-rt" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public-rt.id
}

# aws elastic ip address will be used by the nat gateway
resource "aws_eip" "natgw" {

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-natgw-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id     = aws_eip.natgw.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public[keys(var.vpc.public_subnets)[0]].id # use the first public subnet provided to host the nat gw
  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-natgw"
  }

  depends_on = [
    aws_internet_gateway.igw,
    aws_eip.natgw
  ]
}

# add a default route in the private route table, which will sends traffic to the NAT gateway.
# the private route table is attached to all the private subnets created in this solution
resource "aws_route" "private_rt_default_route_to_ng" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id

  depends_on = [
    aws_route_table.private-rt,
    aws_nat_gateway.main
  ]
}
