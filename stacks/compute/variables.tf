variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "root_delete_on_termination" {
  type    = bool
  default = true
}

variable "instance_definitions" {
  description = "VM settings keyed by a stable name. Disabled entries can retain network settings. An enabled VM can use a locally created IAM role or an existing instance profile."
  type = map(object({
    enabled                     = optional(bool, true)
    ami                         = optional(string)
    instance_type               = optional(string)
    subnet_tier                 = string
    availability_zone           = optional(string)
    associate_public_ip_address = bool
    extra_tags                  = optional(map(string), {})
    security_group = object({
      description = string
      ingress = optional(map(object({
        description = string
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks = optional(list(string), [])
        source_vm   = optional(string)
      })), {})
      egress = optional(map(object({
        description = string
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks = list(string)
      })), {})
    })
    iam = optional(object({
      role_name           = string
      profile_name        = string
      managed_policy_arns = map(string)
    }))
    existing_instance_profile_name = optional(string)
    root_volume = optional(object({
      size                  = optional(number)
      type                  = optional(string)
      delete_on_termination = optional(bool)
      encrypted             = optional(bool)
      kms_key_id            = optional(string)
      iops                  = optional(number)
      throughput            = optional(number)
    }))
    user_data_file = optional(string)
    user_data_vars = optional(map(string), {})
    extra_ebs = optional(map(object({
      size                           = optional(number)
      type                           = optional(string)
      device_name                    = optional(string)
      iops                           = optional(number)
      throughput                     = optional(number)
      encrypted                      = optional(bool)
      kms_key_id                     = optional(string)
      tags                           = optional(map(string))
      filesystem                     = optional(string)
      mount_point                    = optional(string)
      delete_on_termination          = optional(bool)
      force_detach                   = optional(bool)
      skip_destroy                   = optional(bool)
      stop_instance_before_detaching = optional(bool)
    })))
  }))

  validation {
    condition = alltrue([
      for name, vm in var.instance_definitions :
      contains(["public", "private"], vm.subnet_tier) &&
      (vm.subnet_tier == "public" || !vm.associate_public_ip_address) &&
      (!vm.enabled || (vm.ami != null && vm.instance_type != null)) &&
      (vm.iam == null || vm.existing_instance_profile_name == null) &&
      (vm.existing_instance_profile_name == null || trimspace(coalesce(vm.existing_instance_profile_name, " ")) != "") &&
      alltrue([for rule in values(vm.security_group.ingress) :
        (length(rule.cidr_blocks) > 0) != (rule.source_vm != null) &&
        (rule.source_vm == null || (contains(keys(var.instance_definitions), rule.source_vm) && !anytrue([for source_rule in values(try(var.instance_definitions[rule.source_vm].security_group.ingress, {})) : source_rule.source_vm != null]))) &&
        alltrue([for cidr in rule.cidr_blocks : can(cidrnetmask(cidr))])
      ]) &&
      alltrue([for rule in values(vm.security_group.egress) :
        length(rule.cidr_blocks) > 0 && alltrue([for cidr in rule.cidr_blocks : can(cidrnetmask(cidr))])
      ])
    ])
    error_message = "Use valid subnet, AMI, type, and security rules. A VM can use either its own iam block or an existing instance profile name, not both."
  }
}
