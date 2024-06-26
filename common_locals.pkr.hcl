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

  sources = [
    {
      name = "ubuntu2204"
      iso_url = "https://ftp.halifax.rwth-aachen.de/ubuntu-releases/22.04/ubuntu-22.04.4-live-server-amd64.iso"
      iso_checksum = "sha256:45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
      packages = [
        "apparmor",
        "apparmor-profiles",
        "apparmor-profiles-extra",
        "apparmor-utils",
        "apt-transport-https",
        "bash-completion",
        "byobu",
        "bzip2",
        "ca-certificates",
        "cron",
        "curl",
        "iputils-ping",
        "libopenscap8",
        "nano",
        "net-tools",
        "neovim",
        "nftables",
        "openssh-server",
        "open-vm-tools",
        "qemu-guest-agent",
        "python3-apt",
        "rsyslog",
        "software-properties-common",
        "sudo",
        "systemd-journal-remote",
        "systemd-timesyncd",
        "ufw",
        "wget"
      ]
    },
    {
      name = "ubuntu2404"
      iso_url = "https://ftp.halifax.rwth-aachen.de/ubuntu-releases/24.04/ubuntu-24.04-live-server-amd64.iso"
      iso_checksum = "sha256:8762f7e74e4d64d72fceb5f70682e6b069932deedb4949c6975d0f0fe0a91be3"
      packages = [
        "apparmor",
        "apparmor-profiles",
        "apparmor-profiles-extra",
        "apparmor-utils",
        "apt-transport-https",
        "bash-completion",
        "byobu",
        "ca-certificates",
        "cron",
        "curl",
        "iputils-ping",
        "nano",
        "net-tools",
        "neovim",
        "nftables",
        "openscap-scanner",
        "openscap-utils",
        "openssh-server",
        "open-vm-tools",
        "qemu-guest-agent",
        "python3-apt",
        "rsyslog",
        "software-properties-common",
        "sudo",
        "systemd-journal-remote",
        "systemd-timesyncd",
        "ufw",
        "wget"
      ]
    }
  ]
}
