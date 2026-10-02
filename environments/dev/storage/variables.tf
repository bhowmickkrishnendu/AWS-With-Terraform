variable "aws_region" {
  description = "AWS region for the storage stack."
  type        = string
}

variable "environment" {
  description = "Existing state namespace and resource name prefix. Keep dev for the deployed stack."
  type        = string
}

variable "buckets" {
  description = "Map of buckets keyed by bucket name. Set public = true for buckets that should allow public reads."

  type = map(object({
    public = optional(bool, false)
  }))
}
