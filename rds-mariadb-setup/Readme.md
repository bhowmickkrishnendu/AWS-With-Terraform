# RDS MariaDB Instance Setup

This Terraform project creates an RDS MariaDB instance in the ap-south-1 region with the following configurations:

- Database creation method: Standard
- Engine: MariaDB
- Engine Version: 10.11.6
- Free Tier Template
- DB Instance Identifier: testmdb
- Master Username: admin
- Auto-generated Password
- DB Instance Class: db.t3.micro
- Storage Type: General Purpose SSD (gp2)
- Allocated Storage: 20 GB
- Storage Autoscaling: Enabled (Max 1000 GB)
- VPC: vpc-0243e953b038c0d1f
- No Public Access
- VPC Security Group: sg-0878feb5745da1fe4
- Initial Database Name: studentdb
- Automated Backups: Enabled
- Encryption: No
- Auto Minor Version Upgrade: No
- Deletion Protection: Yes
- Database Authentication: Password

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS account and credentials configured

## Usage

1. Clone the repository or download the Terraform script.
2. Navigate to the project directory.
3. Run `terraform init` to initialize the Terraform working directory.
4. Run `terraform apply` to create the RDS instance. Review the plan and enter `yes` to apply the changes.
5. After the apply completes successfully, note the database endpoint from the output.
6. To retrieve the generated database password, run: `terraform output db_password` This command will display the actual password value.

## Outputs

- `db_endpoint`: The endpoint of the MariaDB instance.
- `db_password`: The password for the MariaDB instance (sensitive).

## Cleanup

- To destroy the created resources, run: `terraform destroy` Review the plan and enter `yes` to confirm the destruction.

## Note

- Replace the VPC ID (`vpc-0243e953b038c0d1f`) and security group ID (`sg-0878feb5745da1fe4`) with your own values.
- Update the subnet IDs (`subnet-id1` and `subnet-id2`) in the `aws_db_subnet_group` resource with your private subnet IDs.