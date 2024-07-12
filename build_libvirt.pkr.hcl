variable "libvirt_disk_path" {
    type = string
    default = "/dev/vda"
}

source "libvirt" "ubuntu" {}

build {
  name = "libvirt"

  dynamic "source" {
    for_each = local.sources
    labels = ["libvirt.ubuntu"]

    content {
      name = source.value.name
      # packer options
      boot_command            = ["c<wait>linux /casper/vmlinuz --- autoinstall ds='nocloud-net' vga=794<enter><wait1s>initrd /casper/initrd<enter><wait1s>boot <enter><wait1s>"]
      boot_devices            = ["hd", "cdrom"]
      boot_wait               = "10s"
      chipset                 = "q35"
      domain_type             = "kvm"
      domain_name             = var.vm_name
      vcpu                    = var.cpus
      memory                  = var.memory
      libvirt_uri             = "qemu+ssh://root@eadu.jomrr.de/system"
      network_address_source  = "agent"
      communicator {
        communicator  = "ssh"
        ssh_username  = var.ssh_username
        ssh_password  = var.ssh_password
      }
      graphics {
        type          = "vnc"
       }
      network_interface {
        alias         = "communicator"
        model         = "virtio"
        network       = "lq-linux"
        type          = "managed"
      }
      volume {
        alias         = "artifact"
        bus           = "virtio"
        device        = "disk"
        format        = "qcow2"
        pool          = "default"
        name          = "${var.vm_name}"
        capacity      = "${var.disk_size}M"
        size          = "${var.disk_size}M"
      }
      volume {
        name          = "${var.vm_name}-install"
        bus           = "sata"
        device        = "cdrom"
        readonly      = "true"
        capacity      = "8G"
        format        = "qcow2"
        pool          = "default"
        source {
          type      = "backing-store"
          pool      = "default"
          volume    = "ubuntu-24.04-live-server-amd64.iso"
        }
        // source {
        //   type      = "external"
        //   urls      = [source.value.iso_url]
        //   checksum  = source.value.iso_checksum
        // }
      }
      volume {
        name          = "${var.vm_name}-cloudinit"
        bus           = "sata"
        device        = "cdrom"
        readonly      = true
        capacity      = "1M"
        format        = "raw"
        pool          = "default"
        source {
          type      = "cloud-init"
          meta_data = "{\"instance-id\":\"${var.vm_name}-${source.value.name}\",\"local-hostname\":\"${var.hostname}\"}"
          user_data = templatefile("./templates/user-data.pkrtpl.hcl", { var = var, source = source, local = local, disk = var.libvirt_disk_path })
        }
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
