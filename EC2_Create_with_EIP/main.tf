# AWS provider configuration
provider "aws" {
  alias = "main"
  region = var.region
}

# AWS key pair resource for secure SSH access
resource "aws_key_pair" "Mumbai_First_Server" {
    key_name = "Mumbai_First_Server"
    public_key = tls_private_key.rsa.public_key_openssh
}

# TLS private key resource for the AWS key pair
resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits = 4096
}

# Local file resource to save the private key locally
resource "local_file" "Mumbai_Key" {
    content = tls_private_key.rsa.private_key_pem
    filename = "Mumbai_First_Server.pem"
}
