# GitHub Actions pipeline

GitHub Actions calls reusable Terraform workflows in the separate `bhowmickkrishnendu/terraform-gha-workflows` repository. The callers here pin that repository to commit `da38804b4d72091543c26eb51fcda47c8d6e6f87`. This page describes the checked-in workflow code. GitHub repository settings, environment protection rules, secrets, and actual run results must be checked in GitHub before calling a release path fully tested.

The caller passes `root_directory: stacks/<component>` to each reusable workflow. The `dev` environment value names plan artifacts. It does not select a folder or variable file. Each component offered by these callers has a `terraform.tfvars` file, which Terraform loads automatically. The callers also pass that filename to the shared workflows, whose pinned commit supports `root_directory`.

## What starts each workflow

| Caller | Trigger | Components in code | Result |
| --- | --- | --- | --- |
| `.github/workflows/terraform-plan.yml` | Any pull request to `main` or `master` | Networking and compute | Calls the shared plan workflow for each component |
| `.github/workflows/terraform-apply.yml` | Any push to `main` or `master` | Networking and compute | Calls shared plan, passes an environment job, then calls shared apply |
| `.github/workflows/terraform-destroy.yml` | Manual dispatch | Networking, compute, storage, ECR, or EKS | Calls shared destroy after a `DESTROY` text check |
| `.github/workflows/pr-validation.yml` | Pull request that changes `bootstrap/**`, `stacks/**`, `modules/**`, or `.github/workflows/**` | `bootstrap/` and all `stacks/*/` roots in its validation loop | Runs local formatting, validation, lint, security, cost, and documentation jobs |

The automatic matrices have storage, ECR, and EKS entries commented out. A Terraform root being present does not put it into automatic deployment. The manual destroy list is wider than the apply list, so a selected component needs careful review.

The plan and apply matrices run component jobs independently. There is no explicit `networking` then `compute` order in the workflow. Compute reads networking state, so a change that must land in networking first needs a deliberate release sequence. A push that changes only documentation still starts the plan and apply caller because that caller has no path filter.

## Plan and apply path

The shared plan job checks out the caller repository, installs the requested Terraform version, obtains AWS credentials through GitHub OIDC, and prints the AWS identity. It runs format, `terraform init`, validation, TFLint, and tfsec. It then writes a binary `tfplan` with `terraform.tfvars`, uploads it as an artifact named for the environment and component, and runs Infracost. The caller supplies Terraform `1.14.2`, `ap-south-1`, and the repository variable `AWS_TERRAFORM_ROLE_ARN`. Set that variable to the full ARN of the GitHub OIDC role in the intended AWS account before running plan, apply, or destroy.

The shared plan workflow declares `INFRACOST_API_KEY` as a required secret. Its TFLint command has `continue-on-error: true`, so lint findings do not stop that job. The tfsec step is configured with `soft_fail: false`. These are different behaviors, so do not read a green plan job as proof that every quality check was a gate.

After a push, the caller's `approval` job uses the GitHub environment named `production`. The shared apply job also names that environment. Whether a person must approve depends on the environment protection settings in GitHub, which are outside this repository. The shared apply job checks out the repository again, initializes Terraform, downloads the plan artifact from the same workflow run, and applies that saved plan. It does not create a fresh plan in the apply job.

A saved plan can contain sensitive values. In this repository, compute state includes a generated SSH private key. The plan artifact must be treated as sensitive too. The workflow currently uploads it without an explicit short `retention-days` setting. Review artifact access and retention before relying on this path for sensitive changes. The shared plan and apply jobs use `terraform init -input=false`; neither asks Terraform to keep the lock file read-only in CI.

## PR validation and destroy path

The separate `pr-validation.yml` workflow installs Terraform `1.14.2`, checks formatting, and initializes each component with `-backend=false -lockfile=readonly` before `terraform validate`. Its format step has `continue-on-error: true`. TFLint, tfsec, and Infracost are also configured in ways that can let findings or failures remain advisory. The documentation job checks that standard files exist and looks for an empty description string, which is not a full documentation review. The summary comment can therefore sound more conclusive than the checks support. This workflow is not a verified release gate yet.

The manual destroy caller accepts a component name and requires the text `DESTROY`. The shared destroy workflow checks that text, then runs `terraform destroy -auto-approve` with the selected `terraform.tfvars`. It also names the `production` GitHub environment, but any human approval depends on settings outside the code. Unlike plan and apply, the shared destroy job does not pass a Terraform version to `setup-terraform`, so its CLI version is not pinned by this caller. Review the component, account, state key, and proposed destruction before dispatching it.

## A practical review before merging

1. Confirm the plan job used the intended AWS account and region `ap-south-1`.
2. Read proposed creates, updates, deletes, and replacements for each affected root. Check networking before compute when both change.
3. Check that the state key and `for_each` keys have not changed by accident.
4. Treat the saved plan artifact and logs as sensitive, especially for compute.
5. Verify the GitHub environment protection rules and required secret before treating the workflow as an approval process.

No workflow in this repository currently deploys the bootstrap root. The active root boundaries are shown in [architecture.md](architecture.md). The state bucket that the workflows use is described in [backend.md](backend.md).
