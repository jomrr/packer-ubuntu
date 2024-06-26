packer {
  required_version = "~> 1.11"
  required_plugins {
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
    vsphere = {
      version = "~> 1.3"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}
