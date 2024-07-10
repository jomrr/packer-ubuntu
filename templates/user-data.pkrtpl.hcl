#cloud-config
autoinstall:
  source:
    id: ubuntu-server-minimal
  version: 1
  early-commands:
    - systemctl disable --now ssh # runs in install env, disable for reboot
  identity:
    hostname: ${var.hostname}
    username: ${var.ssh_username}
    password: ${var.ssh_password_encrypted}
  keyboard:
    layout: de
  locale: en_US.UTF-8
  kernel:
    package: linux-virtual
  packages: [${join(",", [for package in concat(local.common_packages, source.value.packages) : "\"${package}\""])}]
  ssh:
    install-server: yes
    allow-pw: yes
  user-data:
    disable_root: true
  timezone: Europe/Berlin
  updates: all
  late-commands:
    - systemctl enable --now ssh # runs in install env
  storage:
    grub:
      reorder_uefi: false
    config:
# Disk setup
    - { ptable: gpt, path: ${disk}, wipe: superblock, preserve: false, grub_device: false, type: disk, id: disk0 }
# EFI Partition
    - { device: disk0, type: partition, size: 1G, flag: esp, number: 1, partition_type: EF00, grub_device: true, wipe: superblock, preserve: false, id: efi-partition }
    - { fstype: fat32, volume: efi-partition, preserve: false, type: format, id: efi-filesystem }
    - { path: /boot/efi, options: "defaults,uid=0,gid=0,umask=077,shortname=winnt", device: efi-filesystem, type: mount, id: efi-mount }
# Linux boot partition
    - { device: disk0, size: 1G, wipe: superblock, flag: boot, number: 2, preserve: false, grub_device: false, type: partition, id: boot-partition }
    - { fstype: ext4, volume: boot-partition, preserve: false, type: format, id: boot-filesystem }
    - { path: /boot, options: "noatime", device: boot-filesystem, type: mount, id: boot-mount }
# Partition for LVM Physical Volume and LVM Volume Group
    - { device: disk0, size: -1, wipe: superblock, flag: '', number: 3, preserve: false, grub_device: false, type: partition, id: pv0 }
    - { name: vg0, devices: [pv0], preserve: false, type: lvm_volgroup, id: vg0 }
# LVM Logical Volumes
# 32G for root
    - { size: 32G, volgroup: vg0, wipe: superblock, preserve: false, name: root, type: lvm_partition, id: root-lv }
    - { fstype: ext4, volume: root-lv, preserve: false, type: format, id: root-filesystem }
    - { path: /, options: "noatime", device: root-filesystem, type: mount, id: root-mount }
# 48G for home
    - { size: 48G, volgroup: vg0, wipe: superblock, preserve: false, name: home, type: lvm_partition, id: home-lv }
    - { fstype: ext4, volume: home-lv, preserve: false, type: format, id: home-filesystem }
    - { path: /home, options: "noatime,nodev,nosuid", device: home-filesystem, type: mount, id: home-mount }
# 16G for opt
    - { size: 16G, volgroup: vg0, wipe: superblock, preserve: false, name: opt, type: lvm_partition, id: opt-lv }
    - { fstype: ext4, volume: opt-lv, preserve: false, type: format, id: opt-filesystem }
    - { path: /opt, options: "noatime,nodev,nosuid", device: opt-filesystem, type: mount, id: opt-mount }
# 16G for tmp
    - { size: 16G, volgroup: vg0, wipe: superblock, preserve: false, name: tmp, type: lvm_partition, id: tmp-lv }
    - { fstype: ext4, volume: tmp-lv, preserve: false, type: format, id: tmp-filesystem }
    - { path: /tmp, options: "noatime,nodev,nosuid", device: tmp-filesystem, type: mount, id: tmp-mount }
# 48G for var
    - { size: 48G, volgroup: vg0, wipe: superblock, preserve: false, name: var, type: lvm_partition, id: var-lv }
    - { fstype: ext4, volume: var-lv, preserve: false, type: format, id: var-filesystem }
    - { path: /var, options: "noatime,nodev,nosuid", device: var-filesystem, type: mount, id: var-mount }
# 8G for var/tmp
    - { size: 8G, volgroup: vg0, wipe: superblock, preserve: false, name: vartmp, type: lvm_partition, id: vartmp-lv }
    - { fstype: ext4, volume: vartmp-lv, preserve: false, type: format, id: vartmp-filesystem }
    - { path: /var/tmp, options: "noatime,nodev,nosuid", device: vartmp-filesystem, type: mount, id: vartmp-mount }
# 8G for var/log
    - { size: 8G, volgroup: vg0, wipe: superblock, preserve: false, name: log, type: lvm_partition, id: log-lv }
    - { fstype: ext4, volume: log-lv, preserve: false, type: format, id: log-filesystem }
    - { path: /var/log, options: "noatime,nodev,noexec,nosuid", device: log-filesystem, type: mount, id: log-mount }
# 8G for var/log/audit
    - { size: 8G, volgroup: vg0, wipe: superblock, preserve: false, name: audit, type: lvm_partition, id: audit-lv }
    - { fstype: ext4, volume: audit-lv, preserve: false, type: format, id: audit-filesystem }
    - { path: /var/log/audit, options: "noatime,nodev,noexec,nosuid", device: audit-filesystem, type: mount, id: audit-mount }
