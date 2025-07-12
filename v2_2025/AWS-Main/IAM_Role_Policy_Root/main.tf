module "iam_role_policy" {
  # source = "D:\\my_github\\AWS-With-Terraform\\v2_2025\\module\\IAM_Role_Policy_Module"
  source = "git::"
  region = var.region
  role_name = var.role_name
  user_policy_name = var.user_policy_name

}