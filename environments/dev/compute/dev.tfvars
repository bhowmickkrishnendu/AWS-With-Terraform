aws_region  = "ap-south-1"
environment = "dev"

instance_type = "t2.small"

ami_id = "ami-09ed39e30153c3bf9"

bastion_ssh_cidr = "10.0.0.0/16"

# Global root volume defaults (apply to any instance that does not set root_volume).
# These can be overridden per-instance using the root_volume block shown below.
root_volume_size           = 20
root_volume_type           = "gp3"
root_delete_on_termination = true


# Example dynamic instance definitions (uncomment and edit as needed)
instance_definitions = {
  bastion = {
    ami                         = "ami-0ac7b260cf76d8865"
    instance_type               = "t3.small"
    subnet_tier                 = "public"
    associate_public_ip_address = true
    use_iam_profile             = true
    extra_tags                  = { Role = "bastion" }
    user_data_file              = "scripts/bastion.sh"
    user_data_vars              = { hostname = "dev-bastion" }

    # --- Root volume override (optional) -----------------------------------
    # Uncomment and adjust any field; omitted fields fall back to the globals above.
    # root_volume = {
    #   size                  = 30     # GiB -- override the global 20 GiB
    #   type                  = "gp3" # gp2 | gp3 | io1 | io2 | sc1 | st1
    #   delete_on_termination = true
    #   encrypted             = true   # encrypt with the default AWS-managed key
    #   kms_key_id            = null   # ARN/alias of a CMK (leave null for AWS-managed)
    #   iops                  = 3000  # gp3: 3000-16000; io1/io2: 100-64000
    #   throughput            = 125   # gp3 only (MiB/s, 125-1000)
    # }
    # -----------------------------------------------------------------------

    # extra_ebs = {
    #   data1 = {
    #     device_name           = "/dev/sdb"
    #     size                  = 50
    #     type                  = "gp3"
    #     encrypted             = false
    #     filesystem            = "xfs"
    #     mount_point           = "/data"
    #     delete_on_termination = true
    #   }
    # }
  }

  # private_ec2 = {
  #   instance_type               = "t3.medium"
  #   subnet_tier                 = "private"
  #   associate_public_ip_address = false
  #   use_iam_profile             = true
  #   extra_tags                  = { Role = "app" }
  #   user_data_file              = "scripts/private_ec2.sh"
  #
  #   # --- Root volume override (optional) ---------------------------------
  #   # root_volume = {
  #   #   size      = 50
  #   #   encrypted = true
  #   # }
  #   # ---------------------------------------------------------------------
  #
  #   extra_ebs = {}
  # }
}
