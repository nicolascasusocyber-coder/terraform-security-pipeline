terraform {
  required_version = ">= 1.12.2, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  skip_credentials_validation = var.offline_plan
  skip_requesting_account_id  = var.offline_plan
  skip_metadata_api_check     = var.offline_plan
}

resource "aws_vpc" "demo" {
  cidr_block = "10.42.0.0/16"

  tags = {
    Project = "terraform-security-pipeline"
  }
}

resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  tags = {
    Project = "terraform-security-pipeline"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  bucket = aws_s3_bucket.demo.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket                  = aws_s3_bucket.demo.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_security_group" "demo" {
  name        = "terraform-security-pipeline-demo"
  description = "Demo security group with SSH restricted to the VPC"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description = "SSH within the demo VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.demo.cidr_block]
  }

  tags = {
    Project = "terraform-security-pipeline"
  }
}
