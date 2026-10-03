data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.statements
    content {
      sid       = statement.key
      effect    = statement.value.effect
      actions   = sort(tolist(statement.value.actions))
      resources = sort(tolist(statement.value.resources))

      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = sort(tolist(condition.value.values))
        }
      }
    }
  }
}

resource "aws_iam_policy" "this" {
  name        = var.name
  path        = var.path
  description = var.description
  policy      = data.aws_iam_policy_document.this.json
  tags        = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
