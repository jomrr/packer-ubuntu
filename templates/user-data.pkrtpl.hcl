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
  packages: [${join(",", [for p in source.value.packages : "\"${p}\""])}]
  ssh:
    install-server: yes
    allow-pw: yes
  user-data:
    disable_root: true
  timezone: Europe/Berlin
  updates: all
  write_files:
  - path: /etc/default/grub.d/99-disable-ipv6.cfg
    content: |
      GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT ipv6.disable=1"
  - path: /etc/default/grub.d/99-enable-apparmor.cfg
    content: |
      GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT apparmor=1 security=apparmor"
  runcmd:
    - "echo '${var.ssh_username} ALL=(ALL:ALL) ALL' > /target/etc/sudoers.d/${var.ssh_username}"
    - "chmod 440 /target/etc/sudoers.d/${var.ssh_username}"
    - "update-grub"
    - "reboot"
    - "aa-enforce /etc/apparmor.d/*"
  storage:
    grub:
      reorder_uefi: false
    config: ${storage_config_json}
  late-commands:
    - systemctl enable --now ssh
    - systemctl mask ctrl-alt-del.target
