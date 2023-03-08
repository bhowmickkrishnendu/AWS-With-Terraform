## AWS with Terraform
This repository contains Terraform code to deploy various resources on Amazon Web Services (AWS) platform. The purpose of this repository is to demonstrate the usage of Terraform to deploy and manage infrastructure on AWS.

##Prerequisites
Before you can use the Terraform code in this repository, you must have the following prerequisites installed:

Terraform (>= v0.14.9)
AWS CLI (>= v2.1.6)

## Usage
To use the Terraform code in this repository, follow these steps:

##Clone the repository using the following command:

git clone https://github.com/bhowmickkrishnendu/AWS-With-Terraform.git

Change into the cloned directory:

cd AWS-With-Terraform

## Initialize Terraform by running the following command:

terraform init

## Configure your AWS credentials by running the following command:

aws configure

Modify the variables.tf file to suit your requirements.

## Create the infrastructure by running the following command:

terraform apply

This will create the resources defined in the Terraform code.

## Destroy the infrastructure by running the following command:

terraform destroy

This will destroy all the resources that were created by the Terraform code.

## Contributing
If you find a bug or want to contribute to this repository, feel free to create a pull request.

## License
This repository is licensed under the MIT License.