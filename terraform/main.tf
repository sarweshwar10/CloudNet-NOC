# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.project}-HQ-VPC", Project = var.project }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-HQ-IGW", Project = var.project }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "${var.project}-Public-${count.index + 1}", Project = var.project }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = { Name = "${var.project}-Private-${count.index + 1}", Project = var.project }
}

# DB Subnets
resource "aws_subnet" "db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = { Name = "${var.project}-DB-${count.index + 1}", Project = var.project }
}

# Elastic IP for NAT
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.project}-NAT-EIP", Project = var.project }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.project}-NATGW", Project = var.project }
  depends_on    = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.project}-Public-RT", Project = var.project }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = { Name = "${var.project}-Private-RT", Project = var.project }
}

# DB Route Table
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-DB-RT", Project = var.project }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db" {
  count          = 2
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}

# Security Group - ALB
resource "aws_security_group" "alb" {
  name   = "${var.project}-SG-ALB"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-SG-ALB", Project = var.project }
}

# Security Group - App Server
resource "aws_security_group" "app" {
  name   = "${var.project}-SG-AppServer"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-SG-AppServer", Project = var.project }
}

# Security Group - Database
resource "aws_security_group" "db" {
  name   = "${var.project}-SG-Database"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-SG-Database", Project = var.project }
}