# METADATA
# title: AWS S3 bucket HCL policies
# description: |
#   Static (HCL) tagging requirements for aws_s3_bucket resources. These run
#   against parsed Terraform source (`.tf` files) and are intended for fast
#   pre-commit / PR feedback before a plan exists.
#
#   Usage:
#     conftest test path/to/main.tf -p policy/ --namespace terraform.hcl.aws.s3
# scope: package
package terraform.hcl.aws.s3

import rego.v1

import data.terraform.lib.tags

# METADATA
# title: S3 buckets must declare required tags
# description: |
#   Every aws_s3_bucket must declare each required tag (Environment, Owner)
#   with a non-empty string value so cost reporting and incident response
#   can attribute the resource.
# custom:
#   severity: high
#   resource: aws_s3_bucket
#   input: hcl
#   required_tags: [Environment, Owner]
#   remediation: |
#     Add the missing key to the resource's `tags` map, e.g.
#       tags = {
#         Environment = "<env>"
#         Owner       = "<team>"
#       }
deny contains msg if {
	some name, blocks in input.resource.aws_s3_bucket
	bucket := blocks[_]
	some missing_tag in tags.missing(object.get(bucket, "tags", {}), tags.default_required)
	msg := sprintf("aws_s3_bucket.%s is missing required tag '%s'", [name, missing_tag])
}
