variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "bastion_ssh_cidr" {
  type = string
}

variable "ami_id" {
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
  type = map(object({
    ami                         = optional(string)
    instance_type               = optional(string)
    subnet_tier                 = string
    associate_public_ip_address = bool
    use_iam_profile             = bool
    extra_tags                  = optional(map(string))

    # Optional per-instance root volume overrides. Any unset field falls back to
    # the corresponding global default (root_volume_size / root_volume_type /
    # root_delete_on_termination). Set root_volume = null to use all global defaults.
    root_volume = optional(object({
      size                  = optional(number)
      type                  = optional(string)
      delete_on_termination = optional(bool)
      encrypted             = optional(bool)
      kms_key_id            = optional(string)
      iops                  = optional(number) # gp3 min 3000; io1/io2 required
      throughput            = optional(number) # gp3 only (MiB/s)
    }))

    # Per-instance bootstrap script. Path is relative to this module and rendered
    # with `user_data_vars` via templatefile(). The EBS-mount script (when extra_ebs
    # defines mount points) is prepended automatically.
    user_data_file = optional(string)
    user_data_vars = optional(map(string), {})
    extra_ebs = optional(map(object({
      size                  = optional(number)
      type                  = optional(string)
      device_name           = optional(string)
      iops                  = optional(number)
      throughput            = optional(number)
      encrypted             = optional(bool)
      kms_key_id            = optional(string)
      tags                  = optional(map(string))
      filesystem            = optional(string)
      mount_point           = optional(string)
      delete_on_termination = optional(bool)
      # attachment flags supported by module
      force_detach                   = optional(bool)
      skip_destroy                   = optional(bool)
      stop_instance_before_detaching = optional(bool)
    })))
  }))

  default = {
    bastion = {
      ami                         = null
      instance_type               = null
      subnet_tier                 = "public"
      associate_public_ip_address = true
      use_iam_profile             = true
      extra_tags                  = {}
      root_volume                 = null # uses global defaults
      extra_ebs                   = {}
    }

    private_ec2 = {
      ami                         = null
      instance_type               = null
      subnet_tier                 = "private"
      associate_public_ip_address = false
      use_iam_profile             = true
      extra_tags                  = {}
      root_volume                 = null # uses global defaults
      extra_ebs                   = {}
    }
  }
}