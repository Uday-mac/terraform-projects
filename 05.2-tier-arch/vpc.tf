resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

resource "aws_subnet" "pubsub-1" {
  count                   = length(var.pubsub_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.pubsub_cidr[count.index]
  availability_zone       = var.az
  map_public_ip_on_launch = true
  tags = merge(var.tags,
    {
      Name = "pubsub-${count.index + 1}"
  })
}

resource "aws_subnet" "privatesub-1" {
  count             = length(var.privatesub_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.privatesub_cidr[count.index]
  availability_zone = var.db-az[count.index]
  tags = merge(var.tags,
    {
      Name = "privatesub-${count.index + 1}"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "2-tier-igw"
  })
}

resource "aws_nat_gateway" "ngw" {
  vpc_id    = aws_vpc.main.id
  subnet_id = aws_subnet.pubsub-1[0].id
  tags = merge(var.tags, {
    Name = "2-tier-ngw"
  })
}

resource "aws_route_table" "pubsub-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "2-tier-pubsub-rt"
  })
}

resource "aws_route_table_association" "puubsub-rta" {
  count          = length(var.pubsub_cidr)
  subnet_id      = aws_subnet.pubsub-1[count.index].id
  route_table_id = aws_route_table.pubsub-rt.id
}

resource "aws_route_table" "privatesub-rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags = merge(var.tags, {
    Name = "2-tier-privatesub-rt"
  })
}

resource "aws_route_table_association" "privatesub-rta" {
  count          = length(var.privatesub_cidr)
  subnet_id      = aws_subnet.privatesub-1[count.index].id
  route_table_id = aws_route_table.privatesub-rt.id

}