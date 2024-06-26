variable "storage_config_disks" {
  type = map(list(map(string)))
  default = {
    "efi" = [
      {
        "id" = "disk0"
        "type" = "disk"
        "grub_device" = "false"
        "path" = "/dev/vda"
        "preserve" = "false"
        "ptable" = "gpt"
        "wipe" = "superblock"
      },
    ]
  }
}

variable "storage_config_partitions" {
  type = map(list(object({
    id              = string
    type            = string
    device          = string
    flag            = string
    grub_device     = string
    partition_type  = string
    number          = number
    preserve        = string
    size            = string
    wipe            = string
  })))
  default = {
    "efi" = [
      {
        "id" = "efi-partition"
        "type" = "partition"
        "device" = "disk0"
        "flag" = "esp"
        "grub_device" = "true"
        "partition_type" = "EF00"
        "number" = 1
        "preserve" = "false"
        "size" = "1G"
        "wipe" = "superblock"
      },
      {
        "id" = "boot-partition"
        "device" = "disk0"
        "type" = "partition"
        "flag" = "boot"
        "grub_device" = "false"
        "partition_type" = "8300"
        "number" = 2
        "preserve" = "false"
        "size" = "1G"
        "wipe" = "superblock"
      },
      {
        "id" = "pv0"
        "type" = "partition"
        "device" = "disk0"
        "flag" = ""
        "grub_device" = "false"
        "partition_type" = "8E00"
        "number" = 3
        "preserve" = "false"
        "size" = "-1"
        "wipe" = "superblock"
      }
    ]
  }
}

variable "storage_config_volgroups" {
  type = map(list(object({
    id       = string
    type     = string
    devices  = list(string)
    name     = string
    preserve = string
    wipe     = string
  })))
  default = {
    "efi" = [
      {
        "id" = "vg0"
        "type" = "lvm_volgroup"
        "devices" = ["pv0"]
        "name" = "vg0"
        "preserve" = "false"
        "wipe" = "superblock"
      },
    ]
  }
}

variable "storage_config_logvols" {
  type = map(list(map(string)))
  default = {
    "efi" = [
       {
        "id" = "root-lv"
        "type" = "lvm_partition"
        "size" = "32G"
        "volgroup" = "vg0"
        "wipe" = "superblock"
        "preserve" = "false"
        "name" = "root"
      },
      {
        "id" = "home-lv"
        "type" = "lvm_partition"
        "size" = "48G"
        "volgroup" = "vg0"
        "wipe" = "superblock"
        "preserve" = "false"
        "name" = "home"
      },
      {
        "id" = "opt-lv"
        "type" = "lvm_partition"
        "size" = "16G"
        "volgroup" = "vg0"
        "wipe" = "superblock"
        "preserve" = "false"
        "name" = "opt"
      },
      {
        "id" = "tmp-lv"
        "type" = "lvm_partition"
        "size" = "16G"
        "volgroup" = "vg0"
        "wipe" = "superblock"
        "preserve" = "false"
        "name" = "tmp"
      },
      {
        "id" = "var-lv"
        "type" = "lvm_partition"
        "size" = "48G"
        "volgroup" = "vg0"
        "wipe" = "superblock"
        "preserve" = "false"
        "name" = "var"
      },
      {
        "id" = "vartmp-lv"
        "type" = "lvm_partition"
        "size" = "8G"
        "volgroup" = "vg0"
        "wipe" = "superblock"
        "preserve" = "false"
        "name" = "vartmp"
      },
      {
        "id" = "log-lv"
        "type" = "lvm_partition"
        "size" = "8G"
        "volgroup" = "vg0"
        "wipe" = "superblock"
        "preserve" = "false"
        "name" = "log"
      },
      {
        "id" = "audit-lv"
        "type" = "lvm_partition"
        "size" = "8G"
        "volgroup" = "vg0"
        "wipe" = "superblock"
        "preserve" = "false"
        "name" = "audit"
      }
    ]
  }
}

variable "storage_config_filesystems" {
  type = map(list(map(string)))
  default = {
    "efi" = [
      {
        "id" = "efi-filesystem"
        "type" = "format"
        "fstype" = "fat32"
        "volume" = "efi-partition"
        "preserve" = "false"
      },
      {
        "id" = "boot-filesystem"
        "type" = "format"
        "fstype" = "ext4"
        "volume" = "boot-partition"
        "preserve" = "false"
      },
      {
        "id" = "root-filesystem"
        "type" = "format"
        "fstype" = "ext4"
        "volume" = "root-lv"
        "preserve" = "false"
      },
      {
        "id" = "home-filesystem"
        "type" = "format"
        "fstype" = "ext4"
        "volume" = "home-lv"
        "preserve" = "false"
      },
      {
        "id" = "opt-filesystem"
        "type" = "format"
        "fstype" = "ext4"
        "volume" = "opt-lv"
        "preserve" = "false"
      },
      {
        "id" = "tmp-filesystem"
        "type" = "format"
        "fstype" = "ext4"
        "volume" = "tmp-lv"
        "preserve" = "false"
      },
      {
        "id" = "var-filesystem"
        "type" = "format"
        "fstype" = "ext4"
        "volume" = "var-lv"
        "preserve" = "false"
      },
      {
        "id" = "vartmp-filesystem"
        "type" = "format"
        "fstype" = "ext4"
        "volume" = "vartmp-lv"
        "preserve" = "false"
      },
      {
        "id" = "log-filesystem"
        "type" = "format"
        "fstype" = "ext4"
        "volume" = "log-lv"
        "preserve" = "false"
      },
      {
        "id" = "audit-filesystem"
        "type" = "format"
        "fstype" = "ext4"
        "volume" = "audit-lv"
        "preserve" = "false"
      }
    ]
  }
}

variable "storage_config_mounts" {
  type = map(list(map(string)))
  default = {
    "efi" = [
      {
        "id" = "efi-mount"
        "type" = "mount"
        "path" = "/boot/efi"
        "options" = "defaultsuid=0gid=0umask=077shortname=winnt"
        "device" = "efi-filesystem"
      },
      {
        "id" = "boot-mount"
        "type" = "mount"
        "path" = "/boot"
        "options" = "relatime"
        "device" = "boot-filesystem"
      },
      {
        "id" = "root-mount"
        "type" = "mount"
        "path" = "/"
        "options" = "relatime"
        "device" = "root-filesystem"
      },
      {
        "id" = "home-mount"
        "type" = "mount"
        "path" = "/home"
        "options" = "relatime,nodev,nosuid"
        "device" = "home-filesystem"
      },
      {
        "id" = "opt-mount"
        "type" = "mount"
        "path" = "/opt"
        "options" = "relatime,nodev,nosuid"
        "device" = "opt-filesystem"
      },
      {
        "id" = "tmp-mount"
        "type" = "mount"
        "device" = "tmp-filesystem"
        "path" = "/tmp"
        "options" = "noatime,nodev,nosuid,noexec"
      },
      {
        "id" = "var-mount"
        "type" = "mount"
        "path" = "/var"
        "options" = "relatime,nodev,nosuid"
        "device" = "var-filesystem"
      },
      {
        "id" = "vartmp-mount"
        "type" = "mount"
        "path" = "/var/tmp"
        "options" = "noatime,nodev,noexec,nosuid"
        "device" = "vartmp-filesystem"
      },
      {
        "id" = "log-mount"
        "type" = "mount"
        "path" = "/var/log"
        "options" = "relatime,nodev,noexec,nosuid"
        "device" = "log-filesystem"
      },
      {
        "id" = "audit-mount"
        "type" = "mount"
        "path" = "/var/log/audit"
        "options" = "relatime,nodev,noexec,nosuid"
        "device" = "audit-filesystem"
      }
    ]
  }
}
