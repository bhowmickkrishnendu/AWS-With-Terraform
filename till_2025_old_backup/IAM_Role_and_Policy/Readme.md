## Terraform code for creating an IAM role with S3 permissions and associating it with an instance profile

This Terraform code provisions the following AWS resources:

### 1. IAM Role:

* **Resource:** `aws_iam_role.role_details`
* **Name:** Defined by the `var.role_name` variable in `variables.tf` (e.g., "s3-access-role")
* **Permissions:**
    * **Assume Role Policy:** Allows EC2 instances to assume the role. This policy explicitly defines who can assume the role (in this case, EC2 service) and the actions they are allowed to perform when assuming the role.
    * **Attached Policies:**
        * **Custom S3 Policy:** Defined by the `aws_iam_policy.policy_details` resource below. It grants permissions for actions like `GetObject`, `PutObject`, `ListBucket`, `DeleteObject`, and `GetBucketLocation` on all S3 resources.
        * **AmazonSSMManagedInstanceCore Policy:** Provides access to AWS Systems Manager for managing and configuring EC2 instances.

### 2. IAM Policy:

* **Resource:** `aws_iam_policy.policy_details`
* **Name:** Defined by the `var.user_policy_name` variable in `variables.tf` (e.g., "s3-access-policy")
* **Description:** "This is the user policy" defines the purpose of the policy for better understanding.
* **Statements:** Grant specific permissions for interacting with S3 resources:
    * **Action:** Defines the S3 API actions allowed (e.g., `GetObject`, `PutObject`).
    * **Effect:** Specifies whether the action is allowed ("Allow") or denied ("Deny").
    * **Resource:** Defines the scope of the permission. In this case, "*" grants access to all S3 resources.

### 3. IAM Role Policy Attachments:

* **Resources:** `aws_iam_role_policy_attachment.attaching_policy` and `aws_iam_role_policy_attachment.attaching_ssm_policy`
* **Action:** Attaches the defined IAM policies (`aws_iam_policy.policy_details` and "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore") to the `aws_iam_role.role_details` resource.

### 4. IAM Instance Profile:

* **Resource:** `aws_iam_role.profile_details`
* **Name:** Matches the name of the associated IAM role (`aws_iam_role.role_details.name`).
* **Role:** Explicitly assigns the `aws_iam_role.role_details` resource to the instance profile, enabling EC2 instances launched with this profile to assume the role and inherit its permissions.

### Prerequisites:

* An AWS account with appropriate IAM permissions to create and manage IAM roles, policies, and instance profiles.
* Terraform installed and configured with access to your AWS credentials.

### Usage:

1. **Configure variables:** Update `variables.tf` with your desired values for:
    - `region`: The AWS region where you want to deploy the resources.
    - `role_name`: The desired name for the IAM role.
    - `user_policy_name`: The desired name for the IAM policy.

2. **Initialize Terraform:** Run `terraform init` to initialize the Terraform environment and download plugins.

3. **Plan the changes:** Run `terraform plan` to preview the changes Terraform will make based on your configuration.

4. **Apply the changes:** Run `terraform apply` to create the resources in your AWS account.

5. **Associate the instance profile with EC2 instances:** When launching EC2 instances, select the created instance profile (e.g., the name defined for `aws_iam_instance_profile.profile_details`) to grant them the IAM role's permissions.

### License:

This code is licensed under the MIT License.



