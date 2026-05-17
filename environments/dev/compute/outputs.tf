output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "private_ec2_instance_id" {
  value = aws_instance.private_ec2.id
}

output "private_ec2_private_ip" {
  value = aws_instance.private_ec2.private_ip
}