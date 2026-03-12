#Mysql configuration

resource "aws_db_subnet_group" "default" {
  count = length(aws_subnet.privatesub-1)
  name       = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.privatesub-1[*].id

  tags = merge(var.tags, {
    Name = "db-subnet"
  })
}

resource "aws_db_instance" "default" {
  count = length(aws_subnet.privatesub-1)
  allocated_storage      = 10
  db_name                = "webappdb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.username
  password               = random_password.db_password.result
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default[count.index].name
  publicly_accessible    = false

  tags = merge(var.tags, {
    Name = "rds"
  })
}