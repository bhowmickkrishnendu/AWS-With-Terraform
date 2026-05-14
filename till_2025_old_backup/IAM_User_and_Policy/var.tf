# Define the variable for the AWS region (Mumbai)
variable "region" {
    description = "This AWS Mumbai region"
    default     = "ap-south-1"
}

# Define the default policy name for IAM user
variable "user_policy_name" {
    default = "Peter_NY_Policy"
}
