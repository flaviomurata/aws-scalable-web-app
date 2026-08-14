ephemeral "random_password" "database" {
  length  = 24
  special = true

  override_special = "!#$%&*()-_=+[]{}:?"
}

resource "aws_secretsmanager_secret" "database_password" {
  name        = "${var.project_name}-${var.environment}-rds-password"
  description = "Internal RDS password managed by Terraform."

  # Development environment: allows clean destroy/recreate cycles.
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "database_password" {
  secret_id = aws_secretsmanager_secret.database_password.id

  secret_string_wo         = ephemeral.random_password.database.result
  secret_string_wo_version = var.db_password_version
}

ephemeral "aws_secretsmanager_secret_version" "database_password" {
  secret_id = aws_secretsmanager_secret_version.database_password.secret_id
}

resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-${var.environment}"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

resource "aws_security_group" "database" {
  name_prefix = "${var.project_name}-${var.environment}-db-"
  description = "Security group for the RDS database."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-db-sg"
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-mysql"

  engine         = "mysql"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  port     = 3306

  password_wo         = ephemeral.aws_secretsmanager_secret_version.database_password.secret_string
  password_wo_version = var.db_password_version

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]

  availability_zone   = var.availability_zone
  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1
  copy_tags_to_snapshot   = true

  auto_minor_version_upgrade = true

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-${var.environment}-mysql"
  }
}

resource "aws_secretsmanager_secret" "application_database" {
  name        = "Mydbsecret"
  description = "Database credentials consumed by the student records application."

  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "application_database" {
  secret_id = aws_secretsmanager_secret.application_database.id

  secret_string_wo = jsonencode({
    user     = var.db_username
    password = ephemeral.aws_secretsmanager_secret_version.database_password.secret_string
    host     = aws_db_instance.main.address
    db       = var.db_name
  })

  secret_string_wo_version = var.db_password_version
}
