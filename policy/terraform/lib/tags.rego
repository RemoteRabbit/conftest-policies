# METADATA
# title: Shared tag helpers
# description: |
#   Tag helpers shared between HCL- and plan-based policies. Keeping the
#   logic in one place ensures both input shapes treat "missing" identically
#   (absent key OR present-but-empty string).
# scope: package
package terraform.lib.tags

import rego.v1

# Default required tag set. Individual rules can pass their own set instead.
default_required := {"Environment", "Owner"}

# present(tag_map) returns the set of tag keys present in tag_map with a
# non-empty string value. Tolerates a nil/absent tag_map.
present(tag_map) := names if {
	is_object(tag_map)
	names := {k | some k; v := tag_map[k]; is_string(v); v != ""}
}

present(tag_map) := set() if {
	not is_object(tag_map)
}

# missing(tag_map, required) returns the required tags that are absent or
# present but empty in tag_map.
missing(tag_map, required) := required - present(tag_map)
