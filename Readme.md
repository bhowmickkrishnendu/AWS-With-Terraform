## AWS with Terraform
This repository contains Terraform code to deploy various resources on Amazon Web Services (AWS) platform. The purpose of this repository is to demonstrate the usage of Terraform to deploy and manage infrastructure on AWS.

## Prerequisites
Before you can use the Terraform code in this repository, you must have the following prerequisites installed:

Terraform (>= v0.14.9)

# AWS-With-Terraform

A collection of Terraform modules and sample projects for provisioning AWS resources. This repository is organized into subfolders, each demonstrating a specific AWS use case or resource configuration using Terraform.

## Repository Structure

- **A_Module_View_Multi_Instances_Project/**: Example of provisioning multiple EC2 instances with modular structure.
- **EC2_Create_with_additional_storage_attached/**: Launch EC2 instances with additional EBS storage attached.
- **EC2_Create_with_EIP/**: Provision EC2 instances with Elastic IP assignment.
- **EC2_Create_with_user_data/**: Launch EC2 instances with user data scripts for bootstrapping.
- **EKS_Cluster_Autoscale_IAM_Policy/**: IAM policies for EKS cluster autoscaling.
- **EKS-VPC-Terraform/**: VPC setup for EKS clusters.
- **IAM_Role_and_Policy/**: Create IAM roles and attach policies.
- **IAM_User_and_Policy/**: Create IAM users and attach policies.
- **Policy_Collection_(json)/**: Collection of reusable AWS IAM and S3 policies in JSON format.
- **rds-mariadb-setup/**: Provision an RDS MariaDB instance.
- **S3_Bucket_Private_With_Policy_Versioning/**: S3 bucket with private access, policy, and versioning (see folder for details).
- **S3_Bucket_Public_With_Inside_Folder/**: S3 bucket with public folder (see folder for details).
- **S3_Bucket_SNS_Email_Subscription/**: S3 bucket with SNS email notification (see folder for details).
- **Single_EC2_Create/**: Minimal example to create a single EC2 instance.
- **SNS_Topic_Email_Subscription/**: SNS topic with email subscription example.
- **VPC_Creation/**: VPC creation using Terraform.
- **v2_2025/**: (Reserved for future or versioned modules).

## Getting Started

1. **Clone the repository:**
	```sh
	git clone https://github.com/bhowmickkrishnendu/AWS-With-Terraform.git
	cd AWS-With-Terraform
	```
2. **Navigate to a subfolder** for the desired use case.
3. **Review the `main.tf`, `var.tf`, and `Readme.md`** (if present) in each subfolder for usage instructions.
4. **Initialize Terraform:**
	```sh
	terraform init
	```
5. **Plan and apply:**
	```sh
	terraform plan
	terraform apply
	```

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) (v1.0+ recommended)
- AWS CLI configured with appropriate credentials

## Notes
- Each subfolder is self-contained and can be used independently.
- Policy JSON files in `Policy_Collection_(json)/` can be referenced or imported into your own Terraform modules.
- Always review and customize variables and policies as per your AWS account and security requirements.

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for details.