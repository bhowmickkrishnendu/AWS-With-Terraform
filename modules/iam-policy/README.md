# IAM policy module

This module creates one customer-managed IAM policy from named statements. Each statement supplies actions and resources, with optional conditions. It returns the policy name and ARN. A bare `*` action is rejected, and a bare `*` resource needs `allow_all_resources = true`.

```hcl
module "bucket_read" {
  source      = "../../modules/iam-policy"
  name        = "example-bucket-read"
  description = "Read objects from one bucket"
  statements = {
    ReadObjects = {
      actions   = ["s3:GetObject"]
      resources = ["arn:aws:s3:::replace-with-your-bucket/*"]
    }
  }
}
```

Replace the bucket name and review the resulting policy before use. This module creates the policy but does not attach it to a role or user. The policy has `prevent_destroy`. See the [IAM root guide](../../docs/iam.md) for attachments.
