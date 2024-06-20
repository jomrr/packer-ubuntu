#cloud-config
autoinstall:
  source:
    id: ubuntu-server-minimal
  version: 1
  early-commands:
    - systemctl stop ssh
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
  runcmd:
    - update-grub
  storage:
    config:
# Disk setup
    - { ptable: gpt, path: /dev/vda, wipe: superblock, preserve: false, grub_device: true, type: disk, id: disk0 }
# BIOS boot partition
    - { device: disk0, type: partition, size: 1M, flag: bios_grub, number: 1, partition_type: EF02, wipe: superblock, preserve: false, id: grub-partition }
# Linux boot partition
    - { device: disk0, size: 1G, wipe: superblock, flag: boot, number: 2, preserve: false, grub_device: false, type: partition, id: boot-partition }
    - { fstype: ext4, volume: boot-partition, preserve: false, type: format, id: boot-filesystem }
    - { path: /boot, options: "relatime", device: boot-filesystem, type: mount, id: boot-mount }
# Partition for LVM Physical Volume and LVM Volume Group
    - { device: disk0, size: -1, wipe: superblock, flag: '', number: 3, preserve: false, grub_device: false, type: partition, id: pv0 }
    - { name: vg0, devices: [pv0], preserve: false, type: lvm_volgroup, id: vg0 }
# LVM Logical Volumes
# 32G for root
    - { size: 32G, volgroup: vg0, wipe: superblock, preserve: false, name: root, type: lvm_partition, id: root-lv }
    - { fstype: ext4, volume: root-lv, preserve: false, type: format, id: root-filesystem }
    - { path: /, options: "relatime", device: root-filesystem, type: mount, id: root-mount }
# 48G for home
    - { size: 48G, volgroup: vg0, wipe: superblock, preserve: false, name: home, type: lvm_partition, id: home-lv }
    - { fstype: ext4, volume: home-lv, preserve: false, type: format, id: home-filesystem }
    - { path: /home, options: "relatime,nodev,nosuid", device: home-filesystem, type: mount, id: home-mount }
# 16G for opt
    - { size: 16G, volgroup: vg0, wipe: superblock, preserve: false, name: opt, type: lvm_partition, id: opt-lv }
    - { fstype: ext4, volume: opt-lv, preserve: false, type: format, id: opt-filesystem }
    - { path: /opt, options: "relatime,nodev,nosuid", device: opt-filesystem, type: mount, id: opt-mount }
# 16G for tmp
    - { size: 16G, volgroup: vg0, wipe: superblock, preserve: false, name: tmp, type: lvm_partition, id: tmp-lv }
    - { fstype: ext4, volume: tmp-lv, preserve: false, type: format, id: tmp-filesystem }
    - { path: /tmp, options: "noatime,nodev,nosuid,noexec", device: tmp-filesystem, type: mount, id: tmp-mount }
# 48G for var
    - { size: 48G, volgroup: vg0, wipe: superblock, preserve: false, name: var, type: lvm_partition, id: var-lv }
    - { fstype: ext4, volume: var-lv, preserve: false, type: format, id: var-filesystem }
    - { path: /var, options: "relatime,nodev,nosuid", device: var-filesystem, type: mount, id: var-mount }
# 8G for var/tmp
    - { size: 8G, volgroup: vg0, wipe: superblock, preserve: false, name: vartmp, type: lvm_partition, id: vartmp-lv }
    - { fstype: ext4, volume: vartmp-lv, preserve: false, type: format, id: vartmp-filesystem }
    - { path: /var/tmp, options: "noatime,nodev,noexec,nosuid", device: vartmp-filesystem, type: mount, id: vartmp-mount }
# 8G for var/log
    - { size: 8G, volgroup: vg0, wipe: superblock, preserve: false, name: log, type: lvm_partition, id: log-lv }
    - { fstype: ext4, volume: log-lv, preserve: false, type: format, id: log-filesystem }
    - { path: /var/log, options: "relatime,nodev,noexec,nosuid", device: log-filesystem, type: mount, id: log-mount }
# 8G for var/log/audit
    - { size: 8G, volgroup: vg0, wipe: superblock, preserve: false, name: audit, type: lvm_partition, id: audit-lv }
    - { fstype: ext4, volume: audit-lv, preserve: false, type: format, id: audit-filesystem }
    - { path: /var/log/audit, options: "relatime,nodev,noexec,nosuid", device: audit-filesystem, type: mount, id: audit-mount }
  late-commands:
    - "echo '${var.ssh_username} ALL=(ALL:ALL) ALL' > /target/etc/sudoers.d/${var.ssh_username}"
    - "chmod 440 /target/etc/sudoers.d/${var.ssh_username}"
