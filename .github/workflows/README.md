# Terraform workflows

`pr-validation.yml` runs on every PR and merge queue check. It has one final `PR checks` gate that must be required by the protected `master` branch. It uses no AWS credentials. Format, validation, IAM tests, workflow lint, TFLint, tfsec, cost, and documentation checks are all blocking.

`terraform-apply.yml` runs after a merge to `master`. It handles deployed networking, storage, and compute in order. Each stack gets a fresh plan. A changed stack waits at its own `apply-<component>` environment before the exact saved plan is applied. Set required reviewers and a `master` deployment branch rule on every apply environment. The reusable workflow checks that reviewers exist before using AWS credentials.

`terraform-plan.yml` is a manual read-only plan. `terraform-destroy.yml` is manual, requires `DESTROY`, and uses separate protected `destroy-<component>` environments. `terraform-drift.yml` checks the deployed stacks weekly. Deploy, destroy, and drift share a concurrency group so they do not overlap.

The callers use the full commit SHA of the `v3.0.0` release of the shared `terraform-gha-workflows` repository. Publish that shared release before merging these callers. Published version tags must not be moved. Set `AWS_TERRAFORM_ROLE_ARN` as a repository Actions variable and `INFRACOST_API_KEY` as a repository secret. No workflow here changes the existing OIDC role or GitHub environment settings. See [pipeline.md](../../docs/pipeline.md) for the setup and limits, and [recovery.md](../../docs/recovery.md) for recovery steps.

Before merging the v3 caller update, configure `TF_PLAN_PASSPHRASE` as a repository Actions secret with at least 32 random characters. Shared jobs receive only this secret explicitly. Plan artifacts are encrypted and verified before apply. Artifact names include the run attempt; use **Re-run all jobs** when retrying. Manual plan uses no artifact and needs no encryption secret.

All four live workflows share concurrency with cancellation disabled and run from `master`; PR checks have separate concurrency and cancel superseded validation. Apply jobs use explicit status conditions, and `Deployment result` fails if any changed stack was skipped. See [the audit](../../docs/pipeline-audit.md) for findings and remaining administrative controls.
