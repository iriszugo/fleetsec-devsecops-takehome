variable "environment" {
  description = "FleetSec deployment environment"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "soc_email" {
  description = "Email destination for FleetSec security alerts"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.soc_email))
    error_message = "soc_email must contain a valid email address."
  }
}

variable "db_username" {
  description = "RDS administrator username"
  type        = string
  sensitive   = true
  default     = "fleetsecadmin"
}

variable "secrets_rotation_lambda_arn" {
  description = "ARN of the Lambda function responsible for Secrets Manager rotation"
  type        = string
}

variable "aws_config_role_arn" {
  description = "IAM role ARN used by AWS Config"
  type        = string
}

variable "s3_access_log_bucket_id" {
  description = "Existing centralized S3 bucket used as the destination for S3 server access logs"
  type        = string
}

variable "s3_replication_destination_bucket_arn" {
  description = "ARN of the secondary-region S3 bucket used for audit-log replication"
  type        = string
}

variable "s3_replication_destination_kms_key_arn" {
  description = "KMS key ARN protecting the secondary-region replication bucket"
  type        = string
}
