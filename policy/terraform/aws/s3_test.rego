package terraform.aws.s3

import rego.v1

test_compliant_bucket_has_no_violations if {
	count(deny) == 0 with input as {"resource": {"aws_s3_bucket": {"ok": [{
		"bucket": "x",
		"tags": {"Environment": "test", "Owner": "platform"},
	}]}}}
}

test_missing_environment_tag_yields_one_violation if {
	msgs := deny with input as {"resource": {"aws_s3_bucket": {"bad": [{
		"bucket": "x",
		"tags": {"Owner": "platform"},
	}]}}}
	count(msgs) == 1
}

test_missing_both_tags_yields_two_violations if {
	msgs := deny with input as {"resource": {"aws_s3_bucket": {"bad": [{"bucket": "x"}]}}}
	count(msgs) == 2
}
