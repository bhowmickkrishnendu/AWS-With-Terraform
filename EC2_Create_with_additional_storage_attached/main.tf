# AWS provider configuration
provider "aws" {
    region = var.region                                             # Set the AWS region based on the 'region' variable
    alias  = "main"
}