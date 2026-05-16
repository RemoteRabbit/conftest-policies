# AWS Terraform fixture

A local-only Terraform configuration used to exercise conftest policies. The
`aws` provider is configured with mock credentials and every `skip_*` flag set
so that `terraform init` and `terraform plan` succeed without any AWS account
or network access. **Never run `terraform apply` here.**

## Generate inputs for conftest

From the repo root:

```sh
./scripts/generate-plan.sh tests/fixtures/terraform/aws/s3
```

That produces, inside this directory:

- `plan.tfplan`: binary plan (gitignored)
- `plan.json`: JSON plan (gitignored), the usual conftest input

You can then run, for example:

```sh
conftest test tests/fixtures/terraform/aws/s3/plan.json \
  -p policy/ --namespace terraform.aws.s3
# or scan the HCL directly:
conftest test tests/fixtures/terraform/aws/s3/main.tf \
  -p policy/ --namespace terraform.aws.s3
```
