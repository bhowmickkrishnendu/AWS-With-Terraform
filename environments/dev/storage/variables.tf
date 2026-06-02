variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "buckets" {
  description = "Map of buckets keyed by bucket name. Set public = true for buckets that should allow public reads."

  type = map(object({
    public = optional(bool, false)
  }))
}