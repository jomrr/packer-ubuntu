# Locals, that are shared between all Packer builds
locals {
  common_packages = [
    "apt-transport-https",
    "bash-completion",
    "ca-certificates",
    "curl",
    "iputils-ping",
    "nano",
    "net-tools",
    "neovim",
    "python3-apt",
    "software-properties-common",
    "sudo",
    "wget"
  ]
  sources = [
    {
      name = "ubuntu2204"
      iso_url = "https://ftp.halifax.rwth-aachen.de/ubuntu-releases/22.04/ubuntu-22.04.4-live-server-amd64.iso"
      iso_checksum = "sha256:45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
      packages = []
    },
    {
      name = "ubuntu2404"
      iso_url = "https://ftp.halifax.rwth-aachen.de/ubuntu-releases/24.04/ubuntu-24.04-live-server-amd64.iso"
      iso_checksum = "sha256:8762f7e74e4d64d72fceb5f70682e6b069932deedb4949c6975d0f0fe0a91be3"
      packages = []
    }
  ]
}
