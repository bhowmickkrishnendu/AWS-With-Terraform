variable "environment" {
  description = "Existing state namespace and resource name prefix. Keep dev for the deployed stack."
  type        = string
}

variable "aws_region" {
  description = "AWS region for the networking stack."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block of the VPC."
  type        = string
}
