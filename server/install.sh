#!/usr/bin/env bash
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Run with sudo on the existing Oracle server.' >&2; exit 1; }
cd "$(dirname "$0")/.."
test -f /opt/xsolutions/compose.yaml
docker volume inspect xsolutions_caddy_data xsolutions_caddy_config >/dev/null
install -d -m 700 /var/lib/xsolutions-deploy
install -d -m 755 /usr/local/share/xsolutions
if [[ ! -f /var/lib/xsolutions-deploy/original-compose.yaml ]]; then
  cp /opt/xsolutions/compose.yaml /var/lib/xsolutions-deploy/original-compose.yaml
fi
install -m 644 compose.yaml /usr/local/share/xsolutions/compose.yaml
install -m 755 server/update-release.sh /usr/local/sbin/xsolutions-update
install -m 644 server/xsolutions-update.service /etc/systemd/system/xsolutions-update.service
install -m 644 server/xsolutions-update.timer /etc/systemd/system/xsolutions-update.timer
systemctl daemon-reload
systemctl enable --now xsolutions-update.timer
echo 'Release updater installed; checks published main releases every minute.'
