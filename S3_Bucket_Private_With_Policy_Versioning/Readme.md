# AWS S3 Bucket Terraform Configuration

## Overview

 This Terraform configuration of an AWS S3 bucket, designed for managing Tomcat server logs. The configuration includes setting up ownership controls, access controls, and an IAM policy for public read access with IP conditions. Additionally, an output is provided to expose the ARN of the created S3 bucket.

## Prerequisites

Ensure you have the following before using this Terraform configuration:

- AWS credentials configured with the necessary permissions.
- Terraform installed on your local machine.

## Usage

1. **Clone Repository:**
   ```bash
   git clone <repository_url>
   cd <repository_directory>
    ```

2. **Customize Variables:**

Modify variables in var.tf (e.g., AWS region).

3. **Initialize Terraform:**

```
terraform init
```
4. **Review Execution Plan:**

```
terraform plan
```

5. **Apply Configuration:**
```
terraform apply
```

6. **Retrieve S3 Bucket ARN:**

After applying, the ARN of the created S3 bucket is available as an output.

****Outputs****

⏹️ ***Bucket ARN:*** The Amazon Resource Name (ARN) of the created S3 bucket.

****Cleanup****

To destroy the resources created by this configuration, run:
```
terraform destroy
```
## License
This Terraform configuration is licensed under the MIT License.
[MIT](https://choosealicense.com/licenses/mit/)

