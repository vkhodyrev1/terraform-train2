# Create a VPC for the region associated with the AZ
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = merge(var.tags_name, {
    Name        = "terraform-train2-${var.infra_env}-vpc"
    Environment = var.infra_env
  })
}

# Create 1 public subnets for each AZ within the regional VPC
resource "aws_subnet" "public" {
  for_each = var.public_subnet_numbers

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key

  # 2,048 IP addresses each
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = merge(var.tags_name, {
    Name        = "terraform-train2-${var.infra_env}-vpc"
    Environment = var.infra_env
  })
}

# Create 1 private subnets for each AZ within the regional VPC
resource "aws_subnet" "private" {
  for_each = var.private_subnet_numbers

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key

  # 2,048 IP addresses each
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = merge(var.tags_name, {
    Name        = "terraform-train2-${var.infra_env}-vpc"
    Environment = var.infra_env
  })
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.tags_name, {
    Name        = "terraform-train2-${var.infra_env}-private-acl"
    Environment = var.infra_env
  })
}

resource "aws_route_table_association" "private" {
  for_each  = aws_subnet.private
  subnet_id = aws_subnet.private[each.key].id

  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "public" {
  for_each  = aws_subnet.public
  subnet_id = aws_subnet.public[each.key].id

  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.vpc_cidr
    # gateway_id = aws_internet_gateway.example.id
  }

  tags = merge(var.tags_name, {
    Name        = "terraform-train2-${var.infra_env}-route-private"
    Environment = var.infra_env
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags_name, {
    Name        = "terraform-train2-${var.infra_env}-route-public"
    Environment = var.infra_env
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags_name, {
    Name        = "terraform-train2-${var.infra_env}-igw"
    Environment = var.infra_env
  })
}