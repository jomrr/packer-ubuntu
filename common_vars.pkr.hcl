variable "cpus" {
  type = number
  default = 4
}

variable "memory" {
  type = number
  default = 8192
}

variable "disk_size" {
    type = string
    default = "204800"
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
