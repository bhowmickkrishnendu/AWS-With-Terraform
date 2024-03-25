provider "aws" {
  region = var.region
  alias = "main"
}

resource "aws_key_pair" "keyname" {
  key_name = "${var.instance_name}"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

