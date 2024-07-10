#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Install ufw
apt-get -y install ufw

# Default deny incoming
ufw default deny incoming

# Allow SSH
ufw allow 22/tcp

# Retrict Loopback traffic
ufw allow in on lo
ufw allow out on lo
ufw deny in from 127.0.0.0/8
ufw deny in from ::1

# Enable ufw
echo y | ufw enable
