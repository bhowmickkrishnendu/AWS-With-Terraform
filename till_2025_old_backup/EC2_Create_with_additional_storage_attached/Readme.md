# Terraform AWS EC2 Instance Deployment

This Terraform configuration deploys an Amazon EC2 instance in AWS with specific configurations for secure SSH access and additional Elastic Block Store (EBS) volumes.

## Prerequisites

1. **AWS Account**: Ensure you have an AWS account and the necessary credentials.

2. **Terraform**: Install Terraform on your local machine. Refer to the official [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli) for instructions.

## Configuration Overview

### Provider Configuration

The AWS provider is configured with the specified region, and an alias is set for easier reference.

```hcl
provider "aws" {
    region = var.region  # Set the AWS region based on the 'region' variable
    alias  = "main"
}
```

### Key Pair and TLS Private Key

An AWS key pair is created for secure SSH access, and a TLS private key is generated for the key pair.
```
resource "aws_key_pair" "Mumbai_First_Server" {
    key_name   = "Mumbai_First_Server"
    public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits  = 4096
}
```

### Local File Resource

A local file resource is used to save the private key locally.

```
resource "local_file" "Mumbai_Key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "Mumbai_First_Server.pem"
}
```

### AWS EC2 Instance

An EC2 instance is configured with specific settings, including the root block device and an additional EBS volume.

```
resource "aws_instance" "Mumbai_First_Server" {
    # ... (Refer to the main.tf file for the complete instance configuration)
}
```

### AWS Security Group
A security group is defined to allow SSH traffic to the EC2 instance.
```
resource "aws_security_group" "allow_ssh" {
    # ... (Refer to the main.tf file for the complete security group configuration)
}
```

### Outputs
Outputs are defined to expose relevant information about the deployed EC2 instance.
```
output "public_key" {
    value = aws_instance.Mumbai_First_Server.public_ip
}

output "private_key" {
    value = aws_instance.Mumbai_First_Server.private_ip
}

output "ec2_id" {
    value = aws_instance.Mumbai_First_Server.id
}
```

## Usage
***1. Clone the Repository:*** Clone this repository to your local machine.

***2. Initialize Terraform:*** Run terraform init in the project directory to initialize Terraform and download the necessary provider plugins.

***3. Apply Changes:*** Run terraform apply to create the AWS resources based on the configuration.

***4. Access EC2 Instance:*** Use the generated private key (Mumbai_First_Server.pem) to SSH into the deployed EC2 instance.


## Cleanup
To remove the created resources, run terraform destroy after usage.


> [!IMPORTANT]
> 1. Ensure that you have the necessary AWS credentials configured on your machine.
> 2. Review and customize the configuration based on your specific requirements before applying changes.
> 3. Always follow best practices for securing your resources, including key pairs and security group configurations.
## License
This Terraform configuration is licensed under the MIT License.
[MIT](https://choosealicense.com/licenses/mit/)

