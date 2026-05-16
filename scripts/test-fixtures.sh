#!/usr/bin/env bash
# Run conftest against every fixture and assert the expected pass/fail outcome.
#
# Layout:
#   tests/fixtures/terraform/hcl/<provider>/<resource>/{compliant,violation}/main.tf
#   tests/fixtures/terraform/plan/<provider>/<resource>/{compliant,violation}/main.tf
#
# Each "compliant" fixture must produce zero denials; each "violation" fixture
# must produce at least one denial. The namespace is derived from the fixture
# path: terraform.<kind>.<provider>.<resource>.
#
# Usage:
#   scripts/test-fixtures.sh hcl
#   scripts/test-fixtures.sh plan
#   scripts/test-fixtures.sh           # both
#
# Plan fixtures are expected to already contain plan.json (run `make plan`).

set -euo pipefail

POLICY_DIR=${POLICY_DIR:-policy}
HCL_ROOT=tests/fixtures/terraform/hcl
PLAN_ROOT=tests/fixtures/terraform/plan

status=0

# namespace_for <root> <fixture-dir-or-file> <kind>
# Maps tests/fixtures/terraform/<kind>/<provider>/<resource>/{compliant,violation}/...
# to terraform.<kind>.<provider>.<resource>.
namespace_for() {
  local root=$1 path=$2 kind=$3
  local rel="${path#"$root"/}"        # <provider>/<resource>/{compliant,violation}/...
  rel="${rel%%/compliant*}"
  rel="${rel%%/violation*}"
  echo "terraform.${kind}.${rel//\//.}"
}

run_compliant() {
  local input=$1 ns=$2 label=$3
  echo "==> [$label] compliant: $input ($ns)"
  if ! conftest test "$input" -p "$POLICY_DIR" --namespace "$ns"; then
    echo "ERROR: compliant fixture produced denials" >&2
    status=1
  fi
}

run_violation() {
  local input=$1 ns=$2 label=$3
  echo "==> [$label] violation (expect denials): $input ($ns)"
  if conftest test "$input" -p "$POLICY_DIR" --namespace "$ns" >/dev/null 2>&1; then
    echo "ERROR: violation fixture did not produce any denials" >&2
    status=1
  else
    echo "  ok: denials fired as expected"
  fi
}

run_hcl() {
  [[ -d $HCL_ROOT ]] || { echo "no HCL fixtures under $HCL_ROOT"; return; }
  while IFS= read -r f; do
    run_compliant "$f" "$(namespace_for "$HCL_ROOT" "$f" hcl)" hcl
  done < <(find "$HCL_ROOT" -type f -path '*/compliant/main.tf' | sort)
  while IFS= read -r f; do
    run_violation "$f" "$(namespace_for "$HCL_ROOT" "$f" hcl)" hcl
  done < <(find "$HCL_ROOT" -type f -path '*/violation/main.tf' | sort)
}

run_plan() {
  [[ -d $PLAN_ROOT ]] || { echo "no plan fixtures under $PLAN_ROOT"; return; }
  while IFS= read -r d; do
    local json="$d/plan.json"
    [[ -f $json ]] || { echo "ERROR: $json missing (run 'make plan')" >&2; status=1; continue; }
    run_compliant "$json" "$(namespace_for "$PLAN_ROOT" "$d" plan)" plan
  done < <(find "$PLAN_ROOT" -type d -path '*/compliant' | sort)
  while IFS= read -r d; do
    local json="$d/plan.json"
    [[ -f $json ]] || { echo "ERROR: $json missing (run 'make plan')" >&2; status=1; continue; }
    run_violation "$json" "$(namespace_for "$PLAN_ROOT" "$d" plan)" plan
  done < <(find "$PLAN_ROOT" -type d -path '*/violation' | sort)
}

case "${1:-all}" in
  hcl)  run_hcl ;;
  plan) run_plan ;;
  all)  run_hcl; run_plan ;;
  *)    echo "Usage: $0 [hcl|plan|all]" >&2; exit 2 ;;
esac

exit "$status"
