# Recovering Terraform deployments

This guide covers the state bucket and the deployed networking, storage, and compute stacks. Keep Terraform state, saved plans, private keys, and recovery files out of Git and public logs. The state bucket has versioning, encryption, public access block, and S3 lockfiles. The existing state keys remain under `dev/`.

## Before changing anything

1. Stop new deployment and destroy runs. Let any active apply finish or establish exactly where it stopped.
2. Confirm the AWS account and Region with the intended local profile. Use `terraform-dev` only if it points to the correct account.
3. Identify the affected stack, the Git commit used by the run, the state key from its `backend.tf`, and the last known good state object version. Record this information privately.
4. Inspect the failed job's plan summary and AWS resources. A failed apply can leave resources changed even when the state file is older.
5. Do not restore a state object just to silence a plan. First decide whether to repair or import the live resource, revert the configuration, or restore an earlier state version.

Run read-only checks from the repository root. Replace `networking` with `storage` or `compute` as needed:

```powershell
$env:AWS_PROFILE = 'terraform-dev'
aws sts get-caller-identity --query Account --output text
terraform -chdir=stacks/networking init -input=false -lockfile=readonly
terraform -chdir=stacks/networking state list
terraform -chdir=stacks/networking plan -input=false
```

Never paste state, a saved plan, or the compute SSH private key into a ticket or chat. The plan job uploads a saved plan only when changes exist and retains it for one day. The apply job checks its SHA256 digest before use. If approval takes longer than one day, rerun from a new commit or workflow run so the plan is fresh.

## Find a recoverable state version

Read the bucket and key from the affected root's `backend.tf`. The current deployed keys are `dev/networking/terraform.tfstate`, `dev/storage/terraform.tfstate`, and `dev/compute/terraform.tfstate`. The bootstrap root has its own key, `bootstrap/terraform.tfstate`.

```powershell
$bucket = '<STATE_BUCKET_FROM_BACKEND_TF>'
$key = 'dev/networking/terraform.tfstate'
aws s3api head-object --bucket $bucket --key $key --query '{VersionId:VersionId,LastModified:LastModified,ServerSideEncryption:ServerSideEncryption}' --no-cli-pager
aws s3api list-object-versions --bucket $bucket --prefix $key --query 'Versions[].{VersionId:VersionId,LastModified:LastModified,IsLatest:IsLatest,Size:Size}' --no-cli-pager
```

The maintainer also has local Phase 0 recovery metadata and server-side copies under a `phase0-backup/` prefix. Those records are local-only. Check object versions and backups before selecting any restore point. A state version is a record of Terraform's knowledge, not a backup of the AWS resources themselves.

## Recover safely

- If code changed but AWS did not, restore the previous Git commit and run a new plan. Keep the same backend key and resource addresses.
- If AWS changed outside Terraform, inspect the normal and refresh-only plans. Use a reviewed configuration change or a targeted import when needed.
- If an apply stopped partway through, inspect the live resources and the newest state version together. Do not blindly replay the old saved plan.
- If the state object is lost or corrupt, prepare a separate recovery copy of the selected S3 version. Compare its resource addresses with live AWS before replacing the active object. A mistaken state rollback can make Terraform propose duplicate creates or deletions. Have a second person review this step.
- For the bootstrap state bucket itself, do not destroy or recreate the bucket as a recovery shortcut. Its Terraform resource uses `prevent_destroy`. Keep versioning and access controls intact.

After repair, run `terraform validate` and a fresh normal plan for the affected stack. Check creates, updates, deletes, replacements, backend key, and `for_each` keys. For networking changes, review compute next because compute reads networking state. Re-enable deployment only when the plan is understood.

## GitHub Actions controls

PR checks run on every pull request and the single `PR checks` job should be required by the protected `master` branch. Post-merge deployment plans networking, storage, and compute in sequence. Each stack with changes waits at its own protected environment, `apply-networking`, `apply-storage`, or `apply-compute`. Manual destroy uses separate `destroy-<component>` environments and a typed confirmation. The reusable apply and destroy jobs stop if the selected environment has no required reviewers.

See [pipeline.md](pipeline.md) for the exact workflow paths, inputs, and setup checks. The weekly drift workflow reports addresses and actions only. It does not save a plan or update state. Investigate any failed drift run before accepting a new deployment plan.
