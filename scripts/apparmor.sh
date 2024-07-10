#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Install apparmor and profiles
apt-get -y install \
    apparmor apparmor-profiles apparmor-profiles-extra apparmor-utils

# Enable apparmor via kernel
sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ apparmor=1 security=apparmor"/' /etc/default/grub

# Update grub bootloader
update-grub

# Set all installed apparmor profiles to enforcing
find /etc/apparmor.d -maxdepth 1 -type f -exec aa-enforce {} \;
