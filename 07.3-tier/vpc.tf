#Creating a custom vpc
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "${var.project}-${var.env}-vpc"
  }
}
#creating app-tier-public-subnet
resource "aws_subnet" "app-tier-subnet" {
  count                   = length(var.app-tier-subnet)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.app-tier-subnet[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-${var.env}-app-tier-subnet-${count.index + 1}"
  }
}


#creatin app-frontend-subnet
resource "aws_subnet" "app-frontend-subnet" {
  count             = length(var.app-frontend-subnet)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app-frontend-subnet[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.project}-${var.env}-app-frontend-subnet-${count.index + 1}"
  }
}

#creating app-backend-subnet
resource "aws_subnet" "app-backend-subnet" {
  count             = length(var.app-backend-subnet)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app-backend-subnet[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.project}-${var.env}-app-backend-subnet-${count.index + 1}"
  }
}

#creating database subnet
resource "aws_subnet" "database-subnet" {
  count             = length(var.app-db-subnet)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app-db-subnet[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.project}-${var.env}-database-subnet-${count.index + 1}"
  }
}

#creating a internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.env}-igw"
  }
}

#creating route table app-fronend-route
resource "aws_route_table" "app-tier-route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-${var.env}-app-frontend-route"
  }
}

#creating route table association for frontend subnet
resource "aws_route_table_association" "app-tier-rta" {
  count          = length(var.app-tier-subnet)
  route_table_id = aws_route_table.app-tier-route.id
  subnet_id      = aws_subnet.app-tier-subnet[count.index].id

}

#creating a single nat gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.app-tier-subnet[0].id

  tags = {
    Name = "${var.project}-${var.env}-nat-gw"
  }
}

#creating elastic ip for nat gateway
resource "aws_eip" "nat-eip" {
  domain = "vpc"
  tags = {
    Name = "${var.project}-${var.env}-nat-eip"
  }
}

#creating private route
resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "${var.project}-${var.env}-private-route"
  }
}

#creating private route table association
resource "aws_route_table_association" "private-rta" {
  count          = length(var.app-backend-subnet)
  route_table_id = aws_route_table.private-route.id
  subnet_id      = aws_subnet.app-backend-subnet[count.index].id
}


