# Configure the AWS provider with an alias "main" and set the region based on the 'region' variable
provider "aws" {
  alias = "main"
  region = var.region
}

# Define an AWS VPC resource named "Mumbai_First_VPC"
resource "aws_vpc" "Mumbai_First_VPC" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "Mumbai_First_VPC"
    }
}