.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

POLICY_DIR  := policy
FIXTURE_DIR := tests/fixtures
HCL_ROOT    := $(FIXTURE_DIR)/terraform/hcl
PLAN_ROOT   := $(FIXTURE_DIR)/terraform/plan

# Plan fixtures are <root>/<provider>/<resource>/{compliant,violation}/main.tf.
PLAN_FIXTURES := $(sort $(dir $(wildcard $(PLAN_ROOT)/*/*/*/main.tf)))

# Run a single plan fixture by passing FIXTURE=tests/fixtures/terraform/plan/aws/s3/compliant
FIXTURE ?=

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "; printf "\nUsage: make \033[36m<target>\033[0m\n\nTargets:\n"} \
		/^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo

.PHONY: install
install: ## Install pre-commit hooks (pre-commit + commit-msg)
	pre-commit install --install-hooks

.PHONY: fmt
fmt: ## Format Terraform fixtures
	terraform fmt -recursive $(FIXTURE_DIR)

.PHONY: fmt-check
fmt-check: ## Check Terraform formatting (no writes)
	terraform fmt -check -recursive $(FIXTURE_DIR)

.PHONY: lint
lint: ## Run all pre-commit hooks against every file
	pre-commit run --all-files

.PHONY: verify
verify: ## Run rego unit tests (conftest verify)
	conftest verify -p $(POLICY_DIR)

.PHONY: plan
plan: ## Generate plan.tfplan + plan.json for all plan fixtures (or FIXTURE=<path>)
	@if [ -n "$(FIXTURE)" ]; then \
		./scripts/generate-plan.sh "$(FIXTURE)"; \
	else \
		for f in $(PLAN_FIXTURES); do ./scripts/generate-plan.sh "$$f"; done; \
	fi

.PHONY: test-hcl
test-hcl: ## Run HCL policies against tests/fixtures/terraform/hcl
	./scripts/test-fixtures.sh hcl

.PHONY: test-plan
test-plan: plan ## Run plan policies against tests/fixtures/terraform/plan
	./scripts/test-fixtures.sh plan

.PHONY: test
test: test-hcl test-plan ## Run both HCL and plan fixture suites

.PHONY: docs
docs: ## Regenerate docs/POLICIES.md from OPA METADATA annotations
	./scripts/gen-docs.sh

.PHONY: docs-check
docs-check: ## Fail if docs/POLICIES.md is out of date
	@./scripts/gen-docs.sh >/dev/null
	@git diff --exit-code -- docs/POLICIES.md \
		|| { echo "docs/POLICIES.md is out of date; run 'make docs'"; exit 1; }

.PHONY: changelogs
changelogs: ## Regenerate docs/changelogs/<kind>.md via git-cliff
	./scripts/gen-scope-changelogs.sh

.PHONY: changelogs-check
changelogs-check: ## Fail if any docs/changelogs/*.md is out of date
	@./scripts/gen-scope-changelogs.sh >/dev/null
	@git diff --exit-code -- docs/changelogs \
		|| { echo "docs/changelogs is out of date; run 'make changelogs'"; exit 1; }

.PHONY: check
check: lint verify docs-check changelogs-check ## Run lint + rego unit tests + docs/changelog freshness (CI-equivalent local gate)

.PHONY: clean
clean: ## Remove generated Terraform artifacts from fixtures
	find $(FIXTURE_DIR) \( -name plan.tfplan -o -name plan.json -o -name .terraform.lock.hcl \) -delete
	find $(FIXTURE_DIR) -type d -name .terraform -prune -exec rm -rf {} +
