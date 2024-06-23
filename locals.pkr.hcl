# Local variables to select the appropriate configuration based on boot_mode
locals {
  storage_disks  = var.storage_config_disks[var.boot_mode]
  storage_partitions = var.storage_config_partitions[var.boot_mode]
  storage_volgroups = var.storage_config_volgroups[var.boot_mode]
  storage_logvols = var.storage_config_logvols[var.boot_mode]
  storage_filesystems = var.storage_config_filesystems[var.boot_mode]
  storage_mounts = var.storage_config_mounts[var.boot_mode]
  # make one list of all storage configurations for user-data template
  storage_config = concat(
    local.storage_disks,
    local.storage_partitions,
    local.storage_volgroups,
    local.storage_logvols,
    local.storage_filesystems,
    local.storage_mounts,
  )
}