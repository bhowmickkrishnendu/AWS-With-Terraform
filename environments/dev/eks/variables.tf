variable "aws_region" {
  type        = string
  description = "AWS region for EKS cluster"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod, etc.)"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.30"
  description = "Kubernetes version to use for the EKS cluster"
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "Enable private API server endpoint"
}

variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Enable public API server endpoint"
}

variable "public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks that can access the public API server endpoint"
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "List of control plane logging types to enable"
}

variable "cluster_log_retention_days" {
  type        = number
  default     = 7
  description = "Number of days to retain cluster logs"
}

variable "node_groups" {
  type = map(object({
    desired_size       = number
    min_size           = number
    max_size           = number
    instance_types     = list(string)
    disk_size          = optional(number, 20)
    capacity_type      = optional(string, "ON_DEMAND")
    max_unavailable    = optional(number, 1)
    tags               = optional(map(string), {})
  }))
  description = "Map of node groups to create"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS cluster will be deployed"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for node groups"
}

variable "control_plane_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for control plane endpoints"
}

variable "enable_oidc_provider" {
  type        = bool
  default     = true
  description = "Enable OIDC identity provider for IAM Roles for Service Accounts (IRSA)"
}

variable "cluster_addons" {
  type = map(object({
    addon_version            = optional(string)
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    preserve                 = optional(bool, false)
    service_account_role_arn = optional(string)
    tags                     = optional(map(string), {})
  }))
  default     = {}
  description = "Map of EKS add-ons to enable (e.g., coredns, kube-proxy, vpc-cni, ebs-csi-driver)"
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to apply to all resources"
}
