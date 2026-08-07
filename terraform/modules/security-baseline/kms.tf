
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_base" {
  statement {
    sid    = "EnableAccountAdministration"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]

    resources = [
      aws_kms_key.s3.arn,
      aws_kms_key.rds.arn,
      aws_kms_key.ecs.arn
    ]
  }
}

resource "aws_kms_key" "s3" {
  policy                  = data.aws_iam_policy_document.kms_base.json
  description             = "FleetSec S3 encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "fleetsec-${var.environment}-s3-kms"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/fleetsec-${var.environment}-s3"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_kms_key" "rds" {
  policy                  = data.aws_iam_policy_document.kms_base.json
  description             = "FleetSec RDS encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "fleetsec-${var.environment}-rds-kms"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/fleetsec-${var.environment}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_kms_key" "ecs" {
  policy                  = data.aws_iam_policy_document.kms_base.json
  description             = "FleetSec ECS encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "fleetsec-${var.environment}-ecs-kms"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "ecs" {
  name          = "alias/fleetsec-${var.environment}-ecs"
  target_key_id = aws_kms_key.ecs.key_id
}
