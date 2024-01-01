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
    pgp_key = file("gpg_public_base64.key")  # Specify the PGP key for encrypting the secret
}

# Define Terraform Output to expose the encrypted secret of the IAM access key
output "secret" {
    value = aws_iam_access_key.keyname.encrypted_secret  # Expose the encrypted secret of the IAM access key
}
