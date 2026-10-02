data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "krish-terraform-state-ap-south-1"
    key    = "dev/networking/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.terraform_remote_state.networking.outputs.public_subnets)
  id       = each.key
}

data "aws_subnet" "private" {
  for_each = toset(data.terraform_remote_state.networking.outputs.private_subnets)
  id       = each.key
}

locals {
  active_instances = { for name, vm in var.instance_definitions : name => vm if vm.enabled }
  iam_instances    = { for name, vm in local.active_instances : name => vm if vm.iam != null }
  policy_attachments = merge([for name, vm in local.iam_instances : {
    for policy_name, arn in vm.iam.managed_policy_arns : "${name}/${policy_name}" => {
      vm_name = name
      arn     = arn
    }
  }]...)
  cidr_group_instances = { for name, vm in var.instance_definitions : name => vm if !anytrue([for rule in values(vm.security_group.ingress) : rule.source_vm != null]) }
  peer_group_instances = { for name, vm in var.instance_definitions : name => vm if anytrue([for rule in values(vm.security_group.ingress) : rule.source_vm != null]) }
  vm_security_groups   = merge(aws_security_group.cidr_vm, aws_security_group.peer_vm)
  public_subnet_ids    = data.terraform_remote_state.networking.outputs.public_subnets
  private_subnet_ids   = data.terraform_remote_state.networking.outputs.private_subnets
}

# A random selection is stored in state, so later plans keep the same subnet.
# Pin an existing instance's AZ in tfvars to preserve its current subnet.
resource "random_integer" "subnet_choice" {
  for_each = { for name, vm in local.active_instances : name => vm if vm.availability_zone == null }
  min      = 0
  max      = length(each.value.subnet_tier == "public" ? local.public_subnet_ids : local.private_subnet_ids) - 1
}

resource "aws_security_group" "cidr_vm" {
  for_each    = local.cidr_group_instances
  name        = "${var.environment}-${replace(each.key, "_", "-")}-sg"
  description = each.value.security_group.description
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  dynamic "ingress" {
    for_each = each.value.security_group.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.security_group.egress
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = { Name = "${var.environment}-${replace(each.key, "_", "-")}-sg", Environment = var.environment }
}

resource "aws_security_group" "peer_vm" {
  for_each    = local.peer_group_instances
  name        = "${var.environment}-${replace(each.key, "_", "-")}-sg"
  description = each.value.security_group.description
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  dynamic "ingress" {
    for_each = each.value.security_group.ingress
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.source_vm == null ? ingress.value.cidr_blocks : null
      security_groups = ingress.value.source_vm == null ? null : [aws_security_group.cidr_vm[ingress.value.source_vm].id]
    }
  }

  dynamic "egress" {
    for_each = each.value.security_group.egress
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = { Name = "${var.environment}-${replace(each.key, "_", "-")}-sg", Environment = var.environment }
}

resource "aws_iam_role" "vm" {
  for_each = local.iam_instances
  name     = each.value.iam.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "vm" {
  for_each   = local.policy_attachments
  role       = aws_iam_role.vm[each.value.vm_name].name
  policy_arn = each.value.arn
}

resource "aws_iam_instance_profile" "vm" {
  for_each = local.iam_instances
  name     = each.value.iam.profile_name
  role     = aws_iam_role.vm[each.key].name
}

resource "tls_private_key" "ec2" {
  for_each  = local.active_instances
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  for_each   = local.active_instances
  key_name   = "${var.environment}-${each.key}-key"
  public_key = tls_private_key.ec2[each.key].public_key_openssh
}

resource "aws_secretsmanager_secret" "ec2_key" {
  for_each                = local.active_instances
  name                    = "${var.environment}-${each.key}-private-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ec2_key" {
  for_each      = local.active_instances
  secret_id     = aws_secretsmanager_secret.ec2_key[each.key].id
  secret_string = tls_private_key.ec2[each.key].private_key_pem
}

module "instances" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  version  = "6.4.0"
  for_each = local.active_instances

  ami           = each.value.ami
  instance_type = each.value.instance_type
  subnet_id = each.value.availability_zone == null ? (
    each.value.subnet_tier == "public" ? local.public_subnet_ids[random_integer.subnet_choice[each.key].result] : local.private_subnet_ids[random_integer.subnet_choice[each.key].result]
  ) : one([for id in(each.value.subnet_tier == "public" ? local.public_subnet_ids : local.private_subnet_ids) : id if(each.value.subnet_tier == "public" ? data.aws_subnet.public[id].availability_zone : data.aws_subnet.private[id].availability_zone) == each.value.availability_zone])

  key_name                    = aws_key_pair.ec2[each.key].key_name
  associate_public_ip_address = each.value.associate_public_ip_address
  create_security_group       = false
  vpc_security_group_ids      = [local.vm_security_groups[each.key].id]
  iam_instance_profile        = each.value.iam == null ? null : aws_iam_instance_profile.vm[each.key].name

  root_block_device = {
    size                  = coalesce(try(each.value.root_volume.size, null), var.root_volume_size)
    type                  = coalesce(try(each.value.root_volume.type, null), var.root_volume_type)
    delete_on_termination = coalesce(try(each.value.root_volume.delete_on_termination, null), var.root_delete_on_termination)
    encrypted             = try(each.value.root_volume.encrypted, null)
    kms_key_id            = try(each.value.root_volume.kms_key_id, null)
    iops                  = try(each.value.root_volume.iops, null)
    throughput            = try(each.value.root_volume.throughput, null)
  }
  ebs_volumes = each.value.extra_ebs
  user_data   = local.instance_user_data[each.key]
  tags        = merge({ Name = "${var.environment}-${each.key}", Environment = var.environment }, each.value.extra_tags)
}

moved {
  from = aws_security_group.bastion_sg
  to   = aws_security_group.cidr_vm["bastion"]
}

moved {
  from = aws_security_group.private_ec2_sg
  to   = aws_security_group.peer_vm["private_ec2"]
}

moved {
  from = aws_iam_role.ec2_ssm_role
  to   = aws_iam_role.vm["bastion"]
}

moved {
  from = aws_iam_instance_profile.ec2_profile
  to   = aws_iam_instance_profile.vm["bastion"]
}

moved {
  from = aws_iam_role_policy_attachment.ssm_core
  to   = aws_iam_role_policy_attachment.vm["bastion/ssm_core"]
}
