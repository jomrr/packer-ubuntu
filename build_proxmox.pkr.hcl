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

variable "proxmox_disk_path" {
    type = string
    default = "/dev/vda"
}

variable "proxmox_vm_id" {
    type = number
    default = null
}

source "proxmox-iso" "ubuntu" {}

build {
    name = "proxmox"

  dynamic "source" {
    for_each = local.sources
    labels = ["proxmox-iso.ubuntu"]

    content {
      # Packer options
      name = source.value.name
      bios              = "ovmf"
      boot_command      = ["c<wait>linux /casper/vmlinuz --- autoinstall ds='nocloud-net'<enter><wait1s>initrd /casper/initrd <enter><wait1s>boot <enter><wait1s>"]
      boot_wait         = "10s"
      communicator      = "ssh"
      ssh_username      = var.ssh_username
      ssh_password      = var.ssh_password
      ssh_timeout       = "15m"
      vm_name           = var.vm_name

      # Proxmox options
      insecure_skip_tls_verify = true
      cores             = var.cpus
      iso_url           = source.value.iso_url
      iso_checksum      = source.value.iso_checksum
      iso_storage_pool  = var.proxmox_pool
      machine           = "q35"
      memory            = var.memory
      node              = var.proxmox_node
      proxmox_url       = var.proxmox_url
      username          = var.proxmox_username
      password          = var.proxmox_password
      qemu_agent        = true
      unmount_iso       = true
      vm_id             = var.proxmox_vm_id

      additional_iso_files {
        cd_content        = {
          "meta-data" = "{\"instance-id\":\"${var.vm_name}-${source.value.name}\",\"local-hostname\":\"${var.hostname}\"}",
          "user-data" = templatefile("./templates/user-data.pkrtpl.hcl", { var = var, source = source, local = local, disk = var.proxmox_disk_path })
        }
        cd_label          = "cidata"
        iso_storage_pool  = var.proxmox_pool
      }

      disks {
          discard = true
          disk_size = "${var.disk_size}M"
          format = "qcow2"
          ssd = true
          storage_pool = var.proxmox_pool
          type = "virtio"
      }

      efi_config {
        efi_storage_pool = var.proxmox_pool
        pre_enrolled_keys = true
      }

      network_adapters {
          model = "virtio"
          bridge = "vmbr0"
          firewall = "true"
      }

      vga {
        type = "qxl"
      }
    }
  }
  # run provisionerss to clean and configure the system
    provisioner "ansible" {
    galaxy_file   = "./ansible/requirements.yml"
    galaxy_force_with_deps = true
    playbook_file = "./ansible/playbook.yml"
    user          = "${var.ssh_username}"
    extra_arguments = [
      "--extra-vars", "ansible_ssh_pass=${var.ssh_password}",
      "--extra-vars", "ansible_become_pass=${var.ssh_password}",
    ]
  }
  provisioner "shell" {
    execute_command = "{{ .Vars }} echo ${var.ssh_password} | sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "./scripts/apparmor.sh",
      "./scripts/coredumps.sh",
      "./scripts/editor.sh",
      "./scripts/ipv6.sh",
      "./scripts/sshd.sh",
      "./scripts/sysctl.sh",
      "./scripts/systemd.sh",
      "./scripts/ufw.sh",
      "./scripts/zero_prep.sh",
    ]
  }
}
