# Terraform CI/CD Pipeline with GitHub Actions

This repository implements a robust CI/CD pipeline for Terraform using GitHub Actions. The workflow automates Terraform operations such as `init`, `validate`, `plan`, `apply`, and `destroy` with manual review gates for enhanced security and compliance.

## Workflow Overview

- **Trigger Events:**
  - On pull requests to the `master` branch
  - Manually via the GitHub Actions UI (`workflow_dispatch`)

- **Environment Variable:**
  - `AWS_REGION` is set to `ap-south-1`

- **Jobs:**
  1. **init**: Initializes Terraform in the specified working directory using a reusable workflow.
  2. **validate**: Validates Terraform configuration.
  3. **plan**: Generates and outputs the Terraform execution plan.
  4. **plan-review**: Manual review gate. Requires human approval before proceeding to apply or destroy. Prompts reviewers to check for:
     - No unexpected resource deletions
     - No unwanted resource recreations
     - Safe IAM policy changes
     - Security group modifications
     - Network/VPC changes
     - Database/storage changes
     - Resource naming changes
  5. **apply**: Applies the Terraform plan (on PR merge or manual dispatch with `apply` action).
  6. **destroy**: Destroys resources (only on manual dispatch with `destroy` action).

- **Reusable Workflows:**
  - All Terraform steps (`init`, `validate`, `plan`, `apply`, `destroy`) use reusable workflows from [bhowmickkrishnendu/terraform-gha-workflows](https://github.com/bhowmickkrishnendu/terraform-gha-workflows).

- **Secrets:**
  - `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are required and must be set in the repository secrets.

## Usage

### 1. Pull Request
- On PR to `master`, the pipeline runs through `init`, `validate`, `plan`, and waits for manual review before applying changes.

### 2. Manual Dispatch
- Go to the Actions tab, select the workflow, and choose `apply` or `destroy` as the action.
- The pipeline will run up to the plan-review step and wait for manual approval before proceeding.

## Working Directory
- All Terraform actions are performed in:  
  `v2_2025/AWS-Main/IAM_Role_Policy_Root`

## Customization
- You can modify the working directory or extend the workflow as needed for your project structure.

## References
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)

---

**Maintainer:** [bhowmickkrishnendu](https://github.com/bhowmickkrishnendu)
