#  Mumbai Cloud Adventure Awaits! 🇮🇳 ☁️

## ✨ Unleash the Power of Terraform with This Code ✨

This Terraform configuration is your launchpad to create a secure and accessible EC2 instance in Mumbai, complete with a key pair, security group, and Elastic IP address.

Here's a detailed breakdown of its functionality:

**1. Key Pair for Secure Access **

- Generates a 4096-bit RSA key pair for encrypted SSH connections 
- Public key is saved as a Terraform output 
- Private key is securely stored locally for future SSH access ️

**2. Security Group for Controlled Traffic ️**

- Creates a security group named "Mumbai_First_Server-SG" 
- Allows inbound SSH traffic on port 22 from any source (0.0.0.0/0) 
- Permits all outbound traffic 

**3. EC2 Instance Launch **

- Provisions a t2.micro EC2 instance with the specified AMI 
- Places the instance within the designated VPC subnet 
- Assigns the created security group for traffic control ️
- Associates a public IP address for direct access 
- Disables accidental API termination for protection 

**4. Elastic IP Address for Persistence **

- Allocates an Elastic IP address and associates it with the instance 
- Ensures a consistent public IP address, even after instance restarts 

**5. Outputs for Easy Retrieval **

- Exposes the following information as Terraform outputs:
   - Private IP address of the instance 
   - EC2 instance ID 
   - Elastic IP address 

**Ready to Begin Your Cloud Journey? **

Follow these steps to kickstart your Mumbai cloud adventure:

1. **Install Terraform:** https://learn.hashicorp.com/terraform/getting-started/install ️
2. **Configure AWS Credentials:** https://krishnendubhowmick.medium.com/how-to-setup-aws-region-access-key-and-secret-key-throgh-aws-cli-for-terraform-f66e7233ef0f 
3. **Execute the Code:** `terraform apply` ✨
4. **Enjoy a Refreshment While Terraform Does Its Thing ☕**
5. **Retrieve Instance Details:** `terraform output` ℹ️
6. **Connect via SSH:** `ssh -i Mumbai_First_Server.pem ec2-user@<elastic_ip>` 

**Explore the Limitless Cloud Possibilities! ☁️**

**Remember:**

- MIT License Grants Freedom to Use, Modify, and Share! ⚖️
- Customize the Code to Align with Your Specific Needs ️
- Refer to Terraform's Official Documentation for Deeper Exploration: https://www.terraform.io/docs 

**Happy Cloud Computing! **

