# METADATA
# title: AWS S3 bucket policies
# description: |
#   Tagging requirements for aws_s3_bucket resources. Targets HCL documents
#   (resources nested under `resource.<type>.<name>` and wrapped in a list by
#   the conftest parser).
# scope: package
package terraform.aws.s3

import rego.v1

# METADATA
# title: S3 buckets must declare an Environment tag
# description: |
#   Every aws_s3_bucket must have a non-empty `tags.Environment` value so cost
#   reporting and incident response can attribute the resource.
# custom:
#   severity: high
#   resource: aws_s3_bucket
#   remediation: |
#     Add `Environment = "<env>"` to the resource's `tags` map.
deny contains msg if {
	some name, instances in input.resource.aws_s3_bucket
	bucket := instances[_]
	not bucket.tags.Environment
	msg := sprintf("aws_s3_bucket.%s is missing required tag 'Environment'", [name])
}

# METADATA
# title: S3 buckets must declare an Owner tag
# description: |
#   Every aws_s3_bucket must have a non-empty `tags.Owner` value identifying
#   the responsible team.
# custom:
#   severity: high
#   resource: aws_s3_bucket
#   remediation: |
#     Add `Owner = "<team>"` to the resource's `tags` map.
deny contains msg if {
	some name, instances in input.resource.aws_s3_bucket
	bucket := instances[_]
	not bucket.tags.Owner
	msg := sprintf("aws_s3_bucket.%s is missing required tag 'Owner'", [name])
}
