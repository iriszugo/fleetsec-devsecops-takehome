data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "fleetsec-${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "fleetsec-${var.environment}-public-${count.index + 1}"
    Tier        = "Public"
    Environment = var.environment
  }
}

resource "aws_subnet" "app" {
  count = 2

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "fleetsec-${var.environment}-app-${count.index + 1}"
    Tier        = "Application"
    Environment = var.environment
  }
}

resource "aws_subnet" "data" {
  count = 2

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 20)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "fleetsec-${var.environment}-data-${count.index + 1}"
    Tier        = "Data"
    Environment = var.environment
  }
}

resource "aws_security_group" "app" {
  name        = "fleetsec-${var.environment}-app-sg"
  description = "FleetSec application security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from load balancer tier"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    description = "HTTPS outbound only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "data" {
  name        = "fleetsec-${var.environment}-data-sg"
  description = "FleetSec database security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "PostgreSQL only from application tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "No general Internet egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/fleetsec/${var.environment}/vpc-flow-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.s3.arn

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name               = "fleetsec-${var.environment}-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role.json
}

data "aws_iam_policy_document" "vpc_flow_logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "vpc_flow_logs" {
  name   = "fleetsec-${var.environment}-vpc-flow-logs-policy"
  policy = data.aws_iam_policy_document.vpc_flow_logs.json
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs" {
  role       = aws_iam_role.vpc_flow_logs.name
  policy_arn = aws_iam_policy.vpc_flow_logs.arn
}

resource "aws_flow_log" "this" {
  vpc_id               = aws_vpc.this.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  ingress = []
  egress  = []

  tags = {
    Name        = "fleetsec-${var.environment}-default-deny"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Private interface endpoint gives the application tier private access
# to Secrets Manager and attaches the application security group to ENIs.
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.app[*].id
  security_group_ids  = [aws_security_group.app.id]
  private_dns_enabled = true

  tags = {
    Name        = "fleetsec-${var.environment}-secretsmanager-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
