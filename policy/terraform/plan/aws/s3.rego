# METADATA
# title: AWS S3 bucket plan policies
# description: |
#   Tagging requirements for aws_s3_bucket resources, evaluated against a
#   Terraform plan (JSON). Use these when variables, locals, data sources, or
#   module composition mean the final tag set is only known after `plan`.
#
#   Usage:
#     terraform show -json plan.tfplan > plan.json
#     conftest test plan.json -p policy/ --namespace terraform.plan.aws.s3
# scope: package
package terraform.plan.aws.s3

import rego.v1

import data.terraform.lib.tags

# METADATA
# title: S3 buckets must declare required tags (plan)
# description: |
#   Every planned aws_s3_bucket create/update must declare each required tag
#   (Environment, Owner) with a non-empty string value. Pure-delete actions
#   are ignored.
# custom:
#   severity: high
#   resource: aws_s3_bucket
#   input: plan
#   required_tags: [Environment, Owner]
#   remediation: |
#     Add the missing key to the resource's `tags` map; if the value is
#     produced by a variable or local, ensure it is non-empty before plan.
deny contains msg if {
	some rc in input.resource_changes
	rc.type == "aws_s3_bucket"
	_is_managed_change(rc)
	some missing_tag in tags.missing(object.get(rc.change.after, "tags", {}), tags.default_required)
	msg := sprintf("%s is missing required tag '%s'", [rc.address, missing_tag])
}

# Only consider changes that produce (or update) a resource. A pure delete has
# `change.after == null` and `actions == ["delete"]`; we skip those.
_is_managed_change(rc) if {
	rc.mode == "managed"
	rc.change.after != null
	not _is_pure_delete(rc.change.actions)
}

_is_pure_delete(actions) if {
	count(actions) == 1
	actions[0] == "delete"
}
