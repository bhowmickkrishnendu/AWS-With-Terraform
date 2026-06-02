aws_region  = "ap-south-1"
environment = "dev"

instance_type = "t2.small"

ami_id = "ami-09ed39e30153c3bf9"

bastion_ssh_cidr = "10.0.0.0/16"

# public_key = "PASTE-YOUR-PUBLIC-KEY-HERE"

# Example dynamic instance definitions (uncomment and edit as needed)
instance_definitions = {
  bastion = {
    ami                         = "ami-0123456789abcdef0"
    instance_type               = "t3.small"
    subnet_tier                 = "public"
    associate_public_ip_address = true
    use_iam_profile             = true
    extra_tags                  = { Role = "bastion" }
    extra_ebs = {
      data1 = {
        device_name           = "/dev/sdb"
        size                  = 50
        type                  = "gp3"
        encrypted             = false
        filesystem            = "xfs"
        mount_point           = "/data"
        delete_on_termination = true
      }
    }
  }

  private_ec2 = {
    instance_type               = "t3.medium"
    subnet_tier                 = "private"
    associate_public_ip_address = false
    use_iam_profile             = true
    extra_tags                  = { Role = "app" }
    extra_ebs                   = {}
  }
}