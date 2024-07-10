#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Install ufw
apt-get -y install ufw

# Default deny incoming
ufw default deny incoming

# Allow SSH
ufw allow 22/tcp

# Enable ufw
echo y | ufw enable
