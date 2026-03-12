resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.project}-${var.environment}-db_password-${random_id.suffix.hex}"
  description = "Database password for ${var.project}"

  tags = merge(var.tags, {
    Name = "db-password"
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode(
    {
      password = random_password.db_password.result
      username = var.username
      host     = ""
      engine   = "mysql"
    }
  )
}