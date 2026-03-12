#creating db-subnetr group
resource "aws_db_subnet_group" "rds-subnet" {
  name       = "${var.project}-${var.env}-db-subnet-gropu"
  subnet_ids = aws_subnet.database-subnet[*].id

  tags = {
    Name = "${var.project}-${var.env}-db-subnet-gropu"
  }
}

#creating a parameter group for rds
resource "aws_db_parameter_group" "rds-parameter" {
  name   = "${var.env}-${var.project}-pg15"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  tags = {
    Name = "${var.env}-${var.project}-pg15"
  }
}

#creating postgres managed db
resource "aws_db_instance" "rds-postgres" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "t3.micro"
  username               = var.db-username
  password               = random_password.db-password.result
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet.name
  parameter_group_name   = aws_db_parameter_group.rds-parameter.name
  multi_az               = false

  tags = {
    Name = "${var.env}-${var.project}-rds"
  }
}
