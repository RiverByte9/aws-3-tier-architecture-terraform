resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-vpc" })
  )
}

## Define Public and Private Subnets
resource "aws_subnet" "public_subnet" {
  cidr_block              = var.subnet_cidr_list[0]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-subnet" })
  )
}

resource "aws_subnet" "private_a" {
  cidr_block        = var.private_subnet_cidr_a
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-a" })
  )
}

resource "aws_subnet" "private_b" {
  cidr_block        = var.private_subnet_cidr_b
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}b"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-b" })
  )
}

## Define Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-igw" })
  )
}

## Define Elastic IP for NAT Gateway
resource "aws_eip" "public" {
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-eip" })
  )
}

## Define NAT Gateway for Private Subnets
resource "aws_nat_gateway" "public" {
  allocation_id = aws_eip.public.id
  subnet_id     = aws_subnet.public_subnet.id # Fixed reference

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-nat" })
  )
}

## Define Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-route-table" })
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-route-table" })
  )
}

## Associate Subnets with Route Tables
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

## Define Routes
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id # ✅ Fixed Reference
}

resource "aws_route" "private-internet_out" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.public.id
  destination_cidr_block = "0.0.0.0/0"
}
