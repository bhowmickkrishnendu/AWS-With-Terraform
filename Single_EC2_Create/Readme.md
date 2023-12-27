# Terraform Configuration for Mumbai VPC

This Terraform configuration defines an AWS Virtual Private Cloud (VPC) in the Mumbai region, including public and private subnets, route tables, and an Internet Gateway.

## Prerequisites

Before you begin, ensure you have:

- [Terraform](https://www.terraform.io/) installed on your machine.
- Appropriate AWS credentials configured.

## Configuration

### Variables

- **region**: The AWS region where the Mumbai VPC will be created.
- **availability_zone**: The Availability Zone for the public subnet.
- **availability_zone1**: The Availability Zone for the private subnet.

Example variables in `var.tf`:
```hcl
variable "region" {
  description = "This is the Mumbai region"
  default     = "ap-south-1"
}

variable "availability_zone" {
  description = "This is Mumbai region, Availability Zone 'a'"
  default     = "ap-south-1a"
}

variable "availability_zone1" {
  description = "This is Mumbai region, Availability Zone 'b'"
  default     = "ap-south-1b"
}
````

## Resources
- **VPC**: Defines the main AWS Virtual Private Cloud.
- **Subnets**: Creates public and private subnets within the VPC.
- **Internet Gateway**: Establishes an Internet Gateway for the VPC.
- **Route Tables**: Sets up route tables for public and private subnets.
- **Route Table Associations**: Associates route tables with respective subnets.

Example resource definitions in the Terraform script:
````hcl
# Resource block for VPC
resource "aws_vpc" "Mumbai_First_VPC" {
    cidr_block          = "10.0.0.0/16"
    enable_dns_support  = true
    enable_dns_hostnames = true
    tags = {
        Name = "Mumbai_First_VPC"
    }
}

# Resource block for public subnet
resource "aws_subnet" "Mumbai_First_VPC_Public_Subnet" {
    vpc_id                  = aws_vpc.Mumbai_First_VPC.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = var.availability_zone
    map_public_ip_on_launch = true
    tags = {
        Name = "Mumbai_First_VPC_Public_Subnet"
    }
}

# ... Additional resource blocks for private subnet, Internet Gateway, route tables, and associations
````

## Outputs
- **vpc_id**: Outputs the ID of the created VPC.
- **public_subnet**: Outputs the ID of the public subnet.
- **private_subnet**: Outputs the ID of the private subnet.
Example output definitions in the Terraform script:
````
# Output block for VPC ID
output "vpc_id" {
  value = aws_vpc.Mumbai_First_VPC.id
}

# Output block for public subnet ID
output "public_subnet" {
    value = aws_subnet.Mumbai_First_VPC_Public_Subnet.id
}

# Output block for private subnet ID
output "private_subnet" {
    value = aws_subnet.Mumbai_First_VPC_Private_Subnet.id
}

````

## Usage
- **1**. Clone this repository.
- **2**. Update the variables in var.tf if needed.
- **3**. Run terraform init to initialize your working directory.
- **4**. Run terraform apply to apply the configuration and create the Mumbai VPC.

## Outputs
After successfully applying the configuration, you can retrieve the outputs:

VPC ID: terraform output vpc_id

Public Subnet ID: terraform output public_subnet

Private Subnet ID: terraform output private_subnet

## Clean Up
To destroy the created resources and clean up, run:
```hcl
terraform destroy
```




## License
This Terraform configuration is licensed under the MIT License.
[MIT](https://choosealicense.com/licenses/mit/)

