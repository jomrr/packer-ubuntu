#!/usr/bin/env bash
set -e

# Clear log files
find /var/log -type f -exec truncate -s 0 {} \;

# flush journal logs
journalctl --flush

# Remove netplan installer config, apt cache, dhcp, random seed and tmp files
rm -rf \
    /var/lib/dhcp/* \
    /var/lib/systemd/random-seed \
    /var/tmp/* \
    /tmp/*

# Zero out the free space to save space in the final image, if discard supported
if [ "$PACKER_BUILDER_TYPE" == "qemu" ] || [ "$PACKER_BUILDER_TYPE" == "proxmox-iso" ]; then
    echo "Zeroing out disk space..."
    dd if=/dev/zero of=/empty bs=1M || rm -f /empty 2>/dev/null
fi

# Clear history
history -c
