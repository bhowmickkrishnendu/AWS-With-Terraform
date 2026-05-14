# AWS provider configuration for the specified region
provider "aws" {
    alias  = "main"
    region = var.region  # Set the AWS region based on the 'region' variable
}

# AWS IAM user resource creation
resource "aws_iam_user" "username" {
    name = "Peter_NY"  # Specify the IAM user name
    path = "/"         # Set the path for the IAM user

    tags = {
        name = "Peter ID access"  # Add a tag for better identification
    }
}

# AWS IAM access key creation for the IAM user
resource "aws_iam_access_key" "keyname" {
    user    = aws_iam_user.username.name  # Reference the created IAM user
    pgp_key = file("publicbase64.key")  # Specify the PGP key for encrypting the secret
}

# AWS IAM policy resource creation
resource "aws_iam_policy" "policy_details" {
  name        = var.user_policy_name  # Specify the name of the IAM policy
  path        = "/"                   # Set the path for the IAM policy
  description = "This is the user policy"  # Add a description for the IAM policy

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = [
                "ec2:Describe*",
            ]
            Effect   = "Allow"
            Resource = "*"
        },
    ]
  })
}

# AWS IAM user policy attachment
resource "aws_iam_user_policy_attachment" "policy_attach" {
  user        = aws_iam_user.username.name       # Reference the IAM user
  policy_arn  = aws_iam_policy.policy_details.arn  # Reference the IAM policy ARN
}

# Define Terraform Output to expose the encrypted secret and access key of the IAM access key
output "encrypted_secret_key" {
    value = aws_iam_access_key.keyname.encrypted_secret  # Expose the encrypted secret of the IAM access key
}

output "access_key" {
    value = aws_iam_access_key.keyname.id  # Expose the access key of the IAM user
}
