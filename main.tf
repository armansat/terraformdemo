terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
# Local variables
locals {
  public_cidr = ["10.0.0.0/24", "10.0.1.0/24"]
  private_cidr = ["10.0.2.0/24", "10.0.3.0/24"]
}
# Create a Public Subnet
resource "aws_subnet" "public" {
    count = 2
  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_cidr[count.index]

  tags = {
    Name = "public${count.index}"
  }
}
# Create a Private Subnet
resource "aws_subnet" "private" {
    count = 2
  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_cidr[count.index]

  tags = {
    Name = "private${count.index}"
  }
}
#Create Route Table Association Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
#Create Route Table Association Private Subnet
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
# Create AWS Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
# Create AWS Elactic IP (Public IP)
resource "aws_eip" "nat" {
    count = 2

  vpc      = true
}
# Create AWS NAT Gateway
resource "aws_nat_gateway" "main" {
    count=2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "main"
  }
}
  # Create AWS Public Route Table 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}
  # Create AWS Private Route Table 
resource "aws_route_table" "private" {
    count = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "private${count.index}"
  }
}
# Create an AWS Security Group
resource "aws_security_group" "main" {
  name        = "main"
  description = "Allow traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allow internal traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["10.0.0.0/16"]
  }
ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["109.239.41.146/32"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Main"
  }
}
