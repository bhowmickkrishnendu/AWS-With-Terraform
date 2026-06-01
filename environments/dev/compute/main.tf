data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "krish-terraform-state-ap-south-1"

/* Compatibility outputs moved to outputs.tf */
    key    = "dev/networking/terraform.tfstate"
    region = "ap-south-1"
  }
}

resource "aws_key_pair" "deployer" {
  key_name = "${var.environment}-key"

  public_key = var.public_key
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "SSH to private EC2 within the VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTPS access for package updates and SSM"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-bastion-sg"
    Environment = var.environment
  }
}


module "instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  for_each = var.instance_definitions

  ami           = coalesce(each.value.ami, var.ami_id)
  instance_type = coalesce(each.value.instance_type, var.instance_type)

  subnet_id = each.value.subnet_tier == "public" ? data.terraform_remote_state.networking.outputs.public_subnets[0] : data.terraform_remote_state.networking.outputs.private_subnets[0]

  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = each.value.associate_public_ip_address

  vpc_security_group_ids = each.key == "bastion" ? [aws_security_group.bastion_sg.id] : [aws_security_group.private_ec2_sg.id]

  iam_instance_profile = each.value.use_iam_profile ? aws_iam_instance_profile.ec2_profile.name : null

  root_block_device = {
    size = lookup(var.instance_root_volumes, each.key, { volume_size = var.root_volume_size, volume_type = var.root_volume_type, delete_on_termination = var.root_delete_on_termination }).volume_size
    type = lookup(var.instance_root_volumes, each.key, { volume_size = var.root_volume_size, volume_type = var.root_volume_type, delete_on_termination = var.root_delete_on_termination }).volume_type
    delete_on_termination = lookup(var.instance_root_volumes, each.key, { volume_size = var.root_volume_size, volume_type = var.root_volume_type, delete_on_termination = var.root_delete_on_termination }).delete_on_termination
  }

  # Accept either a map (preferred) or a list for `extra_ebs` and convert lists to a map with generated keys and default device names.
  ebs_volumes = lookup(each.value, "extra_ebs", null) == null ? null : (
    can(keys(lookup(each.value, "extra_ebs", {}))) ? lookup(each.value, "extra_ebs", {}) : (
      zipmap(
        [for idx in range(length(lookup(each.value, "extra_ebs", []))) : format("vol%02d", idx + 1)],
        [for idx, v in zip(range(length(lookup(each.value, "extra_ebs", []))), lookup(each.value, "extra_ebs", [])) : merge(v, { device_name = coalesce(try(v.device_name, null), format("/dev/sd%s", element(["b","c","d","e","f","g","h","i","j","k","l"], idx))) })]
      )
    )
  )

  # Generate user_data only when `extra_ebs` is a map with explicit device_name and mount_point.
  user_data = can(keys(lookup(each.value, "extra_ebs", {}))) && length([for v in values(lookup(each.value, "extra_ebs", {})) : v.mount_point != null && v.mount_point != "" && v.device_name != null && v.device_name != "" ? 1 : 0]) > 0 ? join("\n", concat(["#!/bin/bash","set -e"], [for v in values(lookup(each.value, "extra_ebs", {})) : v.mount_point != null && v.mount_point != "" && v.device_name != null && v.device_name != "" ? format("if [ -b %s ]; then mkfs -t %s %s || true; mkdir -p %s; mount %s %s; echo '%s %s %s defaults,nofail 0 2' >> /etc/fstab; fi", v.device_name, coalesce(v.filesystem, "ext4"), v.device_name, v.mount_point, v.device_name, v.mount_point, v.device_name, v.mount_point, coalesce(v.filesystem, "ext4")) : ""])) : null

  tags = merge({ Name = "${var.environment}-${each.key}", Environment = var.environment }, coalesce(each.value.extra_tags, {}))
}

resource "aws_security_group" "private_ec2_sg" {
  name        = "${var.environment}-private-ec2-sg"
  description = "Security group for private EC2"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    description = "SSH from bastion"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      aws_security_group.bastion_sg.id
    ]
  }

  egress {
    description = "HTTPS access for SSM and package updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-private-ec2-sg"
    Environment = var.environment
  }
}


resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}


/* module "private_ec2" replaced by dynamic module "instances" (for_each) - see variable `instance_definitions` in variables.tf */