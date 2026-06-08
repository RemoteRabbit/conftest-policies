# conftest-policies

Reusable [conftest](https://www.conftest.dev/) / [OPA](https://www.openpolicyagent.org/)
policies for Terraform code and plans.

## Local development

### Requirements

| Tool                                                               | Used for                                    | CI version |
| ------------------------------------------------------------------ | ------------------------------------------- | ---------- |
| [terraform](https://developer.hashicorp.com/terraform/install)     | Generating plans for fixtures               | <!-- renovate: datasource=github-releases depName=hashicorp/terraform -->1.15.4 |
| [conftest](https://www.conftest.dev/install/)                      | Running policies and rego unit tests        | <!-- renovate: datasource=github-releases depName=open-policy-agent/conftest -->0.68.2 |
| [opa](https://www.openpolicyagent.org/docs/latest/#running-opa)    | Extracting METADATA for docs generation     | <!-- renovate: datasource=github-releases depName=open-policy-agent/opa -->1.16.2 |
| [pre-commit](https://pre-commit.com/#install)                      | Lint + commit-msg hooks                     | latest     |
| `jq`, `bash`, `make`, `curl`                                       | Shell glue for scripts                      | system     |

Any reasonably recent version of each works locally; the table shows what CI
pins (kept in sync with `.github/workflows/ci.yml` automatically by Renovate).

**Arch Linux:**

```sh
sudo pacman -S terraform jq pre-commit make
# conftest + opa are not in the official repos; install from AUR or upstream:
yay -S conftest-bin open-policy-agent-bin
# or grab the release binaries directly:
#   https://github.com/open-policy-agent/conftest/releases
#   https://github.com/open-policy-agent/opa/releases
```

**macOS (Homebrew):**

```sh
brew install terraform conftest opa pre-commit jq make
# `make` from brew is GNU make 4.x; the system `/usr/bin/make` (3.81) also works.
# If you use a different shell, ensure /opt/homebrew/bin (Apple Silicon) or
# /usr/local/bin (Intel) is on PATH.
```

After installing the tools, finish bootstrapping the repo with `make install`
(see Quickstart below).

### Quickstart

```sh
git clone https://github.com/remoterabbit/conftest-policies.git
cd conftest-policies
make install   # one-time: install pre-commit + commit-msg hooks
make check     # lint + rego unit tests + docs freshness
make test      # generate plans for every fixture and run conftest
```

`make` with no arguments lists every available target.

## Layout

```
policy/terraform/lib/<area>.rego                     Shared helpers (terraform.lib.*)
policy/terraform/hcl/<provider>/<resource>.rego      HCL (static) policies   (terraform.hcl.*)
policy/terraform/plan/<provider>/<resource>.rego     Plan (post-plan) policies (terraform.plan.*)
policy/terraform/{hcl,plan,lib}/.../*_test.rego      Rego unit tests
tests/fixtures/terraform/hcl/<provider>/<resource>/{compliant,violation}/main.tf
tests/fixtures/terraform/plan/<provider>/<resource>/{compliant,violation}/main.tf
scripts/                                             Helper scripts
```

Policies come in two flavours so consumers get both fast static feedback and
plan-aware enforcement:

- **HCL** policies (`terraform.hcl.*`) run against parsed `.tf` source. Great
  for pre-commit / PR linting; cheap, no `terraform init`/`plan` needed.
- **Plan** policies (`terraform.plan.*`) run against `terraform show -json
  plan.tfplan` output. Catches violations that only materialise once
  variables, locals, modules, and data sources are resolved.

Both share rule logic via `data.terraform.lib.*` so a single source of truth
defines what e.g. "required tag" means. Fixture paths mirror the policy tree:
each rule has a `compliant/` fixture (expected to pass) and a `violation/`
fixture (expected to fail), which `make test` asserts.

## Local Terraform fixtures

Fixtures under `tests/fixtures/` are designed to run fully offline, with no remote
backend, no cloud credentials. The AWS provider is configured with mock keys
and `skip_*` flags so that `terraform init`/`plan` work without any account.
**Do not `terraform apply` against these fixtures.**

Generate a plan + JSON for every **plan** fixture (or one via `FIXTURE=<path>`).
HCL fixtures are parsed directly by conftest and do not need a plan:

```sh
make plan
make plan FIXTURE=tests/fixtures/terraform/plan/aws/s3/compliant
```

## Common tasks

A self-documenting Makefile wraps the day-to-day workflow:

```sh
make             # list targets
make install     # install pre-commit + commit-msg hooks
make check       # lint + rego unit tests + docs/changelog freshness (CI-equivalent local gate)
make test        # run both HCL and plan fixture suites
make test-hcl    # static (HCL) policies only - no terraform plan needed
make test-plan   # plan-based policies (generates plan.json first)
make docs        # regenerate docs/POLICIES.md from OPA METADATA annotations
make changelogs  # regenerate docs/changelogs/<kind>.md via git-cliff
make clean       # remove generated Terraform artifacts
```

Policy reference docs live at [docs/POLICIES.md](docs/POLICIES.md) and are
generated from `# METADATA` blocks on each rule; `make docs-check` (run by
CI and `make check`) fails if the file is stale. Authoring docs is therefore
just a matter of adding/updating METADATA in the rego file.

Conventional Commits are enforced two ways (release-please depends on them):

- **Locally** via the `commit-msg` pre-commit hook (run `make install` once)
- **In CI** via [.github/workflows/commitlint.yml](.github/workflows/commitlint.yml),
  which validates every commit in a PR and the PR title itself

See [CONTRIBUTING.md](CONTRIBUTING.md) for the allowed commit types and scopes.

Raw commands still work if you prefer:

```sh
# Rego unit tests
conftest verify -p policy/

# Static (HCL) policies against a .tf file
conftest test tests/fixtures/terraform/hcl/aws/s3/compliant/main.tf \
  -p policy/ --namespace terraform.hcl.aws.s3

# Plan policies against plan.json
conftest test tests/fixtures/terraform/plan/aws/s3/compliant/plan.json \
  -p policy/ --namespace terraform.plan.aws.s3

# Run every namespace (HCL + plan) at once
conftest test path/to/input -p policy/ --all-namespaces
```

## Consuming as a pre-commit hook

Downstream repos can wire the static (HCL) checks into their own pre-commit
config; this repo ships a [.pre-commit-hooks.yaml](.pre-commit-hooks.yaml)
exposing two hook IDs:

```yaml
# .pre-commit-config.yaml in the consumer repo
repos:
  - repo: https://github.com/remoterabbit/conftest-policies
    rev: v0.1.0   # pin to a released tag
    hooks:
      - id: conftest-terraform-hcl        # runs on changed .tf files
      # - id: conftest-terraform-plan     # opt-in, manual stage, runs on plan.json
```

`conftest` must be on `PATH`; see the [install
guide](https://www.conftest.dev/install/). The `conftest-terraform-plan` hook
is marked `stages: [manual]` because plans are not usually committed - invoke
it from CI with `pre-commit run conftest-terraform-plan --all-files` after
generating `plan.json`.

## Dependency updates

Dependencies are kept fresh by [Renovate](https://docs.renovatebot.com/).
[.github/renovate.json](.github/renovate.json) covers:

- GitHub Actions versions
- Terraform providers under `tests/fixtures/`
- Pre-commit hook `rev:` pins
- Pinned tool versions in workflow env vars (annotated with `# renovate:` comments)

Updates are grouped by category and raised on Monday mornings (UTC):

- `build(github-actions): ...` - GitHub Actions (pinned to SHAs)
- `build(pre-commit): ...` - pre-commit hook revs
- `build(ci-tooling): ...` - pinned tool versions in workflow env vars
- `build(terraform): ...` - Terraform providers under `tests/fixtures/`
- `security(deps): ...` - CVE / vulnerability fixes (never auto-merged)

These land in a **Dependencies** (and **Security**) section of the
release-please changelog. **Renovate must be enabled on the repo via the
[GitHub App](https://github.com/apps/renovate) for the config to take effect.**

## Releases & distribution

Releases are managed by [release-please](https://github.com/googleapis/release-please)
driven by [Conventional Commits](https://www.conventionalcommits.org/) on `main`.
Merging the release PR creates a tagged GitHub release and triggers an OCI push
of `policy/` to GitHub Container Registry.

Consume from a downstream pipeline:

```sh
# pin by tag
conftest pull oci://ghcr.io/remoterabbit/conftest-policies:0.1.0
conftest test path/to/plan.json -p policy/ --all-namespaces

# or, for stronger guarantees, pin by digest
conftest pull oci://ghcr.io/remoterabbit/conftest-policies@sha256:<digest>
```
