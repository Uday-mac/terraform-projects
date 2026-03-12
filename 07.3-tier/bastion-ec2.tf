#Creating bastion host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ami-id.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  subnet_id              = aws_subnet.app-tier-subnet[0].id

  tags = {
    Name = "Bastion-Host"
  }
}