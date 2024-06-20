packer {
  required_version = ">= 1.11.0"
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
  }
}
