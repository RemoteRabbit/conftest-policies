package terraform.hcl.aws.s3

import rego.v1

# Test inputs mirror the shape conftest's hcl2 parser produces:
#   input.resource.<type>.<name> is a list of resource blocks.

test_compliant_bucket_has_no_violations if {
	count(deny) == 0 with input as {"resource": {"aws_s3_bucket": {"ok": [{
		"bucket": "x",
		"tags": {"Environment": "test", "Owner": "platform"},
	}]}}}
}

test_missing_environment_yields_one_violation if {
	msgs := deny with input as {"resource": {"aws_s3_bucket": {"bad": [{
		"bucket": "x",
		"tags": {"Owner": "platform"},
	}]}}}
	count(msgs) == 1
	some m in msgs
	contains(m, "Environment")
}

test_missing_both_tags_yields_two_violations if {
	msgs := deny with input as {"resource": {"aws_s3_bucket": {"bad": [{"bucket": "x"}]}}}
	count(msgs) == 2
}

test_empty_string_tag_value_is_treated_as_missing if {
	msgs := deny with input as {"resource": {"aws_s3_bucket": {"bad": [{
		"bucket": "x",
		"tags": {"Environment": "", "Owner": "platform"},
	}]}}}
	count(msgs) == 1
	some m in msgs
	contains(m, "Environment")
}

test_multiple_buckets_reported_independently if {
	msgs := deny with input as {"resource": {"aws_s3_bucket": {
		"a": [{"bucket": "a"}],
		"b": [{"bucket": "b", "tags": {"Environment": "x", "Owner": "y"}}],
	}}}
	count(msgs) == 2
}
