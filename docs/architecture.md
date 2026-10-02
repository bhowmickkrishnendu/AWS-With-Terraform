# Architecture overview

This repository describes infrastructure in one AWS account and one primary region, `ap-south-1`. Terraform is split into small root configurations so a change to a bucket does not require the same state file as a change to an EC2 instance. The directory name `dev` is the existing state namespace and resource name prefix. It does not mean there is a second AWS account.

The old backup folder contains earlier examples and is not part of the active deployment.

## The pieces and how they connect

```mermaid
flowchart LR
    GH[GitHub Actions or local Terraform] --> BE[S3 state bucket]
    BE --> NS[Networking state]
    BE --> CS[Compute state]
    BE --> SS[Storage state]
    BE --> ES[ECR state, not created yet]
    BE --> KS[EKS state, not created yet]
    NS -->|VPC and subnet outputs| CS
    NS -->|planned dependency| KS
    CS --> EC2[Bastion EC2]
    CS --> SM[Secrets Manager private key]
    SS --> S3[Application S3 buckets]
```

`infrastructure/00-backend` manages the state bucket itself. Its five existing S3 resources were imported into Terraform state. That state lives at `bootstrap/terraform.tfstate` in the same bucket. Each component under `environments/dev/` has a separate state key. The bucket is versioned, encrypted with SSE-S3, and blocks public access.

| Root | Main responsibility | State key | Status on 2026-10-02 |
| --- | --- | --- | --- |
| `infrastructure/00-backend` | State bucket and its protection settings | `bootstrap/terraform.tfstate` | Imported and zero-change plan |
| `environments/dev/networking` | VPC and public and private subnets | `dev/networking/terraform.tfstate` | Deployed |
| `environments/dev/compute` | EC2, security groups, IAM instance profile, SSH key secret | `dev/compute/terraform.tfstate` | Bastion deployed |
| `environments/dev/storage` | Application S3 buckets | `dev/storage/terraform.tfstate` | Deployed |
| `environments/dev/ecr` | Container image repositories | `dev/ecr/terraform.tfstate` | Code exists, no state object in the last inventory |
| `environments/dev/eks` | Kubernetes cluster, node groups, add-ons | `dev/eks/terraform.tfstate` | Code exists, not ready to deploy |

The five component roots share a backend bucket but have separate state objects. This keeps their changes and locks apart. Compute reads the networking root outputs through `terraform_remote_state`. EKS tries to do the same, but its output names do not yet match the networking outputs. Terraform can validate the EKS syntax without proving that a live EKS plan will work.

## How to read the Terraform code

Each root has a `backend.tf` for state location, `versions.tf` for Terraform and provider constraints, and `provider.tf` for AWS region selection. A `.terraform.lock.hcl` fixes provider versions when it is included in Git. `main.tf` declares resources or calls a community module. `variables.tf` defines input types, `dev.tfvars` supplies values, and `outputs.tf` exposes results to people or another root. Compute also has `locals.tf` to build EC2 user data.

An input variable changes a root's behavior. A `local` names a calculated value within a root. `for_each` creates resources from a map, using each map key as part of the Terraform address. This repository uses it for EC2 instances, S3 buckets, ECR repositories, EKS node groups, and add-ons. Keep an existing key such as `bastion` stable unless you plan a state move. A `count` appears in the EKS OIDC resources to turn that optional feature on or off. Changing a `for_each` key or a count index can affect state addresses even if the AWS object name looks similar.

The roots pin their community module versions where modules are used. Provider versions are selected by each root's lock file. The GitHub Actions callers also pin the shared workflow repository to a commit. These pins make a reviewable starting point for later changes. They do not make a Terraform apply safe by themselves. A plan against the correct account and state is still required.

## Deployment order and current limits

1. The state bucket must exist before a new component can use its S3 backend. It already exists and its bootstrap state has been adopted.
2. Networking comes before compute because compute reads its VPC and subnet outputs.
3. Storage is independent of compute. ECR can be planned separately once its configuration is reviewed.
4. EKS depends on networking, but its current output references need correction before a deployment plan. Private subnets currently have no NAT gateway, so a future EKS design must also provide the network path its nodes and add-ons need.

The automatic plan and apply workflow matrices currently contain networking and compute only. Other roots being present in source code does not mean they are deployed. IAM Identity Center, RDS, Lambda, SNS, and the other services in the long-term goal do not yet have active roots here. See [pipeline.md](pipeline.md) for the actual triggers and release risks.

The key design rule is to preserve existing state keys and deployed resource addresses while improving the code. The current networking, compute, storage, and bootstrap plans were checked with zero proposed resource changes during the foundation work. Compute and storage did report drift notices, which deserve review before a future change to those resources.

For details, read [backend.md](backend.md), [networking.md](networking.md), [compute.md](compute.md), and [storage.md](storage.md).
