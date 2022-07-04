###
# Public Security Group
##

resource "aws_security_group" "public" {
  name        = "terraform-train2-${var.infra_env}-public-sg"
  description = "Public internet access"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(var.tags_name, {
    Name        = "terraform-train2-${var.infra_env}-vpc"
    Environment = var.infra_env
  })
}

resource "aws_security_group_rule" "public_e" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public.id
}
  