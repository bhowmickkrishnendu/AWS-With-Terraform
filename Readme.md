# AWS with Terraform

This repository is a working Terraform project for one AWS account in `ap-south-1`. It separates the state bucket, VPC, EC2, and application buckets into small Terraform roots. Code for ECR and EKS is present, but those roots were not deployed at the last verified inventory. The `dev` prefix remains in existing state keys and resource names; it does not mean there is a second AWS account.

`bootstrap/` manages the state bucket. Each directory in `stacks/` is a separate runnable Terraform root with its own state key. `modules/` holds reusable code and is not applied directly. The old `shared/versions.tf` file was removed because Terraform does not load files from another root automatically. Each root keeps its own version requirements and provider lock file.

The old backup folder contains earlier examples and is not part of the active deployment.

## Start here

| Read | When you need to know |
| --- | --- |
| [Architecture overview](docs/architecture.md) | How the roots, state files, AWS services, and dependencies fit together |
| [Backend and state](docs/backend.md) | How the state bucket protects Terraform state and how the existing bucket was adopted |
| [Networking](docs/networking.md) | VPC, subnets, routing choices, outputs, and current network limits |
| [Compute](docs/compute.md) | Bastion EC2, IAM, security groups, SSH keys, user data, and EBS design |
| [Reusable IAM](docs/iam.md) | Optional roles, policies, users, and policy attachments |
| [Storage](docs/storage.md) | Application buckets, encryption, versioning, and public access choices |
| [Pipeline](docs/pipeline.md) | GitHub Actions triggers, shared workflows, plan artifacts, approval path, and gaps |

The Phase 0, Phase 1, and Phase 2 working records and inventory scripts are kept locally by the maintainer and ignored by Git.

## What exists today

| Terraform root | Purpose | Current position |
| --- | --- | --- |
| `bootstrap` | S3 state bucket, encryption, versioning, public access block, lifecycle | Existing resources imported; state at `bootstrap/terraform.tfstate` |
| `stacks/iam` | Reusable IAM roles, policies, users, and attachments | Optional; empty inputs create nothing |
| `stacks/networking` | VPC with public and private subnets in two availability zones | Deployed; optional NAT and VPC endpoints remain disabled |
| `stacks/compute` | Bastion EC2, security groups, IAM instance profile, SSH key secret | Bastion deployed |
| `stacks/storage` | Two application S3 buckets | Deployed |
| `stacks/ecr` | Container image repositories and retention rules | Code exists; no state object in the last inventory |
| `stacks/eks` | Cluster, node group, IAM, OIDC, and add-ons | Code exists; needs network output fixes before deployment |

The bootstrap, networking, compute, and storage roots each had a zero-change plan during the foundation review. Compute and storage also showed drift notices. Phase 2 now defines each VM's security group and IAM settings in its VM block while keeping direct SSH to the public bastion. The current network values leave NAT and the S3 gateway endpoint disabled. Review a fresh compute plan before any apply because the refactor moves state addresses and removes the EC2 module's extra security group. Networking comes before compute because compute reads networking outputs from remote state. The automatic GitHub plan and apply matrices currently include networking and compute only.

## Work locally

Install Terraform `1.14.2` and AWS CLI. Authenticate to the intended account. The local AWS CLI profile used for the checks is `terraform-dev`. Provider configuration uses the normal AWS credential chain, so a different trusted profile or role can be used without editing Terraform files.

From PowerShell in the repository root, check identity and run a read-only plan for one component:

```powershell
$env:AWS_PROFILE = 'terraform-dev'
aws sts get-caller-identity --query Account --output text
terraform -chdir=stacks/networking init -lockfile=readonly -input=false
terraform -chdir=stacks/networking validate
terraform -chdir=stacks/networking plan -input=false
```

Replace `networking` with `compute` or `storage` after reading that root's documentation. Each root has its own `backend.tf`, `versions.tf`, provider lock file, inputs, and outputs. The active VPC, EC2, and S3 community module versions are pinned. Include the active `.terraform.lock.hcl` files in a commit so another machine selects the same provider builds. Keep existing backend keys and `for_each` keys stable unless a state migration is planned.

The state bucket manages its own imported state through a separate S3 key. Its bucket resource has `prevent_destroy = true`. Review any bootstrap plan closely. Never commit state files, saved plans, AWS credentials, or private keys. Compute state contains a generated SSH private key, and a saved compute plan can contain sensitive data too. Ignored `.phase0-private/` and `.phase1-private/` hold local recovery data.

## Delivery and next work

The caller workflows pin a commit of the shared `terraform-gha-workflows` repository. Set the repository Actions variable `AWS_TERRAFORM_ROLE_ARN` to the full GitHub OIDC role ARN for your account before using them. Pull requests start plan jobs; pushes to `main` or `master` can reach the apply path after its GitHub environment job. A separate manual workflow can destroy a selected component. GitHub environment rules and actual run results need to be checked in GitHub, and the pipeline still has ordering and artifact-handling gaps described in [pipeline.md](docs/pipeline.md).

Current code is a base for the larger goal, not a claim that every planned AWS service is already integrated. EKS output references need correction, and private network egress is still disabled by the current Phase 2 values. IAM Identity Center, RDS, Lambda, SNS, and other planned services need their own reviewed roots or modules. Make each change in a small step, compare its plan with live state, and keep the running bastion and current state addresses intact.
