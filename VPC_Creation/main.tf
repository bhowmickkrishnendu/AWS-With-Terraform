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

# Create a public subnet in the Mumbai VPC
resource "aws_subnet" "Mumbai_First_VPC_Public_Subnet" {
    vpc_id = aws_vpc.Mumbai_First_VPC.id
    cidr_block = "10.0.1.0/24"
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
    tags = {
      Name = "Mumbai_First_VPC_Public_Subnet"
    }
  
}

# Create a private subnet in the Mumbai VPC
resource "aws_subnet" "Mumbai_First_VPC_Private_Subnet" {
    vpc_id = aws_vpc.Mumbai_First_VPC.id
    cidr_block = "10.0.2.0/24"
    availability_zone = var.availability_zone1
    tags = {
        Name = "Mumbai_First_VPC_Private_Subnet"
    } 
}

# Create an Internet Gateway for the Mumbai VPC
resource "aws_internet_gateway" "Mumbai_First_VPC_IGW" {
    vpc_id = aws_vpc.Mumbai_First_VPC.id
    tags = {
      Name = "Mumbai_First_VPC_IGW"
    }
  
}