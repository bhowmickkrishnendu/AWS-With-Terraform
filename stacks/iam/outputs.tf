output "role_arns" {
  value = { for key, role in module.roles : key => role.arn }
}

output "instance_profile_names" {
  value = { for key, role in module.roles : key => role.instance_profile_name if role.instance_profile_name != null }
}

output "policy_arns" {
  value = { for key, policy in module.policies : key => policy.arn }
}

output "user_arns" {
  value = { for key, user in module.users : key => user.arn }
}
