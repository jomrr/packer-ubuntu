variable "boot_mode" {
    type = string
    default = "efi"
}

variable "disk_size" {
    type = string
    default = "200G"
}

variable "efi_firmware_code" {
    type = string
    default = "/usr/share/OVMF/OVMF_CODE.secboot.fd"
}

variable "efi_firmware_vars" {
    type = string
    default = "/usr/share/OVMF/OVMF_VARS.secboot.fd"
}

variable "iso_url" {
    type = string
    default = "https://ftp.halifax.rwth-aachen.de/ubuntu-releases/24.04/ubuntu-24.04-live-server-amd64.iso"
}

variable "iso_checksum" {
    type = string
    default = "sha256:8762f7e74e4d64d72fceb5f70682e6b069932deedb4949c6975d0f0fe0a91be3"
}

variable "ssh_username" {
    type = string
    default = "packer"
}

variable "ssh_password" {
    type = string
    default = "packer"
}

variable "ssh_password_encrypted" {
    type = string
    default = "$6$exlewNtc8ZP3QjTi$Vwiy09gDmU/Lfiwwmfwribu75lijV/BNDb0K4HGfv2ZmMytXkOk5M9f1UkpXDCxm4kDniTiULF2CCBCzqxYzP0"
}

variable "vm_name" {
    type = string
    default = "template-ubuntu-server-24.04"
}
