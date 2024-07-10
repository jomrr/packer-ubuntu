variable "qemu_efi_firmware_code" {
    type = string
    default = "/usr/share/OVMF/OVMF_CODE.secboot.fd"
}

variable "qemu_efi_firmware_vars" {
    type = string
    default = "/usr/share/OVMF/OVMF_VARS.secboot.fd"
}

variable "qemu_disk_path" {
    type = string
    default = "/dev/vda"
}

source "qemu" "ubuntu" {}

build {
  name = "qemu"

  dynamic "source" {
    for_each = local.sources
    labels = ["qemu.ubuntu"]

    content {
      name = source.value.name
      # packer options
      boot_command      = ["c<wait>linux /casper/vmlinuz --- autoinstall ds='nocloud-net' vga=794<enter><wait1s>initrd /casper/initrd<enter><wait1s>boot <enter><wait1s>"]
      boot_wait         = "10s"
      communicator      = "ssh"
      output_directory  = "dist/${var.vm_name}"
      shutdown_command  = "echo ${var.ssh_password} | sudo -S shutdown -P now"
      ssh_username      = var.ssh_username
      ssh_password      = var.ssh_password
      ssh_timeout       = "15m"
      # QEMU VM options
      accelerator       = "kvm"
      cpus              = var.cpus
      format            = "qcow2"
      headless          = "false"
      machine_type      = "q35"
      memory            = var.memory
      qemuargs = [
        [ "-netdev", "user,hostfwd=tcp::{{.SSHHostPort}}-:22,id=forward,net=192.168.76.0/24" ],
        [ "-device", "virtio-net,netdev=forward,id=net0" ],
      ]
      vga               = "qxl"
      vm_name           = var.vm_name
      # disk options
      disk_discard      = "unmap"
      disk_interface    = "virtio"
      disk_size         = "${var.disk_size}M"
      # EFI boot options
      efi_boot          = true
      efi_firmware_code = var.qemu_efi_firmware_code
      efi_firmware_vars = var.qemu_efi_firmware_vars
      # cloud-init configuration via cdrom (floppy fails in 22.04)
      cd_content    = {
        "meta-data" = "{\"instance-id\":\"${var.vm_name}-${source.value.name}\",\"local-hostname\":\"${var.hostname}\"}",
        "user-data" = templatefile("./templates/user-data.pkrtpl.hcl", { var = var, source = source, local = local, disk = var.qemu_disk_path })
      }
      cd_label      = "cidata"
      # ISO source options
      iso_checksum      = source.value.iso_checksum
      iso_url           = source.value.iso_url
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
