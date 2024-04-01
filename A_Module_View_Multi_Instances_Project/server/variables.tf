variable "region" {
  default = "ap-south-1"
}

variable "instance_name" {
  default = "java_app_server"
}

variable "amazon_linux_2023_ami" {
  default = "ami-0ec0e125bb6c6e8ec"
}

variable "vpc_id" {
  default = "vpc-0243e953b038c0d1f"
}

variable "public_subnet_id" {
  default = "subnet-04d2127613eb2e422"
}

variable "t2micro" {
  default = "t2.micro"
}