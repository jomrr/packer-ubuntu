#!/usr/bin/env bash
set -e

# Backup originally packaged sshd_config
cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config.pkg

sudo mkdir -m 0700 -p /etc/ssh/sshd_config.d

cat <<EOF > /etc/ssh/sshd_config
Port 22
AddressFamily inet
ListenAddress 0.0.0.0

HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key

SyslogFacility AUTH
LogLevel VERBOSE

Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256

PermitRootLogin no

# Password Authentication
PasswordAuthentication yes
PermitEmptyPasswords no

# Public Key Authentication
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
AuthorizedKeysCommand none
AuthorizedKeysCommandUser nobody

# Hostbased Authentication
HostbasedAuthentication no
IgnoreUserKnownHosts no
IgnoreRhosts yes

# GSSAPI Authentication
GSSAPIAuthentication no
# GSSAPICleanupCredentials yes
# GSSAPIStrictAcceptorCheck yes
# GSSAPIKeyExchange no
# GSSAPIEnablek5users no

# Kerberos Authentication
KerberosAuthentication no
# KerberosOrLocalPasswd yes
# KerberosTicketCleanup yes
# KerberosGetAFSToken no
# KerberosUseKuserok yes

UseDNS no
UsePAM yes

AllowTcpForwarding no
AllowAgentForwarding no
Banner /etc/issue.net
ClientAliveCountMax 3
ClientAliveInterval 300
Compression no
GatewayPorts no
LoginGraceTime 30
MaxAuthTries 3
MaxSessions 2
MaxStartups 10:30:60
PermitTTY yes
PermitTunnel no
PermitUserEnvironment no
PidFile /var/run/sshd.pid
PrintLastLog yes
PrintMotd no
StrictModes yes
Subsystem sftp /bin/false
TCPKeepAlive no
VersionAddendum none
X11Forwarding no
X11UseLocalhost yes
EOF

# Remove weak moduli from /etc/ssh/moduli file
awk '$5 >= 4096' /etc/ssh/moduli > /etc/ssh/moduli.new
test -f /etc/ssh/moduli.new && mv /etc/ssh/moduli.new /etc/ssh/moduli || true 

# Secure sshd_config files and keys
find /etc/ssh/ -type d -exec chmod 0700 {} \;
find /etc/ssh/ -type f -exec chown root:root {} \;
find /etc/ssh/ -type f -exec chmod 0600 {} \;

# Remove ssh host keys
# find /etc/ssh/ -name 'ssh_host_*_key' -delete

# Create sshd service drop-in directory
mkdir -p /etc/systemd/system/ssh.service.d

# declare -r HOSTKEY_DROPIN="/etc/systemd/system/ssh.service.d/hostkeys.conf"
declare -r NETWORK_DROPIN="/etc/systemd/system/ssh.service.d/network.conf"

# # Create script to regenerate host keys
# cat <<EOF > /usr/local/sbin/regenerate_host_keys.sh
# #!/usr/bin/env bash
# set -e
# #!/bin/bash

# # Check if any SSH host keys are missing and regenerate them if necessary
# # Do not create insecure DSA keys

# if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
#     echo "Generating RSA key..."
#     ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
# fi

# if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
#     echo "Generating ED25519 key..."
#     ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
# fi

# # Remove the systemd drop-in

# if [ -f "$HOSTKEY_DROPIN" ]; then
#     echo "Removing systemd hostkey drop-in file..."
#     rm -f "$HOSTKEY_DROPIN"
# fi

# # Reload systemd manager configuration
# systemctl daemon-reload

# # Remove the script after execution
# echo "Removing script..."
# rm -- "$0"
# EOF

# chown root:root /usr/local/sbin/regenerate_host_keys.sh
# chmod 750 /usr/local/sbin/regenerate_host_keys.sh

# # Create sshd service drop-in file for regenerating host keys
# cat <<EOF > $HOSTKEY_DROPIN
# [Service]
# ExecStartPre=/usr/local/sbin/regenerate_host_keys.sh
# EOF

# Create sshd service drop-in file for network-online.target
# otherwise sshd will fail if bound to specific IP (ListenAddress != 0.0.0.0)
cat <<EOF > $NETWORK_DROPIN
[Unit]
After=network-online.target
Requires=network-online.target
EOF

# Enable sshd
systemctl enable ssh
