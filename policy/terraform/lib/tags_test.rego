package terraform.lib.tags_test

import rego.v1

import data.terraform.lib.tags

test_present_returns_only_non_empty_string_values if {
	tags.present({"a": "x", "b": "", "c": "y", "d": null}) == {"a", "c"}
}

test_present_tolerates_non_object_input if {
	tags.present(null) == set()
	tags.present("oops") == set()
}

test_missing_flags_absent_and_empty if {
	tags.missing({"Owner": "platform", "Environment": ""}, {"Environment", "Owner"}) == {"Environment"}
}

test_missing_returns_empty_when_all_present if {
	tags.missing({"Environment": "test", "Owner": "platform"}, {"Environment", "Owner"}) == set()
}

test_default_required_is_environment_and_owner if {
	tags.default_required == {"Environment", "Owner"}
}
