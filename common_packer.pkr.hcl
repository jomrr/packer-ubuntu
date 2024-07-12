packer {
  required_version = "~> 1.11"
  required_plugins {
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
    libvirt = {
      version = ">= 0.5.0"
      source  = "github.com/thomasklein94/libvirt"
    }
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
    vsphere = {
      version = "~> 1.3"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}
