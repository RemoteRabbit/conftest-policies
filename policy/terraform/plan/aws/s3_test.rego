package terraform.plan.aws.s3

import rego.v1

# Test inputs mirror `terraform show -json plan.tfplan` output.

_rc(name, after) := {
	"address": sprintf("aws_s3_bucket.%s", [name]),
	"mode": "managed",
	"type": "aws_s3_bucket",
	"name": name,
	"change": {"actions": ["create"], "before": null, "after": after},
}

test_compliant_bucket_has_no_violations if {
	count(deny) == 0 with input as {"resource_changes": [_rc(
		"ok",
		{"bucket": "x", "tags": {"Environment": "test", "Owner": "platform"}},
	)]}
}

test_missing_environment_yields_one_violation if {
	msgs := deny with input as {"resource_changes": [_rc(
		"bad",
		{"bucket": "x", "tags": {"Owner": "platform"}},
	)]}
	count(msgs) == 1
	some m in msgs
	contains(m, "Environment")
}

test_missing_both_tags_yields_two_violations if {
	msgs := deny with input as {"resource_changes": [_rc("bad", {"bucket": "x"})]}
	count(msgs) == 2
}

test_empty_string_tag_is_missing if {
	msgs := deny with input as {"resource_changes": [_rc(
		"bad",
		{"bucket": "x", "tags": {"Environment": "", "Owner": "platform"}},
	)]}
	count(msgs) == 1
}

test_pure_delete_is_ignored if {
	count(deny) == 0 with input as {"resource_changes": [{
		"address": "aws_s3_bucket.gone",
		"mode": "managed",
		"type": "aws_s3_bucket",
		"name": "gone",
		"change": {"actions": ["delete"], "before": {"bucket": "x"}, "after": null},
	}]}
}

test_non_s3_resource_ignored if {
	count(deny) == 0 with input as {"resource_changes": [{
		"address": "aws_iam_role.x",
		"mode": "managed",
		"type": "aws_iam_role",
		"name": "x",
		"change": {"actions": ["create"], "before": null, "after": {"name": "x"}},
	}]}
}
