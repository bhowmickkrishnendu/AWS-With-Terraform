variable "region" {
  description = "This is  the AWS region to create resources"
  type = string
}

variable "role_name" {
  description = "The name of the IAM role to create."
  type = string
}

variable "user_policy_name" {
  description = "The name of IAM policy to create."
  type = string
}