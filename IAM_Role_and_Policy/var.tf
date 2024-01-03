# Define the variable for the AWS region (Mumbai)
variable "region" {
    description = "This variable specifies the AWS Mumbai region"
    default     = "ap-south-1"  # Set the default AWS region to Mumbai (ap-south-1)
}

# Define the variable for the IAM role name
variable "role_name" {
    default = "Bucket Control"  # Set the default IAM role name to 'Bucket Control'
}

# Define the default policy name for IAM user
variable "user_policy_name" {
    default = "s3_Policy"
}
