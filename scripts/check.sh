#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
revision=$(git rev-parse HEAD)
image="xsolutions-check:$revision"
container="xsolutions-check-$$"
cleanup() { docker rm -f "$container" >/dev/null 2>&1 || true; }
trap cleanup EXIT
for script in ./*.sh scripts/*.sh server/*.sh; do bash -n "$script"; done
git diff --check
test -s xsolutions-site/index.html
docker build --build-arg "REVISION=$revision" -t "$image" .
MSYS_NO_PATHCONV=1 docker run --rm --entrypoint caddy "$image" validate --config /etc/caddy/Caddyfile --adapter caddyfile
MSYS_NO_PATHCONV=1 docker run -d --name "$container" -p 127.0.0.1::80 "$image" caddy run --config /etc/caddy/Caddyfile.local --adapter caddyfile
port=$(docker port "$container" 80/tcp | awk -F: '{print $NF}' | tr -d '\r')
for attempt in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:$port/version.json" | grep -q "$revision"; then break; fi
  sleep 1
done
curl -fsS "http://127.0.0.1:$port/" | cmp - xsolutions-site/index.html
for asset in favicon.svg robots.txt sitemap.xml; do
  curl -fsS "http://127.0.0.1:$port/$asset" | cmp - "xsolutions-site/$asset"
done
curl -fsS "http://127.0.0.1:$port/version.json" | grep -q "$revision"
test "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/.git/config")" = 404
echo 'Container configuration, all public files, release identity and source exclusion passed.'
