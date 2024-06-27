variable "vsphere_vcenter_server" {
  type = string
  default = "10.0.1.182"
}

variable "vsphere_insecure_connection" {
  type = bool
  default = true
}

variable "vsphere_username" {
  type = string
  default = "packer@vsphere.local"
}

variable "vsphere_password" {
  type = string
  default = "Packer,Build3r"
}

variable "vsphere_cluster" {
  type = string
  default = "Cluster"
}

variable "vsphere_datacenter" {
  type = string
  default = "Datacenter"
}

variable "vsphere_datastore" {
  type = string
  default = "vms"
}

variable "vsphere_folder" {
  type = string
  default = "Templates"
}

variable "vsphere_host" {
  type = string
  default = "10.0.1.180"
}

variable "vsphere_network" {
  type = string
  default = "VM Network"
}

variable "vsphere_network_card" {
  type = string
  default = "vmxnet3"
}

variable "vsphere_disk_controller" {
  type = list(string)
  default = ["pvscsi"]
}

variable "vsphere_disk_path" {
  type = string
  default = "/dev/sda"
}

variable "vsphere_disk_thin_provisioned" {
  type = bool
  default = true
}

source "vsphere-iso" "ubuntu" {}

build {
  name = "vsphere-iso"

  dynamic "source" {
    for_each = local.sources
    labels = ["source.vsphere-iso.ubuntu"]

    content {
      name = source.value.name
      # packer options
      boot_command      = ["c<wait>linux /casper/vmlinuz --- autoinstall ds='nocloud-net'<enter><wait1s>initrd /casper/initrd <enter><wait1s>boot <enter><wait1s>"]
      boot_wait         = "10s"
      communicator      = "ssh"
      shutdown_command  = "echo ${var.ssh_password} | sudo -S shutdown -P now"
      ssh_username      = var.ssh_username
      ssh_password      = var.ssh_password
      ssh_timeout       = "15m"

      vm_name           = join("-", [var.vm_name_prefix, source.value.name])
      # vsphere options
      vcenter_server    = var.vsphere_vcenter_server
      insecure_connection = var.vsphere_insecure_connection
      username          = var.vsphere_username
      password          = var.vsphere_password
      # cluster           = var.vsphere_cluster
      host              = var.vsphere_host
      datacenter        = var.vsphere_datacenter
      datastore         = var.vsphere_datastore
      folder            = var.vsphere_folder

      convert_to_template = true
      local_cache_overwrite = false
      remote_cache_cleanup = true
      remote_cache_overwrite = false
      remote_cache_datastore = var.vsphere_datastore

      # VM options
      CPUs              = var.cpus
      RAM               = var.memory
      RAM_reserve_all   = false
      disk_controller_type = var.vsphere_disk_controller
      firmware          = "efi-secure" 
      guest_os_type     = "ubuntu64Guest"
      vm_version        = "21"

      network_adapters {
        network = var.vsphere_network
        network_card = var.vsphere_network_card
      }

      storage {
        disk_size = var.disk_size
        disk_thin_provisioned = var.vsphere_disk_thin_provisioned
      }
      
      # cloud-init configuration via cdrom (floppy fails in 22.04)
      cd_content    = {
        "meta-data" = jsonencode({
          instance-id = "${var.vm_name_prefix}-${source.value.name}"
          local-hostname = "${var.vm_name_prefix}-${source.value.name}"
        })
        "user-data" = templatefile(
          "./templates/user-data.pkrtpl.hcl", { var = var, source = source, local = local, disk = var.vsphere_disk_path }
        )
      }
      cd_label      = "cidata"
      # ISO source options
      iso_checksum      = source.value.iso_checksum
      iso_url           = source.value.iso_url
    }
  }
  provisioner "ansible" {
    galaxy_file   = "./ansible/requirements.yml"
    playbook_file = "./ansible/playbook.yml"
    user          = "${var.ssh_username}"
    extra_arguments = [
      "--extra-vars", "ansible_ssh_pass=${var.ssh_password}",
      "--extra-vars", "ansible_become_pass=${var.ssh_password}",
    ]
  }
}
