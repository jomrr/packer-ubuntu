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
    default = 200
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
        "ptable": "gpt",
        "path": "/dev/vda",
        "wipe": "superblock",
        "preserve": "false",
        "grub_device": "false",
        "type": "disk",
        "id": "disk0"
      },
      {
        "device": "disk0",
        "type": "partition",
        "size": "1G",
        "flag": "esp",
        "number": 1,
        "partition_type": "EF00",
        "grub_device": "true",
        "wipe": "superblock",
        "preserve": "false",
        "id": "efi-partition"
      },
      {
        "fstype": "fat32",
        "volume": "efi-partition",
        "preserve": "false",
        "type": "format",
        "id": "efi-filesystem"
      },
      {
        "path": "/boot/efi",
        "options": "defaults,uid=0,gid=0,umask=077,shortname=winnt",
        "device": "efi-filesystem",
        "type": "mount",
        "id": "efi-mount"
      },
      {
        "device": "disk0",
        "type": "partition",
        "size": "1G",
        "wipe": "superblock",
        "flag": "boot",
        "number": 2,
        "preserve": "false",
        "grub_device": "false",
        "id": "boot-partition"
      },
      {
        "fstype": "ext4",
        "volume": "boot-partition",
        "preserve": "false",
        "type": "format",
        "id": "boot-filesystem"
      },
      {
        "path": "/boot",
        "options": "relatime",
        "device": "boot-filesystem",
        "type": "mount",
        "id": "boot-mount"
      },
      {
        "device": "disk0",
        "size": "100%",
        "wipe": "superblock",
        "flag": "",
        "number": 3,
        "preserve": "false",
        "grub_device": "false",
        "type": "partition",
        "id": "pv0"
      },
      {
        "name": "vg0",
        "devices": "[pv0]",
        "preserve": "false",
        "type": "lvm_volgroup",
        "id": "vg0"
      },
      {
        "size": "32G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "root",
        "type": "lvm_partition",
        "id": "root-lv"
      },
      {
        "fstype": "ext4",
        "volume": "root-lv",
        "preserve": "false",
        "type": "format",
        "id": "root-filesystem"
      },
      {
        "path": "/",
        "options": "relatime",
        "device": "root-filesystem",
        "type": "mount",
        "id": "root-mount"
      },
      {
        "size": "48G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "home",
        "type": "lvm_partition",
        "id": "home-lv"
      },
      {
        "fstype": "ext4",
        "volume": "home-lv",
        "preserve": "false",
        "type": "format",
        "id": "home-filesystem"
      },
      {
        "path": "/home",
        "options": "relatime,nodev,nosuid",
        "device": "home-filesystem",
        "type": "mount",
        "id": "home-mount"
      },
      {
        "size": "16G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "opt",
        "type": "lvm_partition",
        "id": "opt-lv"
      },
      {
        "fstype": "ext4",
        "volume": "opt-lv",
        "preserve": "false",
        "type": "format",
        "id": "opt-filesystem"
      },
      {
        "path": "/opt",
        "options": "relatime,nodev,nosuid",
        "device": "opt-filesystem",
        "type": "mount",
        "id": "opt-mount"
      },
      {
        "size": "16G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "tmp",
        "type": "lvm_partition",
        "id": "tmp-lv"
      },
      {
        "fstype": "ext4",
        "volume": "tmp-lv",
        "preserve": "false",
        "type": "format",
        "id": "tmp-filesystem"
      },
      {
        "path": "/tmp",
        "options": "noatime,nodev,nosuid,noexec",
        "device": "tmp-filesystem",
        "type": "mount",
        "id": "tmp-mount"
      },
      {
        "size": "48G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "var",
        "type": "lvm_partition",
        "id": "var-lv"
      },
      {
        "fstype": "ext4",
        "volume": "var-lv",
        "preserve": "false",
        "type": "format",
        "id": "var-filesystem"
      },
      {
        "path": "/var",
        "options": "relatime,nodev,nosuid",
        "device": "var-filesystem",
        "type": "mount",
        "id": "var-mount"
      },
      {
        "size": "8G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "vartmp",
        "type": "lvm_partition",
        "id": "vartmp-lv"
      },
      {
        "fstype": "ext4",
        "volume": "vartmp-lv",
        "preserve": "false",
        "type": "format",
        "id": "vartmp-filesystem"
      },
      {
        "path": "/var/tmp",
        "options": "noatime,nodev,noexec,nosuid",
        "device": "vartmp-filesystem",
        "type": "mount",
        "id": "vartmp-mount"
      },
      {
        "size": "8G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "log",
        "type": "lvm_partition",
        "id": "log-lv"
      },
      {
        "fstype": "ext4",
        "volume": "log-lv",
        "preserve": "false",
        "type": "format",
        "id": "log-filesystem"
      },
      {
        "path": "/var/log",
        "options": "relatime,nodev,noexec,nosuid",
        "device": "log-filesystem",
        "type": "mount",
        "id": "log-mount"
      },
      {
        "size": "8G",
        "volgroup": "vg0",
        "wipe": "superblock",
        "preserve": "false",
        "name": "audit",
        "type": "lvm_partition",
        "id": "audit-lv"
      },
      {
        "fstype": "ext4",
        "volume": "audit-lv",
        "preserve": "false",
        "type": "format",
        "id": "audit-filesystem"
      },
      {
        "path": "/var/log/audit",
        "options": "relatime,nodev,noexec,nosuid",
        "device": "audit-filesystem",
        "type": "mount",
        "id": "audit-mount"
      }
    ]
  }
}
