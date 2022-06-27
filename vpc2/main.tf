# Create a VPC for the region associated with the AZ
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    # Project            = "terraform-train2.io"
    # ManagedBy          = "terraform"
    Name               = "terraform-train2-${var.infra_env}-vpc"
    Environment        = var.infra_env
    "${var.tags_name}" = "${var.tags_value}"
  }
}

# Create 1 public subnets for each AZ within the regional VPC
resource "aws_subnet" "public" {
  for_each = var.public_subnet_numbers

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key

  # 2,048 IP addresses each
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = {
    # Project     = "terraform-train2.io"
    # Role        = "public"
    # ManagedBy   = "terraform"
    Name               = "terraform-train2-${var.infra_env}-public-subnet"
    Environment        = var.infra_env
    Subnet             = "${each.key}-${each.value}"
    "${var.tags_name}" = "${var.tags_value}"
  }
}

# Create 1 private subnets for each AZ within the regional VPC
resource "aws_subnet" "private" {
  for_each = var.private_subnet_numbers

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key

  # 2,048 IP addresses each
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = {
    # Project     = "terraform-train2.io"
    # Role        = "private"
    # ManagedBy   = "terraform"
    Name               = "terraform-train2-${var.infra_env}-private-subnet"
    Environment        = var.infra_env
    Subnet             = "${each.key}-${each.value}"
    "${var.tags_name}" = "${var.tags_value}"
  }
}