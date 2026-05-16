# Contributing

Thanks for contributing! This repo uses [Conventional Commits](https://www.conventionalcommits.org/)
to drive [release-please](https://github.com/googleapis/release-please) (version
bumps + `CHANGELOG.md`) and [commitlint](https://commitlint.js.org) (CI + the
local `commit-msg` hook installed via `make install`).

Commit messages **must** match:

```
<type>(<scope>): <subject>
```

The scope is optional for human commits; Renovate always sets one.

## Commit types

| Type       | When to use                                                                       | Changelog section |
| ---------- | --------------------------------------------------------------------------------- | ----------------- |
| `feat`     | New policy, new rule, new helper - anything user-visible and additive             | Features          |
| `fix`      | Bug fix in an existing policy/rule, scripts, or Makefile                          | Bug Fixes         |
| `security` | CVE / vulnerability fix (Renovate emits these automatically for security alerts)  | Security          |
| `perf`     | Faster rego, faster scripts, lower CI time                                        | Performance       |
| `revert`   | Reverts an earlier commit                                                         | Reverts           |
| `docs`     | README, `docs/POLICIES.md` content, METADATA annotations, CONTRIBUTING            | Documentation     |
| `refactor` | Code change that neither fixes a bug nor adds a feature                           | Refactors         |
| `build`    | Dependency updates (Renovate emits these automatically)                           | Dependencies      |
| `test`     | Adding or fixing tests only                                                       | _hidden_          |
| `ci`       | Changes to `.github/workflows/**`, pre-commit config, lint config                 | _hidden_          |
| `chore`    | Everything else (e.g. tweaking `.gitignore`, repo housekeeping)                   | _hidden_          |

A breaking change is signaled with `!` after the type/scope or a
`BREAKING CHANGE:` footer and triggers a major version bump.

## Allowed scopes

Scopes are enum-validated by commitlint to catch typos. If you need a new one,
add it to `.commitlintrc.yml`.

| Scope            | Used for                                                  |
| ---------------- | --------------------------------------------------------- |
| `github-actions` | GitHub Actions version bumps (Renovate)                   |
| `pre-commit`     | pre-commit hook `rev:` bumps (Renovate)                   |
| `ci-tooling`     | Pinned tool versions in workflow env vars (Renovate)      |
| `terraform`      | Terraform providers under `tests/fixtures/` (Renovate)    |
| `deps`           | Security/vulnerability fixes (Renovate) or manual deps    |

Human commits without a clear scope match should just omit the scope:
`feat: add s3 bucket public-access policy`.

## Examples

```
feat: add s3 bucket public-access denial rule
fix: handle nil module address in vpc rule
docs: clarify how to consume oci artifact
feat!: drop support for conftest <0.50

build(github-actions): update actions/checkout to v5
build(pre-commit): update astral-sh/ruff-pre-commit to v0.8.0
security(deps): update urllib3 to 2.2.3 [security]
```

## Workflow

1. `make install` - installs pre-commit + commit-msg hooks (one-time).
2. Branch, code, `make check`, `make test`.
3. Open a PR. CI runs lint, rego unit tests, fixture plans, commitlint, and
   `renovate.json` validation.
4. On merge to `main`, release-please opens/updates a release PR with the next
   version + changelog. Merging that PR cuts a tagged release.
