# Terraform workflows

`terraform-plan.yml` runs on pull requests to `main` or `master`. `terraform-apply.yml` runs on pushes to those branches, plans first, then waits for the `production` GitHub environment gate before calling the apply workflow. Their matrices currently include `networking` and `compute` only. Review both matrices before enabling another root.

`terraform-destroy.yml` is a manual workflow and requires the `DESTROY` input. Its component list includes roots that are not in the automatic plan/apply matrices, so review the selected component and its state before dispatching it.

The three callers use reusable workflows from `bhowmickkrishnendu/terraform-gha-workflows` pinned to commit `5c384e29866d4f2d647536b86e64ea2b17dfb018`. Plan and apply request Terraform `1.14.2`, `ap-south-1`, and the GitHub OIDC role `arn:aws:iam::234617061868:role/github-actions-terraform-role`. The destroy caller uses the same region. The shared repository owns the implementation of its reusable jobs; changes there require a new reviewed commit pin here.

`pr-validation.yml` performs formatting, initialization with provider lock files, validation, and advisory static/security/cost checks. Its advisory checks do not yet establish a release gate. A separate pipeline audit is planned before relying on those results. See [pipeline.md](../../docs/pipeline.md) for the current workflow behavior and the [repository README](../../Readme.md) for the live deployment boundaries.
