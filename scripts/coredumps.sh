#!/usr/bin/env bash
set -e

# Disable core dumps for all users
cat <<EOF > /etc/security/limits.d/99-disable-coredumps.conf
* hard core 0
* soft core 0
EOF

# Disable core dumps for setuid programs
cat <<EOF > /etc/sysctl.d/50-disable-coredumps.conf
fs.suid_dumpable = 0
kernel.core_pattern=|/bin/false
EOF

# Disable core dumps in systemd
sudo mkdir -p /etc/systemd/coredump.conf.d/
cat <<EOF > /etc/systemd/coredump.conf.d/disable.conf
[Coredump]
Storage=none
ProcessSizeMax=0
EOF

# Make sure DefaultLimitCORE commented out
sed -i '/.*DefaultLimitCORE=/ s/^/#/' /etc/systemd/system.conf

# Disable core dumps in bash
echo 'ulimit -S -c 0' >> /etc/profile
