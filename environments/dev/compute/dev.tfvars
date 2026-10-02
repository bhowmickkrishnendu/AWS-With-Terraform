aws_region  = "ap-south-1"
environment = "dev"

root_volume_size           = 20
root_volume_type           = "gp3"
root_delete_on_termination = true

instance_definitions = {
  bastion = {
    ami                         = "ami-0ac7b260cf76d8865"
    instance_type               = "t3.small"
    subnet_tier                 = "public"
    availability_zone           = "ap-south-1a"
    associate_public_ip_address = true
    extra_tags                  = { Role = "bastion" }
    user_data_file              = "scripts/bastion.sh"
    user_data_vars              = { hostname = "dev-bastion" }

    # The internet gateway makes the public IP reachable. This rule opens SSH
    # from any IPv4 address. Replace with your trusted public /32 when possible.
    security_group = {
      description = "Security group for bastion host"
      ingress = {
        ssh = { description = "SSH Access", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      }
      egress = {
        ssh   = { description = "SSH to private EC2 within the VPC", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
        https = { description = "HTTPS access for package updates and SSM", from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      }
    }

    # Kept with its deployed names to avoid replacing the role or profile.
    iam = {
      role_name    = "dev-ec2-ssm-role"
      profile_name = "dev-ec2-profile"
      managed_policy_arns = {
        ssm_core = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }

  # This group exists in state, but no private VM is deployed. Keep it until
  # the private VM is needed so the SG is not destroyed by this refactor.
  private_ec2 = {
    enabled                     = false
    subnet_tier                 = "private"
    associate_public_ip_address = false
    security_group = {
      description = "Security group for private EC2"
      ingress = {
        ssh_from_bastion = { description = "SSH from bastion", from_port = 22, to_port = 22, protocol = "tcp", source_vm = "bastion" }
      }
      egress = {
        https = { description = "HTTPS access for SSM and package updates", from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      }
    }
  }
}
