resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = element(var.subnet_availability_zones, count.index)
  vpc_id = aws_vpc.this.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-subnet-public"
  }
}

# connect vpc to internet
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.vpc_name
  }
}

# route traffic from vpc to internet gateway
resource "aws_route_table" "vpc_to_ig" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

# add route table to subnet
resource "aws_route_table_association" "ig_to_pubic_subnet" {
  count = length(var.public_subnets)

  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.vpc_to_ig.id
}
