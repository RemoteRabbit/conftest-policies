# Compliant aws_s3_bucket fixture for static (HCL) policy checks.
# Conftest parses this file directly; no `terraform init`/`plan` required.

resource "aws_s3_bucket" "compliant" {
  bucket = "example-compliant-bucket"

  tags = {
    Environment = "test"
    Owner       = "platform"
  }
}
