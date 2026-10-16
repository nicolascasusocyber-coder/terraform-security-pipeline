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

# Misconfiguration 1 (ISO 27001 A.8.24): Public S3 bucket without server-side encryption
resource "aws_s3_bucket" "insecure_bucket" {
  bucket        = "my-company-confidential-data-bucket"
  force_destroy = true
}

# Misconfiguration 2 (ISO 27001 A.8.24): Unencrypted EBS storage volume
resource "aws_ebs_volume" "insecure_volume" {
  availability_zone = "eu-west-1a"
  size              = 20
  encrypted         = false

  tags = {
    Name = "InsecureDataVolume"
  }
}

# Misconfiguration 3 (ISO 27001 A.8.20): Security group allowing unrestricted inbound SSH access
resource "aws_security_group" "insecure_sg" {
  name        = "insecure-ssh-sg"
  description = "Security group with open SSH port"
  vpc_id      = "vpc-12345678"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
