# Security Policy

## Supported versions

Only the latest tagged release receives security fixes. Pin by tag (or digest)
when consuming the policies via OCI:

```sh
conftest pull oci://ghcr.io/remoterabbit/conftest-policies@sha256:<digest>
```

## Reporting a vulnerability

Please **do not** open a public GitHub issue for security problems.

Use GitHub's [private vulnerability reporting](https://github.com/remoterabbit/conftest-policies/security/advisories/new)
to send a report. You should receive an acknowledgement within a few days.

When reporting, include:

- A description of the issue and its impact.
- Steps to reproduce (a minimal Terraform fixture and the policy invocation
  helps a lot).
- The commit SHA / release tag you tested against.
- Any suggested remediation, if you have one.

## Scope

In scope:

- Rego policies under `policy/` producing incorrect deny/allow decisions in a
  way that masks insecure infrastructure.
- Supply-chain issues with the published OCI artifact on GHCR.
- CI workflow misconfigurations that could leak secrets or allow unauthorised
  writes to the repository.

Out of scope:

- Vulnerabilities in third-party tools themselves (`conftest`, `opa`,
  `terraform`) - please report those upstream.
- Issues in example fixtures under `tests/fixtures/`; these are intentionally
  insecure to exercise the policies.
