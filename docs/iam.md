# Reusable IAM roles, policies, and users

The `stacks/iam` root is an optional IAM workspace. Its input maps are empty by default, so it does not create a role, policy, user, or attachment until you add one. It contains no account number, GitHub repository, OIDC provider, or existing IAM role name. The current GitHub Actions role and the bastion role remain owned where they are today.

The root uses three small local modules. `modules/iam-role` creates a role from the trust principals and conditions you give it. Set `create_instance_profile = true` for an EC2 role, then use the `instance_profile_names` output when a future VM needs it. `modules/iam-policy` creates a customer-managed policy from named statements. Each statement names its actions and resources. A bare `*` action is rejected, and a bare `*` resource needs `allow_all_resources = true`. `modules/iam-user` creates an IAM user without a console password or access key. Attach policies with the two attachment maps, which accept either a policy key from this root or an existing policy ARN.

Each module has a short guide: [role](../modules/iam-role/README.md), [policy](../modules/iam-policy/README.md), and [user](../modules/iam-user/README.md). The [IAM to compute example](../examples/iam-compute/README.md) shows the full path from a new EC2 role and instance profile to a new VM. It leaves the running bastion role in compute.

The role, policy, user, and instance-profile resources have `prevent_destroy` so removing a map entry cannot silently delete them. A deliberate retirement needs a reviewed plan and a deliberate change to that lifecycle rule. Keep map keys stable because they form Terraform state addresses. IAM is account-wide, so one root can serve roles and users for several workloads. Use narrow actions and resource ARNs for each policy.

## Check the code without changing AWS

From the repository root, run:

```powershell
terraform -chdir=stacks/iam init -backend=false -input=false
terraform -chdir=stacks/iam fmt -check
terraform -chdir=stacks/iam validate
terraform -chdir=stacks/iam test
```

`stacks/iam/example.tfvars` shows one EC2 role, one S3 read policy, one IAM user, and two attachments. Terraform does not load that file automatically. Replace its example names and bucket ARN before planning it against a real account.

## Use remote state when you decide to create IAM resources

The S3 backend is intentionally partial. Give it your own bucket, key, and Region at initialization. Choose a new state key that is not used by another Terraform root. For example:

```powershell
$env:AWS_PROFILE = 'YOUR_PROFILE'
terraform -chdir=stacks/iam init -input=false `
  -backend-config='bucket=YOUR_STATE_BUCKET' `
  -backend-config='key=iam/terraform.tfstate' `
  -backend-config='region=YOUR_REGION' `
  -backend-config='use_lockfile=true' `
  -backend-config='encrypt=true'
terraform -chdir=stacks/iam plan -input=false -var-file=example.tfvars
```

Check the AWS identity and plan before any apply. Do not import an existing role or user into this root without reviewing ownership and state first. No existing OIDC provider or role is imported by this code.

IAM Identity Center account access is a separate manual setup in the AWS Organizations management account. This root manages IAM users, not Identity Center users. For human AWS access, use Identity Center when it is enabled. The current bastion still uses a Terraform-generated SSH private key in compute state. Future key changes should be planned separately so the running bastion is not replaced.
