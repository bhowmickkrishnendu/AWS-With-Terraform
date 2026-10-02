# Application storage design

The storage root manages application S3 buckets. It is separate from the S3 bucket that holds Terraform state. Its state key is `dev/storage/terraform.tfstate`, and its current `dev.tfvars` names two application buckets: `krish-dev-app-data` and `krish-dev-dev-assets`.

## How buckets are described

`var.buckets` is a map keyed by the real bucket name. `module.app_buckets` uses `for_each` over that map and calls version `5.16.1` of the community S3 bucket module. Adding a map entry asks Terraform to manage another bucket. Removing or renaming a key changes a Terraform address, and because the key is also the bucket name, it can mean a different AWS bucket. Review the plan and any data in the bucket before such a change.

Each module instance enables versioning and sets default server-side encryption to AES256. `force_destroy = false` means Terraform will not empty a nonempty bucket for deletion. It is not a blanket ban on deleting an empty bucket. Tags include `Environment` and `ManagedBy`, with `ManagedBy = Terraform` in this root. The state bucket uses different code and `ManagedBy = terraform`, so there is no single tag convention yet.

`public` is an optional Boolean value for each bucket. It defaults to `false`. Both current entries use that default, so no public-read policy is selected by this configuration. The `try` calls in `main.tf` handle an omitted `public` value and choose the private path.

| Setting | `public = false` | `public = true` |
| --- | --- | --- |
| Bucket public access block flags | All four are true | All four are false |
| `aws_s3_bucket_policy.public_read` | No policy resource from this root | Adds a policy for public object reads over HTTPS |
| Versioning and AES256 encryption | Enabled | Enabled |

The policy for a public bucket denies all S3 actions over insecure transport and allows `s3:GetObject` for everyone over HTTPS. It does not grant public list access. An account-level public access block or another AWS control can still prevent public access. Setting `public = true` is therefore both a security decision and a change that needs an AWS-level verification after apply. There is no public bucket enabled in the current values.

`locals.public_buckets` filters the bucket map down to entries with `public = true`. The policy resource uses `for_each` over that filtered map. This is why a private bucket has no policy resource at that address. `outputs.tf` returns maps of bucket names and ARNs plus the list of public bucket keys.

## Operating the root

The root takes `aws_region`, `environment`, and `buckets`. `provider.tf` uses the region input. `backend.tf` keeps storage state separate from the state bucket's own bootstrap state. The last live plan proposed zero adds, changes, or removals, but Terraform reported drift notices for the two buckets and their versioning resources. That notice is not a request to apply; compare live settings, state, and the next plan before editing those resources.

```powershell
$env:AWS_PROFILE = 'terraform-dev'
terraform -chdir=environments/dev/storage init -lockfile=readonly -input=false
terraform -chdir=environments/dev/storage validate
terraform -chdir=environments/dev/storage plan -var-file=dev.tfvars -input=false
```

The current code does not configure bucket lifecycle rules, replication, access logging, or object lock for application buckets. Those are design choices to make per data class, not properties to assume from versioning alone. For Terraform state storage, see [backend.md](backend.md).
