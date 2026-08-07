resource "aws_sns_topic" "security_alerts" {
  name              = "fleetsec-${var.environment}-security-alerts"
  kms_master_key_id = aws_kms_key.s3.id

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "soc_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.soc_email
}

resource "aws_guardduty_detector" "this" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }

    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_securityhub_account" "this" {}

resource "aws_cloudtrail" "this" {
  name                          = "fleetsec-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.s3.arn
  sns_topic_name                = aws_sns_topic.security_alerts.name
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_logs.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [
    aws_s3_bucket_policy.audit_logs_tls_only
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_config_configuration_recorder" "this" {
  name     = "fleetsec-${var.environment}-config-recorder"
  role_arn = var.aws_config_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "this" {
  name           = "fleetsec-${var.environment}-config-delivery"
  s3_bucket_name = aws_s3_bucket.audit_logs.id

  depends_on = [
    aws_config_configuration_recorder.this
  ]
}

data "aws_iam_policy_document" "sns_security_alerts" {
  statement {
    sid    = "AllowS3EventNotifications"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "sns:Publish"
    ]

    resources = [
      aws_sns_topic.security_alerts.arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.audit_logs.arn]
    }
  }
}

resource "aws_sns_topic_policy" "security_alerts" {
  arn    = aws_sns_topic.security_alerts.arn
  policy = data.aws_iam_policy_document.sns_security_alerts.json
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/fleetsec/${var.environment}/cloudtrail"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.s3.arn

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "cloudtrail_logs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudtrail_logs" {
  name               = "fleetsec-${var.environment}-cloudtrail-logs-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_logs_assume_role.json
}

data "aws_iam_policy_document" "cloudtrail_logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "cloudtrail_logs" {
  name   = "fleetsec-${var.environment}-cloudtrail-logs-policy"
  policy = data.aws_iam_policy_document.cloudtrail_logs.json
}

resource "aws_iam_role_policy_attachment" "cloudtrail_logs" {
  role       = aws_iam_role.cloudtrail_logs.name
  policy_arn = aws_iam_policy.cloudtrail_logs.arn
}

# Organization-ready GuardDuty baseline.
# Requires an AWS Organizations delegated administrator when applied.
resource "aws_guardduty_organization_configuration" "this" {
  detector_id                      = aws_guardduty_detector.this.id
  auto_enable_organization_members = "ALL"

  datasources {
    s3_logs {
      auto_enable = true
    }

    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = true
        }
      }
    }
  }
}
