resource "aws_iam_user" "this" {
  name                 = var.name
  path                 = var.path
  permissions_boundary = var.permissions_boundary_arn
  force_destroy        = false
  tags                 = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
