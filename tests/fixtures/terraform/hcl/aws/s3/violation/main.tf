# Non-compliant aws_s3_bucket fixture for static (HCL) policy checks.
# Expected to be denied by `terraform.hcl.aws.s3` rules.

resource "aws_s3_bucket" "missing_all_tags" {
  bucket = "example-missing-all-tags"
  # Intentionally no tags map at all.
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
