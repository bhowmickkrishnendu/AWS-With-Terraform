# Terraform workflows

`pr-validation.yml` runs on every PR and merge queue check. It has one final `PR checks` gate that must be required by the protected `master` branch. It uses no AWS credentials. Format, validation, IAM tests, workflow lint, TFLint, tfsec, cost, and documentation checks are all blocking.

`terraform-apply.yml` runs after a merge to `master`. It handles deployed networking, storage, and compute in order. Each stack gets a fresh plan. A changed stack waits at its own `apply-<component>` environment before the exact saved plan is applied. Set required reviewers and a `master` deployment branch rule on every apply environment. The reusable workflow checks that reviewers exist before using AWS credentials.

`terraform-plan.yml` is a manual read-only plan. `terraform-destroy.yml` is manual, requires `DESTROY`, and uses separate protected `destroy-<component>` environments. `terraform-drift.yml` checks the deployed stacks weekly. Deploy, destroy, and drift share a concurrency group so they do not overlap.

The callers use the exact `v2.0.1` release tag of the shared `terraform-gha-workflows` repository. Publish that shared release before merging these callers. Published version tags must not be moved. Set `AWS_TERRAFORM_ROLE_ARN` as a repository Actions variable and `INFRACOST_API_KEY` as a repository secret. No workflow here changes the existing OIDC role or GitHub environment settings. See [pipeline.md](../../docs/pipeline.md) for the setup and limits, and [recovery.md](../../docs/recovery.md) for recovery steps.
