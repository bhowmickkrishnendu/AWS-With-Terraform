# Mumbai First Server - Terraform Configuration

## Overview

This Terraform configuration automates the deployment of an AWS EC2 instance in the Mumbai region. It includes a security group for SSH access and an AWS key pair for secure login.

## Prerequisites

Ensure the following are set up before running the Terraform configuration:

- AWS credentials with required permissions.
- Terraform installed on your local machine.

## Usage

1. **Clone Repository:**
   ```bash
   git clone <repository_url>
   cd <repository_directory>

2. **Customize Variables**:
Modify variables in var.tf (e.g., AWS region, availability zone).

3. **Initialize Terraform**: 

```
terraform init
```
4. **Review Execution Plan**:

```
terraform plan
```
5. **Apply Configuration**:

```
terraform apply
```

**Retrieve Key Pair**:
After applying, the private key is saved as Mumbai_First_Server.pem for SSH access.

**Outputs**

⏺️ Public IP: Public IP address of the EC2 instance. 

⏺️ Private IP: Private IP address of the EC2 instance.

⏺️ EC2 Instance ID: Unique identifier for the EC2 instance.

**Cleanup**

To destroy resources, run:

```
terraform destroy
```
## License
This Terraform configuration is licensed under the MIT License.
[MIT](https://choosealicense.com/licenses/mit/)

