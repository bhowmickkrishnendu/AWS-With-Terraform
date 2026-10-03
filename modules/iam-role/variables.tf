variable "name" {
  description = "Name of the IAM role."
  type        = string
}

variable "path" {
  description = "IAM path for the role."
  type        = string
  default     = "/"
}

variable "trust" {
  description = "Who may assume this role, with optional IAM conditions."
  type = object({
    actions    = optional(set(string), ["sts:AssumeRole"])
    principals = map(set(string))
    conditions = optional(map(object({
      test     = string
      variable = string
      values   = set(string)
    })), {})
  })

  validation {
    condition = length(var.trust.actions) > 0 && length(var.trust.principals) > 0 && alltrue([
      for principal_type, identifiers in var.trust.principals :
      contains(["AWS", "Service", "Federated"], principal_type) &&
      length(identifiers) > 0 && !contains(identifiers, "*")
    ])
    error_message = "Trust needs explicit AWS, Service, or Federated principals. A wildcard principal is not allowed."
  }
}

variable "permissions_boundary_arn" {
  description = "Optional permissions boundary for this role."
  type        = string
  default     = null
}

variable "create_instance_profile" {
  description = "Create an instance profile when this role will be attached to EC2."
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Optional instance profile name. Defaults to the role name."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for the role and optional instance profile."
  type        = map(string)
  default     = {}
}
