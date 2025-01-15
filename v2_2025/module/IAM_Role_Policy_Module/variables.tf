variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "role_name" {
  description = "The name of the IAM role to create"
  type        = string
  default     = "Bucket-Control"
}

variable "user_policy_name" {
  description = "The name of the IAM policy create"
  type = string
  default = "s3_policy"
}