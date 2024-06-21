source "proxmox-iso" "ubuntu" {}

build {
    name = "proxmox-iso"

  dynamic "source" {
    for_each = var.sources
    labels = ["source.proxmox-iso.ubuntu"]

    content {
      # Packer options
      name = source.value.name
      bios              = var.boot_mode == "efi" ? "ovmf" : "seabios"
      boot_command      = ["c<wait>linux /casper/vmlinuz --- autoinstall ds='nocloud-net'<enter><wait1s>initrd /casper/initrd <enter><wait1s>boot <enter><wait1s>"]
      boot_wait         = "10s"
      communicator      = "ssh"
      ssh_username      = var.ssh_username
      ssh_password      = var.ssh_password
      ssh_timeout       = "15m"
      vm_name           = join("-", [var.vm_name_prefix, source.value.name])

      # Proxmox options
      insecure_skip_tls_verify = true
      cores             = "4"
      iso_url           = source.value.iso_url
      iso_checksum      = source.value.iso_checksum
      iso_storage_pool  = var.proxmox_pool
      machine           = "q35"
      memory            = "8192"
      node              = var.proxmox_node
      proxmox_url       = var.proxmox_url
      username          = var.proxmox_username
      password          = var.proxmox_password
      qemu_agent        = true
      unmount_iso       = true
      vm_id             = var.proxmox_vm_id

      additional_iso_files {
        cd_content        = {
          "meta-data" = "{\"instance-id\":\"${var.vm_name_prefix}-${source.value.name}\",\"local-hostname\":\"${var.vm_name_prefix}-${source.value.name}\"}",
          "user-data" = templatefile("./templates/user-data.${var.boot_mode}.pkrtpl.hcl", { var = var, source = source })
        }
        cd_label          = "cidata"
        iso_storage_pool  = var.proxmox_pool
      }

      disks {
          disk_size = var.disk_size
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

    provisioner "ansible" {
      galaxy_file   = "./requirements.yml"
      playbook_file = "./playbook.yml"
      user          = "${var.ssh_username}"
      extra_arguments = [
        "--extra-vars", "ansible_ssh_pass=${var.ssh_password}",
        "--extra-vars", "ansible_become_pass=${var.ssh_password}",
      ]
    }
}
