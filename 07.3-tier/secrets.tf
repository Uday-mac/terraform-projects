resource "random_password" "db-password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "db-cred" {
  name                    = "${var.project}-${var.env}-db-cred-${random_id.suffix.hex}"
  description             = "DB credentials"
  recovery_window_in_days = 7

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_secretsmanager_secret_version" "db-password" {
  secret_id = aws_secretsmanager_secret.db-cred.id
  secret_string = jsonencode({
    dbname   = var.db-name
    username = var.db-username
    password = random_password.db-password.result
    port     = var.db-port
    engine   = var.db-engine
    host     = aws_db_instance.rds-postgres.endpoint
  })
}
