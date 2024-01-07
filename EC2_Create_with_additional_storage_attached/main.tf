# AWS provider configuration
provider "aws" {
    region = var.region                                             # Set the AWS region based on the 'region' variable
    alias  = "main"
}

# AWS key pair resource for secure SSH access
resource "aws_key_pair" "Mumbai_First_Server" {
    key_name   = "Mumbai_First_Server"
    public_key = tls_private_key.rsa.public_key_openssh
}

# TLS private key resource for the AWS key pair
resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits  = 4096
}