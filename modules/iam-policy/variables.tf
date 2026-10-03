variable "name" {
  description = "Name of the customer-managed IAM policy."
  type        = string
}

variable "description" {
  description = "What access this policy grants."
  type        = string
}

variable "path" {
  description = "IAM path for the policy."
  type        = string
  default     = "/"
}

variable "statements" {
  description = "Named policy statements with explicit actions and resources."
  type = map(object({
    effect              = optional(string, "Allow")
    actions             = set(string)
    resources           = set(string)
    allow_all_resources = optional(bool, false)
    conditions = optional(map(object({
      test     = string
      variable = string
      values   = set(string)
    })), {})
  }))

  validation {
    condition = length(var.statements) > 0 && alltrue([
      for statement in values(var.statements) :
      contains(["Allow", "Deny"], statement.effect) &&
      length(statement.actions) > 0 && length(statement.resources) > 0 &&
      !contains(statement.actions, "*") &&
      (statement.allow_all_resources || !contains(statement.resources, "*"))
    ])
    error_message = "Each statement needs explicit actions and resources. Use allow_all_resources = true only when an AWS action requires Resource *."
  }
}

variable "tags" {
  description = "Tags for the policy."
  type        = map(string)
  default     = {}
}
