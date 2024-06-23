#cloud-config

autoinstall:
  source:
    id: ubuntu-server-minimal
  version: 1
  early-commands:
    - systemctl disable --now ssh
  identity:
    hostname: ${var.vm_name_prefix}-${source.value.name}
    username: ${var.ssh_username}
    password: ${var.ssh_password_encrypted}
  keyboard:
    layout: de
  locale: en_US.UTF-8
  kernel:
    package: linux-virtual
  packages: [${join(",", [for package in source.value.packages : "\"${package}\""])}]
  ssh:
    install-server: yes
    allow-pw: yes
  user-data:
    disable_root: true
  timezone: Europe/Berlin
  updates: all
  late-commands:
    - curtin in-target --target=/target -- systemctl mask ctrl-alt-del.target # runs in target env
    - "echo '${var.ssh_username} ALL=(ALL:ALL) ALL' > /target/etc/sudoers.d/${var.ssh_username}" # writes to target env
    - "chmod 440 /target/etc/sudoers.d/${var.ssh_username}" # changes target env
    - curtin in-target --target=/target -- sudo sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1 apparmor=1 security=apparmor"/' /etc/default/grub
    - curtin in-target --target=/target -- update-grub
    - curtin in-target --target=/target -- find /etc/apparmor.d -maxdepth 1 -type f -exec aa-enforce {} \;
    - systemctl enable --now ssh # runs in install env
  storage:
    grub:
      reorder_uefi: false
    config: local.storage_config
  late-commands:
    - systemctl enable --now ssh
    - systemctl mask ctrl-alt-del.target
