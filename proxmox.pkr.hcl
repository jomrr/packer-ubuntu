source "proxmox-iso" "ubuntu" {
  bios              = var.boot_mode == "efi" ? "ovmf" : "seabios"
  boot_command      = ["c<wait>linux /casper/vmlinuz --- autoinstall ds='nocloud-net'<enter><wait1s>initrd /casper/initrd <enter><wait1s>boot <enter><wait1s>"]
  boot_wait         = "5s"
  communicator      = "ssh"
  cores             = "4"

  disks {
      disk_size = "${var.disk_size}"
      storage_pool = "${var.proxmox_pool}"
      type = "virtio"
  }

  efi_config {
    efi_storage_pool = "${var.proxmox_pool}"
    pre_enrolled_keys = true
  }

  additional_iso_files {
    cd_content        = {
      "meta-data" = "{\"instance-id\":\"${var.vm_name_prefix}-${source.value.name}\",\"local-hostname\":\"${var.vm_name_prefix}-${source.value.name}\"}",
      "user-data" = templatefile("./templates/user-data.${var.boot_mode}.pkrtpl.hcl", { var = var, source = source })
    }
    cd_label          = "cidata"
    iso_storage_pool  = "${var.proxmox_pool}"
  }

  insecure_skip_tls_verify = true

  iso_url           = "${var.iso_url}"
  iso_checksum      = "${var.iso_checksum}"
  iso_storage_pool  = "${var.proxmox_pool}"

  machine           = "q35"
  memory            = "8192"

  network_adapters {
      model = "virtio"
      bridge = "vmbr0"
      firewall = "true"
  }

  node              = "${var.proxmox_node}"
  proxmox_url       = "${var.proxmox_url}"
  username          = "${var.proxmox_username}"
  password          = "${var.proxmox_password}"
  vm_id             = "${var.proxmox_vm_id}"

  qemu_agent        = true

  ssh_username      = "${var.ssh_username}"
  ssh_password      = "${var.ssh_password}"
  ssh_timeout       = "15m"

  unmount_iso       = true

  vga {
    type = "qxl"
  }

  vm_name           = join("-", [var.vm_name_prefix, source.value.name])
}

build {
    name = "proxmox-iso"

    dynamic "source" {
      for_each = var.sources
      labels = ["source.proxmos-iso.ubuntu"]

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
