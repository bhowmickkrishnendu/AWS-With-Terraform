# AWS SNS Topic with Email Subscriptions

This Terraform configuration creates an AWS SNS Topic with two email subscriptions.

## Resources

- **AWS SNS Topic:** An SNS Topic with the specified name and display name.
- **SNS Topic Subscriptions:** Two email subscriptions to the SNS Topic, using specified email addresses.

## Outputs

- **topic_arn:** The ARN of the created SNS Topic.

## Usage

1. **Install Terraform:** Follow the instructions on the official Terraform website to install Terraform on your system.
2. **Configure AWS Credentials:** Set up your AWS credentials using environment variables or an AWS configuration file.
3. **Initialize Terraform:** Run `terraform init` to initialize the Terraform workspace and install any required providers.
4. **Review and Plan:** Run `terraform plan` to review the changes that Terraform will make to your infrastructure.
5. **Apply Changes:** Run `terraform apply` to create the SNS Topic and subscriptions.

## Variables

- **region:** The AWS region where the resources will be created (default: ap-south-1).
- **topicname:** The name of the SNS Topic (default: Demo-Topic_Name).

## Additional Notes

- Consider using a remote state backend (e.g., S3) to store Terraform state for better collaboration and version control.
- Explore using Terraform modules to organize and reuse common infrastructure patterns.
- Implement appropriate tagging for resources to manage costs and track usage.
