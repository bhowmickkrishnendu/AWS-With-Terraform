# AWS IAM User and Policy Management

This Terraform configuration sets up an IAM user, access key, and custom policy in AWS.

## Resources

- `aws_iam_user`: Creates an IAM user named `Peter_NY` 
- `aws_iam_access_key`: Creates an access key for the `Peter_NY` IAM user. The secret key is encrypted using the provided PGP key
- `aws_iam_policy`: Creates a custom IAM policy called `user_policy_name` that allows read-only EC2 access
- `aws_iam_user_policy_attachment`: Attaches the custom IAM policy to the `Peter_NY` IAM user

## Outputs  

- `encrypted_secret_key`: The encrypted secret access key for the `Peter_NY` user
- `access_key`: The access key ID for the `Peter_NY` user

## Usage

1. Set AWS credentials in the provider
2. Update `region` and `user_policy_name` variables 
3. Provide path to public PGP key for encrypting the secret access key 
4. Run `terraform apply` to create resources
5. Access keys and ARNs can be referenced in other Terraform resources

This config sets up core IAM resources to create limited privilege IAM users with custom policies for access control.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.