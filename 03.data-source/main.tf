data "aws_vpc" "vpc_name" {
  filter {
    name   = "tag:Name"
    values = ["Default-vpc"]
  }
}

data "aws_subnet" "shared" {
  filter {
    name   = "tag:Name"
    values = ["Default-pub-sub1"]
  }
  vpc_id = data.aws_vpc.vpc_name.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "test" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = data.aws_subnet.shared.id

  tags = {
    Name = "test-instance"
  }
}

