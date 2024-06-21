variable "boot_mode" {
    type = string
    default = "efi"
}

variable "disk_size" {
    type = string
    default = "200G"
}

variable "efi_firmware_code" {
    type = string
    default = "/usr/share/OVMF/OVMF_CODE.secboot.fd"
}

variable "efi_firmware_vars" {
    type = string
    default = "/usr/share/OVMF/OVMF_VARS.secboot.fd"
}

variable "proxmox_url" {
    type = string
    default = "https://192.168.122.167:8006/api2/json"
}

variable "proxmox_username" {
    type = string
    default = "root@pam"
}

variable "proxmox_password" {
    type = string
    default = "packer"
}

variable "proxmox_node" {
    type = string
    default = "pve"
}

variable "proxmox_pool" {
    type = string
    default = "local-btrfs"
}

variable "proxmox_vm_id" {
    type = number
    default = null
}

variable "sources" {
  type = list(object({
    name         = string
    iso_url      = string
    iso_checksum = string
    packages     = list(string)
  }))
  default = [
    {
      name = "ubuntu2204"
      iso_url = "https://ftp.halifax.rwth-aachen.de/ubuntu-releases/22.04/ubuntu-22.04.4-live-server-amd64.iso"
      iso_checksum = "sha256:45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
      packages = [
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

variable "ssh_username" {
    type = string
    default = "packer"
}

variable "ssh_password" {
    type = string
    default = "packer"
}

variable "ssh_password_encrypted" {
    type = string
    default = "$6$exlewNtc8ZP3QjTi$Vwiy09gDmU/Lfiwwmfwribu75lijV/BNDb0K4HGfv2ZmMytXkOk5M9f1UkpXDCxm4kDniTiULF2CCBCzqxYzP0"
}

variable "vm_name_prefix" {
    type = string
    default = "template"
}

variable "storage_configs" {
  type = map(list(map(string)))
  default = {
    "efi": [
      {
        "id": "disk0"
        "type": "disk",
        "ptable": "gpt",
        "path": "/dev/vda",
        "wipe": "superblock",
        "preserve": "false",
        "grub_device": "false",
      },
      {
        "id": "efi-partition"
        "type": "partition",
        "device": "disk0",
        "size": "1G",
        "flag": "esp",
        "number": 1,
        "partition_type": "EF00",
        "grub_device": "true",
        "wipe": "superblock",
        "preserve": "false",
      },
      {
        "id": "efi-filesystem"
        "type": "format",
        "fstype": "fat32",
        "volume": "efi-partition",
        "preserve": "false",
      },
      {
        "id": "efi-mount"
        "type": "mount",
        "path": "/boot/efi",
        "options": "defaults,uid=0,gid=0,umask=077,shortname=winnt",
        "device": "efi-filesystem",
      },
      {
        "id": "boot-partition"
        "device": "disk0",
        "type": "partition",
        "size": "1G",
        "wipe": "superblock",
        "flag": "boot",
        "number": 2,
        "preserve": "false",
        "grub_device": "false",
      },
      {
        "id": "boot-filesystem"
        "type": "format",
        "fstype": "ext4",
        "volume": "boot-partition",
        "preserve": "false",
      },
      {
        "id": "boot-mount"
        "type": "mount",
        "path": "/boot",
        "options": "relatime",
        "device": "boot-filesystem",
      },
      {
        "id": "pv0"
        "type": "partition",
        "device": "disk0",
        "size": -1,
        "wipe": "superblock",
        "flag": "",
        "number": 3,
        "preserve": "false",
        "grub_device": "false",
      },
      {
        "id": "vg0"
        "type": "lvm_volgroup",
        "name": "vg0",
        "devices": "pv0",
        "preserve": "false",
      },
      {
        "id": "root-lv"
        "type": "lvm_partition",
        "size": "32G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "root",
      },
      {
        "id": "root-filesystem"
        "type": "format",
        "fstype": "ext4",
        "volume": "root-lv",
        "preserve": "false",
      },
      {
        "id": "root-mount"
        "type": "mount",
        "path": "/",
        "options": "relatime",
        "device": "root-filesystem",
      },
      {
        "id": "home-lv"
        "type": "lvm_partition",
        "size": "48G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "home",
      },
      {
        "id": "home-filesystem"
        "type": "format",
        "fstype": "ext4",
        "volume": "home-lv",
        "preserve": "false",
      },
      {
        "id": "home-mount"
        "type": "mount",
        "path": "/home",
        "options": "relatime,nodev,nosuid",
        "device": "home-filesystem",
      },
      {
        "id": "opt-lv"
        "type": "lvm_partition",
        "size": "16G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "opt",
      },
      {
        "id": "opt-filesystem"
        "type": "format",
        "fstype": "ext4",
        "volume": "opt-lv",
        "preserve": "false",
      },
      {
        "id": "opt-mount"
        "type": "mount",
        "path": "/opt",
        "options": "relatime,nodev,nosuid",
        "device": "opt-filesystem",
      },
      {
        "id": "tmp-lv"
        "type": "lvm_partition",
        "size": "16G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "tmp",
      },
      {
        "id": "tmp-filesystem"
        "type": "format",
        "fstype": "ext4",
        "volume": "tmp-lv",
        "preserve": "false",
      },
      {
        "id": "tmp-mount"
        "type": "mount",
        "device": "tmp-filesystem",
        "path": "/tmp",
        "options": "noatime,nodev,nosuid,noexec",
      },
      {
        "id": "var-lv"
        "type": "lvm_partition",
        "size": "48G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "var",
      },
      {
        "id": "var-filesystem"
        "type": "format",
        "fstype": "ext4",
        "volume": "var-lv",
        "preserve": "false",
      },
      {
        "id": "var-mount"
        "type": "mount",
        "path": "/var",
        "options": "relatime,nodev,nosuid",
        "device": "var-filesystem",
      },
      {
        "id": "vartmp-lv"
        "type": "lvm_partition",
        "size": "8G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "vartmp",
      },
      {
        "id": "vartmp-filesystem"
        "type": "format",
        "fstype": "ext4",
        "volume": "vartmp-lv",
        "preserve": "false",
      },
      {
        "id": "vartmp-mount"
        "type": "mount",
        "path": "/var/tmp",
        "options": "noatime,nodev,noexec,nosuid",
        "device": "vartmp-filesystem",
      },
      {
        "id": "log-lv"
        "type": "lvm_partition",
        "size": "8G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "log",
      },
      {
        "id": "log-filesystem"
        "type": "format",
        "fstype": "ext4",
        "volume": "log-lv",
        "preserve": "false",
      },
      {
        "id": "log-mount"
        "type": "mount",
        "path": "/var/log",
        "options": "relatime,nodev,noexec,nosuid",
        "device": "log-filesystem",
      },
      {
        "id": "audit-lv"
        "type": "lvm_partition",
        "size": "8G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "audit",
      },
      {
        "id": "audit-filesystem"
        "type": "format",
        "fstype": "ext4",
        "volume": "audit-lv",
        "preserve": "false",
      },
      {
        "id": "audit-mount"
        "type": "mount",
        "path": "/var/log/audit",
        "options": "relatime,nodev,noexec,nosuid",
        "device": "audit-filesystem",
      }
    ]
  }
}
