#Configuration for ec2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    db_host     = aws_db_instance.rds.endpoint
    db_username = aws_db_instance.rds.username
    db_password = random_password.db_password.result
    db_name     = aws_db_instance.rds.db_name   
  })

  tags = {
    Name = "HelloWorld"
  }
}
