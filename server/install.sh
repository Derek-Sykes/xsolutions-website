#!/usr/bin/env bash
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Run with sudo on the existing Oracle server.' >&2; exit 1; }
[[ $# == 0 || ( $# == 1 && $1 == --paused ) ]] || { echo 'Usage: sudo bash server/install.sh [--paused]' >&2; exit 2; }
cd "$(dirname "$0")/.."
test -f /opt/xsolutions/compose.yaml
docker network inspect xsolutions-proxy >/dev/null || {
  echo 'Install the shared gateway and its xsolutions-proxy network before this updater. See server/gateway/README.md.' >&2
  exit 1
}
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
if [[ ${1:-} == --paused ]]; then
  systemctl disable --now xsolutions-update.timer
  echo 'Release updater installed with timer paused. Resume after verifying the gateway migration.'
else
  systemctl enable --now xsolutions-update.timer
  echo 'Release updater installed; checks published main releases every minute.'
fi
