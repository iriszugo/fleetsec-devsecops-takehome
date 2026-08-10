resource "aws_db_subnet_group" "this" {
  name       = "fleetsec-${var.environment}-db-subnets"
  subnet_ids = aws_subnet.data[*].id

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_parameter_group" "postgres" {
  name   = "fleetsec-${var.environment}-postgres"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "fleetsec-${var.environment}-rds-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "this" {
  identifier = "fleetsec-${var.environment}-postgres"

  engine         = "postgres"
  engine_version = "16"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "fleetsec"
  username = var.db_username

  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.rds.key_id

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  multi_az            = true
  publicly_accessible = false

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.data.id]
  parameter_group_name   = aws_db_parameter_group.postgres.name

  backup_retention_period   = 7
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "fleetsec-${var.environment}-postgres-final"

  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]

  # RDS security hardening
  auto_minor_version_upgrade          = true
  iam_database_authentication_enabled = true
  copy_tags_to_snapshot               = true

  performance_insights_enabled          = true
  performance_insights_kms_key_id       = aws_kms_key.rds.arn
  performance_insights_retention_period = 7

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    DataClass   = "PersonalData"
  }
}
