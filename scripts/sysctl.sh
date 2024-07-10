#!/usr/bin/env bash
set -e

cat <<EOF > /etc/sysctl.d/99-harden-ipv4.conf
# Disable Accepting ICMP Redirects for All IPv4 Interfaces
net.ipv4.conf.all.accept_redirects = 0
# Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv4 Interfaces
net.ipv4.conf.all.accept_source_route = 0
# Enable Kernel Parameter to Log Martian Packets on all IPv4 Interfaces
net.ipv4.conf.all.log_martians = 1
# Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces
net.ipv4.conf.all.rp_filter = 1
# Disable Kernel Parameter for Accepting Secure ICMP Redirects on all IPv4 Interfaces
net.ipv4.conf.all.secure_redirects = 0
# Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv4 Interfaces
net.ipv4.conf.default.accept_redirects = 0
# Disable Kernel Parameter for Accepting Source-Routed Packets on IPv4 Interfaces by Default
net.ipv4.conf.default.accept_source_route = 0
# Enable Kernel Paremeter to Log Martian Packets on all IPv4 Interfaces by Default
net.ipv4.conf.default.log_martians = 1
# Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces by Default
net.ipv4.conf.default.rp_filter = 1
# Configure Kernel Parameter for Accepting Secure Redirects By Default
net.ipv4.conf.default.secure_redirects = 0
# Enable Kernel Parameter to Ignore ICMP Broadcast Echo Requests on IPv4 Interfaces
net.ipv4.icmp_echo_ignore_broadcasts = 1
# Enable Kernel Parameter to Ignore Bogus ICMP Error Responses on IPv4 Interfaces
net.ipv4.icmp_ignore_bogus_error_responses = 1
# Enable Kernel Parameter to Use TCP Syncookies on Network Interfaces
net.ipv4.tcp_syncookies = 1
# Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces
net.ipv4.conf.all.send_redirects = 0
# Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces by Default
net.ipv4.conf.default.send_redirects = 0
EOF

cat <<EOF > /etc/sysctl.d/99-harden-kernel.conf
# Restrict Exposed Kernel Pointer Addresses Access
kernel.kptr_restrict = 1
# Enable Randomized Layout of Virtual Address Space
kernel.randomize_va_space = 2
EOF
