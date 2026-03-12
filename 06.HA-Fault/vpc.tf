#Cretaing the vpc
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.project}-vpc"
  })
}

#creating the subnets in which each availability zone
resource "aws_subnet" "public-subnet" {
  count                   = length(var.public_cidr)
  depends_on              = [aws_vpc.main]
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr[count.index]
  availability_zone       = var.az[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project}-public-subnet-[count.index]"
  })

}

resource "aws_subnet" "private-subnet" {
  count                   = length(var.private_cidr)
  depends_on              = [aws_vpc.main]
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_cidr[count.index]
  availability_zone       = var.az[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.project}-private-subnet-${count.index + 1}"
  })

}

#creating the internet gateway
resource "aws_internet_gateway" "igw" {
  depends_on = [aws_vpc.main]
  vpc_id     = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project}-igw"
  })
}

#creating public route table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {
    Name = "${var.project}-public-route-table"
  })
}

#creating public route table association
resource "aws_route_table_association" "public-rta" {
  count          = length(var.public_cidr)
  route_table_id = aws_route_table.public_route.id
  subnet_id      = aws_subnet.public-subnet[count.index].id
}

#creating the NAT gateway
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_cidr)
  allocation_id = aws_eip.nat-eip[count.index].id
  subnet_id     = aws_subnet.public-subnet[count.index].id

  tags = merge(var.tags, {
    Name = "${var.project}-nat-${count.index + 1}"
  })
}

#creating the elastic IP for NAT gateway
resource "aws_eip" "nat-eip" {
  count  = length(var.private_cidr)
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project}-eip-${count.index + 1}"
  })
}

#cretaing private route table
resource "aws_route_table" "private_route" {
  count  = length(var.private_cidr)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = merge(var.tags, {
    Name = "${var.project}-private-route-table"
  })
}

#creating private route table assocation
resource "aws_route_table_association" "private-rta" {
  count          = length(var.private_cidr)
  route_table_id = aws_route_table.private_route[count.index].id
  subnet_id      = aws_subnet.private-subnet[count.index].id
}