# IAM role module

This module creates one IAM role from the trust principals and conditions supplied by its caller. Set `create_instance_profile = true` when an EC2 instance will use the role. The module returns the role name and ARN, plus the profile name and ARN when a profile exists.

```hcl
module "app_vm_role" {
  source                  = "../../modules/iam-role"
  name                    = "example-app-vm-role"
  create_instance_profile = true
  trust = {
    principals = { Service = ["ec2.amazonaws.com"] }
  }
}
```

The module does not attach permission policies. Attach only the policies the role needs in the calling root. The role and optional profile have `prevent_destroy`; retiring either requires a reviewed code and state change. See the [IAM root guide](../../docs/iam.md) and the [IAM to compute example](../../examples/iam-compute/README.md).
