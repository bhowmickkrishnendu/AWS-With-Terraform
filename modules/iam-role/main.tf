data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = sort(tolist(var.trust.actions))

    dynamic "principals" {
      for_each = var.trust.principals
      content {
        type        = principals.key
        identifiers = sort(tolist(principals.value))
      }
    }

    dynamic "condition" {
      for_each = var.trust.conditions
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = sort(tolist(condition.value.values))
      }
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = var.name
  path                 = var.path
  assume_role_policy   = data.aws_iam_policy_document.trust.json
  permissions_boundary = var.permissions_boundary_arn
  tags                 = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = coalesce(var.instance_profile_name, var.name)
  role = aws_iam_role.this.name
  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
