variable "aws_region" {
  description = "AWS Region. Null uses the AWS profile or environment setting. IAM resources are global to an account."
  type        = string
  default     = null
}

variable "roles" {
  description = "IAM roles keyed by stable names. Empty by default."
  type = map(object({
    name                     = string
    path                     = optional(string, "/")
    permissions_boundary_arn = optional(string)
    create_instance_profile  = optional(bool, false)
    instance_profile_name    = optional(string)
    trust = object({
      actions    = optional(set(string), ["sts:AssumeRole"])
      principals = map(set(string))
      conditions = optional(map(object({
        test     = string
        variable = string
        values   = set(string)
      })), {})
    })
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "policies" {
  description = "Customer-managed IAM policies keyed by stable names. Empty by default."
  type = map(object({
    name        = string
    description = string
    path        = optional(string, "/")
    statements = map(object({
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
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "users" {
  description = "IAM users keyed by stable names. No login profile or access key is created."
  type = map(object({
    name                     = string
    path                     = optional(string, "/")
    permissions_boundary_arn = optional(string)
    tags                     = optional(map(string), {})
  }))
  default = {}
}

variable "role_policy_attachments" {
  description = "Attach either a policy from this root or an existing policy ARN to a role from this root."
  type = map(object({
    role_key   = string
    policy_key = optional(string)
    policy_arn = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for attachment in values(var.role_policy_attachments) :
      contains(keys(var.roles), attachment.role_key) &&
      ((attachment.policy_key != null) != (attachment.policy_arn != null)) &&
      (attachment.policy_key == null || contains(keys(var.policies), attachment.policy_key))
    ])
    error_message = "Each role attachment needs an existing role key and exactly one valid policy key or policy ARN."
  }
}

variable "user_policy_attachments" {
  description = "Attach either a policy from this root or an existing policy ARN to a user from this root."
  type = map(object({
    user_key   = string
    policy_key = optional(string)
    policy_arn = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for attachment in values(var.user_policy_attachments) :
      contains(keys(var.users), attachment.user_key) &&
      ((attachment.policy_key != null) != (attachment.policy_arn != null)) &&
      (attachment.policy_key == null || contains(keys(var.policies), attachment.policy_key))
    ])
    error_message = "Each user attachment needs an existing user key and exactly one valid policy key or policy ARN."
  }
}
