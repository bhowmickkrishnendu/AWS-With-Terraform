locals {
  # Per-instance EBS-mount script. Non-empty only when extra_ebs is a map whose
  # entries declare both device_name and mount_point. (Mirrors the previous inline logic.)
  ebs_mount_scripts = {
    for k, def in var.instance_definitions : k => (
      can(keys(lookup(def, "extra_ebs", {}))) ? join("\n", [
        for v in values(lookup(def, "extra_ebs", {})) :
        format(
          "if [ -b %s ]; then mkfs -t %s %s || true; mkdir -p %s; mount %s %s; echo '%s %s %s defaults,nofail 0 2' >> /etc/fstab; fi",
          v.device_name, coalesce(v.filesystem, "ext4"), v.device_name, v.mount_point,
          v.device_name, v.mount_point, v.device_name, v.mount_point, coalesce(v.filesystem, "ext4")
        )
        if v.mount_point != null && v.mount_point != "" && v.device_name != null && v.device_name != ""
      ]) : ""
    )
  }

  # Per-instance custom bootstrap, rendered from user_data_file via templatefile().
  custom_user_data = {
    for k, def in var.instance_definitions : k => (
      def.user_data_file != null && def.user_data_file != ""
      ? templatefile("${path.module}/${def.user_data_file}", def.user_data_vars)
      : ""
    )
  }

  # Final merged user_data: shebang, then auto EBS mount, then the custom script.
  # null when neither part has content (so the module omits user_data entirely).
  instance_user_data = {
    for k, def in var.instance_definitions : k => (
      local.ebs_mount_scripts[k] == "" && local.custom_user_data[k] == ""
      ? null
      : join("\n", concat(
        ["#!/bin/bash", "set -e"],
        local.ebs_mount_scripts[k] == "" ? [] : ["# --- auto EBS mount ---", local.ebs_mount_scripts[k]],
        local.custom_user_data[k] == "" ? [] : ["# --- custom user_data ---", local.custom_user_data[k]]
      ))
    )
  }
}
