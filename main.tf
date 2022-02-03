# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
# Local variables
locals {
  public_cidr  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_cidr = ["10.0.2.0/24", "10.0.3.0/24"]
}
# Create a Public Subnet
resource "aws_subnet" "public" {
  count      = length(local.public_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_cidr[count.index]

  tags = {
    Name = "public${count.index}"
  }
}
# Create a Private Subnet
resource "aws_subnet" "private" {
  count      = length(local.private_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_cidr[count.index]

  tags = {
    Name = "private${count.index}"
  }
}
#Create Route Table Association Public Subnet
resource "aws_route_table_association" "public" {
  count          = length(local.public_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
#Create Route Table Association Private Subnet
resource "aws_route_table_association" "private" {
  count          = length(local.private_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
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
  count = length(local.public_cidr)

  vpc = true
}
# Create AWS NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = length(local.public_cidr)
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
  count  = length(local.private_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
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
    description = "Allow internal traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["109.239.42.216/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Main"
  }
}
output "a" {
  value = local.public_cidr
}

output "b" {
  value = length(local.public_cidr)
}