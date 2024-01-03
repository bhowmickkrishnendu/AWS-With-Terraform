# AWS provider configuration for the specified region
provider "aws" {
    alias  = "main"
    region = var.region  # Set the AWS region based on the 'region' variable
}

# AWS IAM role resource creation
resource "aws_iam_role" "role_details" {
    name = var.role_name              # Specify the name of the IAM role

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
        name    =  var.role_name              # Add a tag for better identification
    }
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
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:GetBucketLocation",
            ]
            Effect   = "Allow"
            Resource = "*"
        },
    ]
  })
}

# Attach IAM policy to IAM role
resource "aws_iam_role_policy_attachment" "attaching_policy" {
  policy_arn = aws_iam_policy.policy_details.arn
  role = aws_iam_role.role_details.name
}