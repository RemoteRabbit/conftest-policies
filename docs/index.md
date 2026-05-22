---
title: conftest-policies
description: OPA/Rego policies for Terraform, packaged for conftest.
hide:
  - navigation
---

# conftest-policies

OPA/Rego policies for Terraform, packaged for [conftest](https://www.conftest.dev/).
Policies cover both **static HCL** (`.tf` source) and **plan JSON**
(`terraform show -json plan.tfplan`).

## Where to start

- **[Policy reference](POLICIES.md)** - every policy with its rule ID,
  severity, description, and remediation, generated from OPA `METADATA`
  annotations.
- **Changelogs** - per-kind history:
  - [`hcl`](changelogs/hcl.md) - static HCL policies
  - [`plan`](changelogs/plan.md) - plan-based policies

## Using these policies

Pull and run against a Terraform plan:

```bash
conftest pull oci://ghcr.io/remoterabbit/conftest-policies:latest
terraform show -json plan.tfplan | conftest test -
```

Or use as a pre-commit hook - see the hook IDs in
[`.pre-commit-hooks.yaml`](https://github.com/remoterabbit/conftest-policies/blob/main/.pre-commit-hooks.yaml).

## Source

[remoterabbit/conftest-policies on GitHub](https://github.com/remoterabbit/conftest-policies)
