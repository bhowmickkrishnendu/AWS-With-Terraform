aws_region  = "ap-south-1"
environment = "dev"

root_volume_size           = 20
root_volume_type           = "gp3"
root_delete_on_termination = true

instance_definitions = {
  # dev-bastion was decommissioned. Its services moved to infra-services-nano.
  # The entry stays disabled so its security group remains as the SSH source
  # for private_ec2. The instance, key pair, secret, and IAM role are removed.
  bastion = {
    enabled                     = false
    subnet_tier                 = "public"
    associate_public_ip_address = true
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
