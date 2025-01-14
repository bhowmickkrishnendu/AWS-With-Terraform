# AWS IAM Role and Policy Module
# This module creates an IAM role and policy in AWS, allowing for the management of permissions and access control.
resource "aws_iam_role" "role_details" {
  name = var.role_name              # Specify the name of the IAM role

  # Use the template file for assume role policy
  assume_role_policy = file("${path.module}/assume_role_policy.json.tpl")

  tags = {
    name    = var.role_name              # Add a tag for better identification
  }
  
}

# AWS IAM policy resource creation
resource "aws_iam_policy" "policy_details" {
    name        = var.user_policy_name  # Specify the name of the IAM policy
    path        = "/"                   # Set the path for the IAM policy
    description = "This is the user policy"  # Add a description for the IAM policy
    
    # Use the template file for user policy
    policy = file("${path.module}/user_policy.json.tpl")
}

# Attach IAM policy to IAM Role
