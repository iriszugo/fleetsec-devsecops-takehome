resource "aws_secretsmanager_secret" "application" {
  name                    = "fleetsec/${var.environment}/application"
  description             = "FleetSec application security credentials"
  kms_key_id              = aws_kms_key.ecs.arn
  recovery_window_in_days = 30

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    DataClass   = "Credential"
  }
}

resource "aws_secretsmanager_secret_rotation" "application" {
  secret_id           = aws_secretsmanager_secret.application.id
  rotation_lambda_arn = var.secrets_rotation_lambda_arn

  rotation_rules {
    automatically_after_days = 30
  }
}
