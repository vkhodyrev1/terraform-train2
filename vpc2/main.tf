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

resource "aws_network_acl" "main" {
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

  tags = {
    Name = "main"
  }
}