# AWS provider configuration for the specified region
provider "aws" {
    alias  = "main"
    region = var.region  # Set the AWS region based on the 'region' variable
}

# AWS IAM role resource creation
resource "aws_iam_role" "role_name" {
    name = "Bucket Control"  # Specify the name of the IAM role

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = ""
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })

    tags = {
        name    =  "Bucket Control"  # Add a tag for better identification
    }
}
