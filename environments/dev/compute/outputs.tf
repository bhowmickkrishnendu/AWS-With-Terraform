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