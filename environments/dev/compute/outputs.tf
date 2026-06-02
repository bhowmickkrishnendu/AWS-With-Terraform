output "bastion_public_ip" {
  value = module.instances["bastion"].public_ip
}

output "bastion_instance_id" {
  value = module.instances["bastion"].id
}

output "private_ec2_instance_id" {
  value = module.instances["private_ec2"].id
}

output "private_ec2_private_ip" {
  value = module.instances["private_ec2"].private_ip
}

output "ec2_key_pair_names" {
  value = { for instance_name, key_pair in aws_key_pair.ec2 : instance_name => key_pair.key_name }
}

output "ec2_private_key_secret_arns" {
  value = { for instance_name, secret in aws_secretsmanager_secret.ec2_key : instance_name => secret.arn }
}

/* Compatibility aliases (old names) */
output "bastion_id" {
  description = "Compatibility: bastion id alias"
  value       = try(module.instances["bastion"].id, null)
}

output "bastion_private_ip" {
  description = "Compatibility: bastion private ip alias"
  value       = try(module.instances["bastion"].private_ip, null)
}

output "bastion_ebs_volumes" {
  description = "Compatibility: bastion ebs volumes"
  value       = try(module.instances["bastion"].ebs_volumes, null)
}

output "private_ec2_id" {
  description = "Compatibility: private_ec2 id alias"
  value       = try(module.instances["private_ec2"].id, null)
}

output "private_ec2_ebs_volumes" {
  description = "Compatibility: private_ec2 ebs volumes"
  value       = try(module.instances["private_ec2"].ebs_volumes, null)
}