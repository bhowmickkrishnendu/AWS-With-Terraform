# AWS Provider configuration
provider "aws" {
    alias  = "main"
    region = var.region  # Set the AWS region based on the 'region' variable  
}

