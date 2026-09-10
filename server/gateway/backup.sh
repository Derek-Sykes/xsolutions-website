#!/usr/bin/env bash
# Installed at /usr/local/sbin/xsolutions-backup; existing daily timer is reused.
set -euo pipefail
umask 077
backup_dir=/var/backups/xsolutions
mkdir -p "$backup_dir"
paths=(xsolutions xsolutions-gateway)
if [[ -d /opt/dylan-demo ]]; then paths+=(dylan-demo); fi
tar -czf "$backup_dir/site-$(date -u +%F).tar.gz" -C /opt "${paths[@]}"
find "$backup_dir" -maxdepth 1 -type f -name 'site-*.tar.gz' -mtime +7 -delete
