<!--
Title MUST follow Conventional Commits (release-please depends on it):
  feat: add iam wildcard action policy
  fix(s3): handle bucket without tags block
  docs: clarify --all-namespaces usage
  chore(ci): bump conftest to 0.57.0
-->

## Summary

<!-- What does this PR change and why? -->

## Related issue

Closes #

## Type of change

- [ ] New or updated policy
- [ ] Bug fix
- [ ] Tooling / CI / build
- [ ] Documentation
- [ ] Other:

## Checklist

- [ ] `make check` passes locally
- [ ] `make test` passes locally
- [ ] New / changed policies have `# METADATA` annotations
- [ ] New / changed policies have rego unit tests (`*_test.rego`)
- [ ] Fixture(s) added or updated under `tests/fixtures/`
- [ ] `docs/POLICIES.md` regenerated (`make docs`) if policies changed
- [ ] Commit messages follow Conventional Commits
