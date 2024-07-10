#!/usr/bin/env bash
set -e

# Mask sleep, suspend, hibernate, hybrid-sleep, and ctrl-alt-del.target
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target ctrl-alt-del.target
