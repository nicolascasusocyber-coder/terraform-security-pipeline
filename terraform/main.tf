terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

# Remediation 1: S3 Bucket with Server-Side Encryption
resource "aws_s3_bucket" "insecure_bucket" {
  bucket        = "my-company-confidential-data-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.insecure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Remediation 2: EBS Storage Volume with Encryption
resource "aws_ebs_volume" "insecure_volume" {
  availability_zone = "eu-west-1a"
  size              = 20
  encrypted         = true

  tags = {
    Name = "SecureDataVolume"
  }
}

# Remediation 3: Restricted Security Group (No 0.0.0.0/0 SSH)
resource "aws_security_group" "insecure_sg" {
  name        = "secure-ssh-sg"
  description = "Security group with restricted SSH port"
  vpc_id      = "vpc-12345678"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}
