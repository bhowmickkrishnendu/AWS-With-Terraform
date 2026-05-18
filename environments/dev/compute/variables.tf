variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "bastion_ssh_cidr" {
  type = string
}

variable "public_key" {
  type      = string
  sensitive = true
}

variable "ami_id" {
  type = string
}