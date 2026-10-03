variable "name" {
  description = "Name of the IAM user. No password or access key is created."
  type        = string
}

variable "path" {
  description = "IAM path for the user."
  type        = string
  default     = "/"
}

variable "permissions_boundary_arn" {
  description = "Optional permissions boundary for the user."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for the user."
  type        = map(string)
  default     = {}
}
