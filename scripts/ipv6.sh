#!/usr/bin/env bash
set -e

# Enable apparmor via kernel
sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ ipv6.disable=1"/' /etc/default/grub

# Update grub bootloader
update-grub
