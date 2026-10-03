variable "aws_region" {
  type        = string
  description = "AWS region where ECR repositories will be created"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod, etc.)"
}

variable "repositories" {
  type = map(object({
    description            = optional(string, "")
    image_tag_mutability   = optional(string, "MUTABLE")
    scan_on_push           = optional(bool, true)
    encryption_type        = optional(string, "AES256")
    force_delete           = optional(bool, false)
    image_retention_count  = optional(number, 10)
    lifecycle_days_expired = optional(number, 30)
    tags                   = optional(map(string), {})
  }))
  description = "Map of ECR repositories to create with their configurations"
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to apply to all resources"
}
