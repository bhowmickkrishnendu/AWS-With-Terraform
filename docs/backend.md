# Terraform backend and state bucket

Terraform state records which AWS object belongs to each resource address in code. Without the right state, Terraform may propose creating a bucket or instance that already exists. This happened with the bootstrap root before its state was adopted. The five existing bucket resources are now imported, and the last plan from the S3 backend proposed zero changes.

## What this root manages

`bootstrap` owns the bucket `krish-terraform-state-ap-south-1` and four separate settings:

| File | Resource | Purpose |
| --- | --- | --- |
| `s3.tf` | `aws_s3_bucket.terraform_state` | Names and tags the state bucket; `prevent_destroy` blocks a Terraform destroy of this bucket |
| `s3-versioning.tf` | `aws_s3_bucket_versioning.terraform_state` | Keeps versions of state objects for recovery |
| `s3-encryption.tf` | `aws_s3_bucket_server_side_encryption_configuration.terraform_state` | Uses AES256 server-side encryption by default |
| `s3-public-access.tf` | `aws_s3_bucket_public_access_block.terraform_state` | Enables all four public access block settings |
| `s3-lifecycle.tf` | `aws_s3_bucket_lifecycle_configuration.terraform_state` | Expires noncurrent object versions after 30 days |

`provider.tf` sets `ap-south-1`. It does not name a laptop profile, so local AWS CLI credentials or the GitHub OIDC role can supply identity. `versions.tf` sets Terraform and AWS provider constraints. The provider lock file selects the exact installed provider version until it is intentionally updated.

## Where the state lives

The bucket contains `bootstrap/terraform.tfstate` for this root and separate `dev/<component>/terraform.tfstate` objects for component roots. Each root's `backend.tf` names its own key, sets `encrypt = true`, and enables S3 lockfiles with `use_lockfile = true`. A state lock helps prevent two Terraform writers from changing the same state at once. The component roots do not share one state file.

The bootstrap state lives in the bucket that it manages. This works because the bucket existed before migration. It also means the bucket must remain available for Terraform to read its own state. The `prevent_destroy` guard protects the bucket resource from Terraform deletion, but it does not protect against every AWS action or every unsafe configuration change. Review any plan that touches this root carefully.

State may contain sensitive values. Compute state includes a generated SSH private key even though that key is also saved in Secrets Manager. Never commit state, a binary plan, or a downloaded state object. S3 versioning offers a recovery path, but the 30-day rule removes old noncurrent versions. Local recovery files for the bootstrap migration are kept in ignored `.phase1-private/` on the maintainer's machine.

## How the bucket was adopted

At first, the AWS bucket and its settings existed but this root had no state file. Terraform therefore proposed five creates. The account, region, bucket tags, versioning, encryption, public access block, and lifecycle were checked in AWS. Each of the five existing resources was imported under its matching address using the bucket name as the import ID. A local recovery copy was saved before the state was moved to the unused `bootstrap/terraform.tfstate` key. The new object was confirmed to be versioned and AES256 encrypted. A remote state read found all five addresses, and the final plan proposed zero adds, changes, or removals. No AWS infrastructure resource was created by the import or migration.

## Safe local checks

From the repository root in PowerShell, use the intended AWS CLI profile and confirm the account before planning:

```powershell
$env:AWS_PROFILE = 'terraform-dev'
aws sts get-caller-identity --query Account --output text
terraform -chdir=bootstrap init -lockfile=readonly -input=false
terraform -chdir=bootstrap validate
terraform -chdir=bootstrap state list
terraform -chdir=bootstrap plan -input=false
```

The expected account is the one that owns the state bucket. The state list should have the five resources in the table above. If the plan proposes creating the bucket or changing its protection settings, stop and check the backend key, AWS identity, state version, and live settings before doing anything else. Do not run `init -migrate-state` again as a routine initialization step.

For the wider root layout, see [architecture.md](architecture.md). For the bucket used by applications, see [storage.md](storage.md).
