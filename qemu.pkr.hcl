packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "ubuntu" {
  accelerator       = "kvm"
  boot_command      = ["c<wait>linux /casper/vmlinuz --- autoinstall ds='nocloud-net'<enter><wait1s>initrd /casper/initrd <enter><wait1s>boot <enter><wait1s>"]
  boot_wait         = "5s"
  communicator      = "ssh"
  cpus              = "4"
  disk_discard      = "unmap"
  disk_interface    = "virtio"
  disk_size         = "${var.disk_size}"
  efi_boot          = var.boot_mode == "efi"
  efi_firmware_code = var.boot_mode == "efi" ? var.efi_firmware_code : null
  efi_firmware_vars = var.boot_mode == "efi" ? var.efi_firmware_vars : null
  floppy_content    = {
    "meta-data" = jsonencode("instance-id: ${var.vm_name}\nlocal-hostname: ${var.vm_name}"),
    "user-data" = templatefile("./templates/user-data.${var.boot_mode}.pkrtpl.hcl", {var = var })
    } 
  floppy_label      = "cidata"
  format            = "qcow2"
  headless          = "false"
  iso_url           = "${var.iso_url}"
  iso_checksum      = "${var.iso_checksum}"
  machine_type      = "q35"
  memory            = "8192"
  output_directory  = "build"
  qemuargs = [
    [ "-netdev", "user,hostfwd=tcp::{{.SSHHostPort}}-:22,id=forward,net=192.168.76.0/24" ],
    [ "-device", "virtio-net,netdev=forward,id=net0" ],
  ]
  shutdown_command  = "echo ${var.ssh_password} | sudo -S shutdown -P now"
  ssh_username      = "${var.ssh_username}"
  ssh_password      = "${var.ssh_password}"
  ssh_timeout       = "15m"
  vga               = "qxl"
  vm_name           = "${var.vm_name}"
}

build {
    sources = ["source.qemu.ubuntu"]

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
