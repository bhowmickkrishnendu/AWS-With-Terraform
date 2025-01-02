variable "region" {
  description = "AWS region"
  type        = string
}

variable "availability_zone" {
  description = "Primary availability zone"
  type        = string
}

variable "availability_zone1" {
  description = "Secondary availability zone"
  type        = string
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}
