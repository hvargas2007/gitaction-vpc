# VPC Produccion Definition 
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-Vpc" }, )
}

# Public Subnet Produccion Definition
resource "aws_subnet" "public" {
  for_each          = { for i, v in var.PublicSubnet : i => v }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.project-tags, { Name = "${each.value.name}" }, )
}

# Private Subnet Produccion Definition
resource "aws_subnet" "private" {
  for_each          = { for i, v in var.PrivateSubnet : i => v }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.project-tags, { Name = "${each.value.name}" }, )
}



# Internet Gateway vpc Produccion
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-Igw" }, )
}

# EIP for NAT Gateway
resource "aws_eip" "nat_gateway" {
  count = 2
  vpc   = true
}

# NAT Gateway 
resource "aws_nat_gateway" "nat_gateway" {
  count         = 2
  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-NatGateway" }, )
}


# Public Route table Definition Produccion
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-PublicRouteTable" }, )
}

# Private Route Table 
resource "aws_route_table" "private_route_table" {
  count      = 2
  vpc_id     = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-PrivateRouteTable-App" }, )
}


# Public Subnets Produccion Association 
resource "aws_route_table_association" "public" {
  count          = length(var.PublicSubnet)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Subnets Produccion Association
resource "aws_route_table_association" "private" {
  count          = length(var.PrivateSubnet)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

# VPC Produccion Flow Logs to CloudWatch
resource "aws_flow_log" "VpcFlowLogProduccion" {
  iam_role_arn    = aws_iam_role.vpc_fl_policy_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}