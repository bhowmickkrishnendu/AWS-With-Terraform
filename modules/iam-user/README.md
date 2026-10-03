# IAM user module

This module creates one IAM user and returns its name and ARN. It does not create a console password, access key, or policy attachment. Use a role or IAM Identity Center for human access when possible.

```hcl
module "integration_user" {
  source = "../../modules/iam-user"
  name   = "example-integration-user"
}
```

The caller can set a path, tags, or permissions boundary and attach a reviewed policy separately. The user has `prevent_destroy` and `force_destroy = false`, so removing it requires a deliberate retirement. See the [IAM root guide](../../docs/iam.md).
