#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

# # Remove cloud-init package
# apt-get -y purge cloud-init

# # Remove cloud-init folders
# rm -rf /etc/cloud /etc/cloud-init /var/lib/cloud

# # Remove cloud-init configuration and logs
# rm -rf /var/log/cloud-init*.log

# # Reinstall netplan as it is removed with cloud-init
# apt-get -y install netplan.io
