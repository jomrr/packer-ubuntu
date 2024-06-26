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
    default = "$y$j9T$LcG8Ap18XrU8alcuAxwdG1$8LCEWit0M2Hg/kKaroLp4UY8LJiJD7LBhd8KN.4xvu1"
}

variable "vm_name_prefix" {
    type = string
    default = "template"
}
