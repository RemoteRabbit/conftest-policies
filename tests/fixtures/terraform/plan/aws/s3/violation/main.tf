terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configured so `terraform plan` works fully offline; never `apply`.
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

# Mixed compliant/non-compliant resources to exercise the plan-based rules.
resource "aws_s3_bucket" "missing_all_tags" {
  bucket = "example-missing-all-tags"
}

resource "aws_s3_bucket" "missing_owner" {
  bucket = "example-missing-owner"

  tags = {
    Environment = "test"
  }
}

resource "aws_s3_bucket" "empty_environment" {
  bucket = "example-empty-environment"

  tags = {
    Environment = ""
    Owner       = "platform"
  }
}
