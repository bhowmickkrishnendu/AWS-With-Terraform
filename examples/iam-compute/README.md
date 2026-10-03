# Use an IAM-managed profile with a new VM

This example connects the optional `stacks/iam` root to a **new** VM in `stacks/compute`. It does not change the running bastion. The IAM root owns the role, policy, attachment, and instance profile. Compute receives only the profile **name** and does not create another role for this VM.

1. Set your AWS CLI profile and confirm the intended account. Follow the [IAM backend setup](../../docs/iam.md#use-remote-state-when-you-decide-to-create-iam-resources) for a new IAM state key. Replace the example bucket name and IAM names in [iam.tfvars](iam.tfvars). Then review the IAM plan:

   ```powershell
   $env:AWS_PROFILE = 'YOUR_PROFILE'
   aws sts get-caller-identity --query Account --output text
   terraform -chdir=stacks/iam plan -input=false -var-file=../../examples/iam-compute/iam.tfvars
   ```

2. Once the IAM resources are created from that reviewed configuration, read the profile name:

   ```powershell
   terraform -chdir=stacks/iam output -json instance_profile_names
   ```

   The example's `app_vm` key returns `example-app-vm-profile`. Pass that **name**, not the role ARN or profile ARN, to compute.

3. Add this entry **inside the existing** `instance_definitions` map in [stacks/compute/terraform.tfvars](../../stacks/compute/terraform.tfvars). Keep the current `bastion` and `private_ec2` entries. Replace the AMI with one valid in your chosen Region.

   ```hcl
   app_vm = {
     ami                            = "ami-REPLACE_FOR_YOUR_REGION"
     instance_type                  = "t3.small"
     subnet_tier                    = "public"
     associate_public_ip_address    = true
     existing_instance_profile_name = "example-app-vm-profile"

     security_group = {
       description = "Security group for example app VM"
       ingress = {
         ssh_from_bastion = {
           description = "SSH from bastion"
           from_port   = 22
           to_port     = 22
           protocol    = "tcp"
           source_vm   = "bastion"
         }
       }
       egress = {
         https = {
           description = "HTTPS outbound"
           from_port   = 443
           to_port     = 443
           protocol    = "tcp"
           cidr_blocks = ["0.0.0.0/0"]
         }
       }
     }
   }
   ```

   This example uses a public subnet and public IP so HTTPS can leave through the internet gateway while NAT remains disabled. Its SSH rule accepts only the bastion security group. For a private VM, use `subnet_tier = "private"`, no public IP, and first provide the outbound path that workload needs.

4. Review the compute plan before creating the new VM:

   ```powershell
   terraform -chdir=stacks/compute plan -input=false
   ```

   Expect a new `app_vm` instance and related key, secret, and security group. Check that the bastion is not replaced. The current compute design generates a private SSH key for each enabled VM and stores it in Terraform state and Secrets Manager, so protect state and saved plans.
