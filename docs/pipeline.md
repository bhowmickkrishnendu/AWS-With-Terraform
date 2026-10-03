# GitHub Actions pipeline

This project uses one AWS account and separate Terraform state files. The deployed stacks are networking, storage, and compute. The IAM root has no live inputs, and ECR and EKS have no deployed state in the last inventory, so automatic deployment does not include them. Bootstrap manages the state bucket and also stays outside automatic deployment.

## Pull requests

Every pull request runs [PR checks](../.github/workflows/pr-validation.yml), with no path filter. The jobs check workflow syntax, Terraform format and validation for every root, IAM tests, a disposable local destroy test, TFLint, tfsec, Infracost, and required files. The final `PR checks` job fails when any job fails, is cancelled, or is skipped.

PR code does not receive AWS credentials or a live Terraform state role. The compute state can contain an SSH private key, so live plans are made only after merge or by a maintainer using the manual plan workflow. This also means a PR check is a code and cost estimate, not a live AWS plan.

TFLint and tfsec fail the PR when they find issues. tfsec gates HIGH and CRITICAL findings. The currently deployed state bucket uses AES256, so it has a narrow, dated exception for the customer-managed KMS rule. The undeployed EKS root has dated exceptions for cluster encryption, public API access, and broad egress. These exceptions expire and must be resolved during Phase 5 before EKS is enabled. New findings outside these exact locations fail the check.

Infracost estimates the three deployed roots from Terraform source and `terraform.tfvars`. It reports their current estimated monthly costs, not a live bill or a PR cost difference. If the CLI fails or `INFRACOST_API_KEY` is unavailable, the cost job fails. Configure that repository secret before requiring the PR gate. Fork PRs cannot receive the secret from a normal `pull_request` workflow, so their cost job will fail until the change is brought through a trusted branch. No cost increase threshold is configured because this project has not set a budget policy.

To enforce the PR result, protect `master` in GitHub Settings and require the status check named `PR checks`. Do not add a path filter to this workflow. Review the first completed PR run and select its final gate job as the required check. The repository currently has a protected `master` branch, but the exact required-check list must be verified in GitHub settings after this workflow is published.

## After a merge

[Terraform Deploy](../.github/workflows/terraform-apply.yml) starts on a push to `master`. It plans networking, then waits for approval and applies its saved plan if there are changes. It repeats that sequence for storage and then compute. This order gives compute a fresh plan after networking has finished. A no-change plan skips its apply approval. A failed plan or apply stops the later stacks.

Each apply job uses a different GitHub environment: `apply-networking`, `apply-storage`, and `apply-compute`. Configure each environment with at least one required reviewer and allow deployment from `master` only. The reusable apply job reads the environment protection rules and fails before AWS access if required reviewers are absent. An environment name alone does not provide approval. Approval happens separately for each changed stack.

The caller uses the existing repository variable `AWS_TERRAFORM_ROLE_ARN`. The role and its OIDC trust are not created or changed by this phase. Set the variable to the intended role ARN and check that its trust allows runs on `master`. No account ID or access key belongs in this repository.

The reusable plan workflow returns whether the plan has changes and a SHA256 digest. It uploads the binary plan only for changed stacks, with a one-day retention period. The approved apply job downloads the artifact from the same run, compares the digest, checks that `master` still points at this run's commit, and applies that saved plan. A binary Terraform plan can include secrets in cleartext. Restrict who can read Actions artifacts and do not copy them to PR comments. If the approval waits past the artifact lifetime, rerun a fresh deployment. The deploy and destroy callers use one concurrency group with cancellation disabled, so live runs queue instead of overlapping.

The three reusable workflows in `terraform-gha-workflows` must be pinned to the reviewed Phase 6 commit SHA in every caller. Publish the shared workflow commit before publishing this repository branch so the SHA resolves. The plan and apply jobs use Terraform `1.14.2` and the committed provider lock files.

## Manual plan, destroy, and drift

[Terraform Manual Plan](../.github/workflows/terraform-plan.yml) lets a maintainer plan one deployed stack from `master`. It does not upload its saved plan and cannot apply.

[Terraform Manual Destroy](../.github/workflows/terraform-destroy.yml) accepts only networking, storage, or compute. It requires the exact text `DESTROY` and only runs from `master`. It creates a destroy plan in `ap-south-1`, then waits at `destroy-<component>` with required reviewers. The job verifies the saved plan digest and applies that plan. Configure these three destroy environments separately and restrict them to `master`. A local disposable Terraform stack test exercises saved-plan creation and destruction without touching AWS. The live destroy path still needs a separate test on disposable AWS resources before anyone uses it for a deployed stack.

[Terraform Drift](../.github/workflows/terraform-drift.yml) runs weekly and can be started manually. It checks networking, storage, and compute with a read-only normal plan. It reports only event types, resource addresses, and actions, and fails on drift, proposed changes, or plan errors. It does not save a binary plan. Existing storage drift notices may make this job fail until their cause is resolved; do not suppress them without reviewing the live bucket and state.

See [recovery.md](recovery.md) for state version checks, failed apply handling, and a safe recovery order.
