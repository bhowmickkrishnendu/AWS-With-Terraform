module "roles" {
  source   = "../../modules/iam-role"
  for_each = var.roles

  name                     = each.value.name
  path                     = each.value.path
  trust                    = each.value.trust
  permissions_boundary_arn = each.value.permissions_boundary_arn
  create_instance_profile  = each.value.create_instance_profile
  instance_profile_name    = each.value.instance_profile_name
  tags                     = each.value.tags
}

module "policies" {
  source   = "../../modules/iam-policy"
  for_each = var.policies

  name        = each.value.name
  description = each.value.description
  path        = each.value.path
  statements  = each.value.statements
  tags        = each.value.tags
}

module "users" {
  source   = "../../modules/iam-user"
  for_each = var.users

  name                     = each.value.name
  path                     = each.value.path
  permissions_boundary_arn = each.value.permissions_boundary_arn
  tags                     = each.value.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = var.role_policy_attachments
  role       = module.roles[each.value.role_key].name
  policy_arn = each.value.policy_key != null ? module.policies[each.value.policy_key].arn : each.value.policy_arn
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each   = var.user_policy_attachments
  user       = module.users[each.value.user_key].name
  policy_arn = each.value.policy_key != null ? module.policies[each.value.policy_key].arn : each.value.policy_arn
}
