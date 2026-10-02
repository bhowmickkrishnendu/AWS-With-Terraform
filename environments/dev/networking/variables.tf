variable "environment" {
  description = "Existing state namespace and resource name prefix. Keep dev for the deployed stack."
  type        = string
}

variable "aws_region" {
  description = "AWS region for the networking stack."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block of the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR."
  }
}

variable "availability_zones" {
  description = "Availability zones, in the same order as the public and private subnet CIDR lists."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) > 0 && length(distinct(var.availability_zones)) == length(var.availability_zones)
    error_message = "Provide at least one unique availability zone."
  }
}

variable "public_subnet_cidrs" {
  description = "One public subnet CIDR per availability zone, in matching order."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones) && alltrue([for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "Provide one valid public IPv4 subnet CIDR for each availability zone."
  }
}

variable "private_subnet_cidrs" {
  description = "One private subnet CIDR per availability zone, in matching order."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones) && alltrue([for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "Provide one valid private IPv4 subnet CIDR for each availability zone."
  }
}

variable "nat_gateway_mode" {
  description = "Private outbound internet access: none, one NAT gateway, or one NAT gateway per availability zone."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "single", "per_az"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be none, single, or per_az."
  }
}

variable "enable_s3_gateway_endpoint" {
  description = "Add a gateway endpoint to the private route tables for in-region S3 traffic."
  type        = bool
  default     = false
}

variable "interface_endpoint_services" {
  description = "AWS interface endpoint service suffixes, such as ssm, ssmmessages, ec2messages, ecr.api, ecr.dkr, or sts. Each service adds an endpoint in every private subnet."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for service in var.interface_endpoint_services : can(regex("^[a-z0-9][a-z0-9.-]*$", service))])
    error_message = "Interface endpoint service names must use lowercase letters, digits, dots, or hyphens."
  }
}
