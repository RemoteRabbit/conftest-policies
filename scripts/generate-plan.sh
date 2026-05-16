#!/usr/bin/env bash
# Generate a Terraform plan + JSON representation for conftest, fully offline.
#
# Usage: scripts/generate-plan.sh <path-to-terraform-fixture>
# Example: scripts/generate-plan.sh tests/fixtures/aws

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <path-to-terraform-fixture>" >&2
  exit 2
fi

fixture_dir=$1

if [[ ! -d $fixture_dir ]]; then
  echo "Error: '$fixture_dir' is not a directory" >&2
  exit 1
fi

pushd "$fixture_dir" >/dev/null

terraform init -input=false -backend=false >/dev/null
terraform plan -input=false -out=plan.tfplan
terraform show -json plan.tfplan >plan.json

popd >/dev/null

echo "Wrote $fixture_dir/plan.tfplan and $fixture_dir/plan.json"
