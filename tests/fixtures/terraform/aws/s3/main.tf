terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configured so `terraform plan` works fully offline with no real AWS account.
# We never `apply`; this exists only to produce HCL + a plan JSON for conftest.
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

# --- Compliant example -------------------------------------------------------

resource "aws_s3_bucket" "compliant" {
  bucket = "example-compliant-bucket"

  tags = {
    Environment = "test"
    Owner       = "platform"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "compliant" {
  bucket = aws_s3_bucket.compliant.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "compliant" {
  bucket                  = aws_s3_bucket.compliant.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Non-compliant example (used to assert policies catch violations) --------

resource "aws_s3_bucket" "violation" {
  bucket = "example-violation-bucket"
  # Intentionally missing tags + no encryption + no public access block.
}
