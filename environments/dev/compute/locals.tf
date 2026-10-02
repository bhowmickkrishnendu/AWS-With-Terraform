locals {
  # Per-instance EBS-mount script. Existing filesystems are never formatted again,
  # and /etc/fstab receives each mount entry only once.
  ebs_mount_scripts = {
    for k, def in local.active_instances : k => (
      join("\n", [
        for v in values(coalesce(def.extra_ebs, {})) :
        templatefile("${path.module}/templates/mount-ebs.sh.tftpl", {
          device_name = v.device_name
          mount_point = v.mount_point
          filesystem  = coalesce(v.filesystem, "ext4")
        })
        if v.mount_point != null && v.mount_point != "" && v.device_name != null && v.device_name != ""
      ])
    )
  }

  # Per-instance custom bootstrap, rendered from user_data_file via templatefile().
  custom_user_data = {
    for k, def in local.active_instances : k => (
      def.user_data_file != null && def.user_data_file != ""
      ? templatefile("${path.module}/${def.user_data_file}", def.user_data_vars)
      : ""
    )
  }

  # Final merged user_data: shebang, then auto EBS mount, then the custom script.
  # null when neither part has content (so the module omits user_data entirely).
  instance_user_data = {
    for k, def in local.active_instances : k => (
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
