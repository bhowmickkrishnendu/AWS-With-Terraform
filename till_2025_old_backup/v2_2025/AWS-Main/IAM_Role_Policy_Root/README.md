<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_role_policy"></a> [iam\_role\_policy](#module\_iam\_role\_policy) | D:\my_github\AWS-With-Terraform\v2_2025\module\IAM_Role_Policy_Module | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | This is  the AWS region to create resources | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The name of the IAM role to create. | `string` | n/a | yes |
| <a name="input_user_policy_name"></a> [user\_policy\_name](#input\_user\_policy\_name) | The name of IAM policy to create. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->