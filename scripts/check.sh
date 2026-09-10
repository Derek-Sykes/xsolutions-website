#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
revision=$(git rev-parse HEAD)
image="xsolutions-check:$revision"
container="xsolutions-check-$$"
proxy="xsolutions-proxy-check-$$"
preview="xsolutions-preview-check-$$"
network="xsolutions-check-$$"
cleanup() {
  docker rm -f -v "$container" "$proxy" "$preview" >/dev/null 2>&1 || true
  docker network rm "$network" >/dev/null 2>&1 || true
}
trap cleanup EXIT
for script in ./*.sh scripts/*.sh server/*.sh; do bash -n "$script"; done
git diff --check
test -s xsolutions-site/index.html
docker build --build-arg "REVISION=$revision" -t "$image" .
XSOLUTIONS_IMAGE="$image" docker compose -f compose.yaml config -q
MSYS_NO_PATHCONV=1 docker run --rm --tmpfs /data --tmpfs /config --entrypoint caddy "$image" validate --config /etc/caddy/Caddyfile --adapter caddyfile
MSYS_NO_PATHCONV=1 docker run --rm --tmpfs /data --tmpfs /config --entrypoint caddy "$image" validate --config /etc/caddy/Caddyfile.local --adapter caddyfile
docker network create "$network" >/dev/null
# Exercise the production default, including container-name resolution at the gateway.
MSYS_NO_PATHCONV=1 docker run -d --name "$container" --tmpfs /data --tmpfs /config --network "$network" --network-alias xsolutions-site -p 127.0.0.1::80 "$image"
test -z "$(docker inspect "$container" --format '{{range .Mounts}}{{if eq .Type "volume"}}{{.Name}}{{end}}{{end}}')"
port=$(docker port "$container" 80/tcp | awk -F: '{print $NF}' | tr -d '\r')
for attempt in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:$port/version.json" | grep -q "$revision"; then break; fi
  sleep 1
done
while IFS= read -r -d '' asset; do
  curl -fsS "http://127.0.0.1:$port/${asset#xsolutions-site/}" | cmp - "$asset"
done < <(find xsolutions-site -type f -print0)
curl -fsS "http://127.0.0.1:$port/version.json" | grep -q "$revision"
curl -fsSI "http://127.0.0.1:$port/version.json" | grep -iq '^Cache-Control: no-store'
test "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/.git/config")" = 404
MSYS_NO_PATHCONV=1 docker exec "$container" wget -q -O - http://127.0.0.1:8081/version.json | grep -q "$revision"
MSYS_NO_PATHCONV=1 docker run -d --name "$proxy" --tmpfs /data --tmpfs /config --network "$network" -p 127.0.0.1::80 "$image" \
  caddy reverse-proxy --from http://xsolutions.test:80 --to xsolutions-site:80
proxy_port=$(docker port "$proxy" 80/tcp | awk -F: '{print $NF}' | tr -d '\r')
for attempt in $(seq 1 30); do
  if curl -fsS -H 'Host: xsolutions.test' "http://127.0.0.1:$proxy_port/version.json" | grep -q "$revision"; then break; fi
  sleep 1
done
curl -fsS -H 'Host: xsolutions.test' "http://127.0.0.1:$proxy_port/" | cmp - xsolutions-site/index.html
curl -fsSI -H 'Host: xsolutions.test' "http://127.0.0.1:$proxy_port/" | grep -iq '^X-Frame-Options: DENY'
curl -fsSI -H 'Host: xsolutions.test' "http://127.0.0.1:$proxy_port/version.json" | grep -iq '^Cache-Control: no-store'
# Keep the preview launchers equivalent while retaining no-cache development responses.
MSYS_NO_PATHCONV=1 docker run -d --name "$preview" --tmpfs /data --tmpfs /config -p 127.0.0.1::80 "$image" caddy run --config /etc/caddy/Caddyfile.local --adapter caddyfile
preview_port=$(docker port "$preview" 80/tcp | awk -F: '{print $NF}' | tr -d '\r')
for attempt in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:$preview_port/version.json" | grep -q "$revision"; then break; fi
  sleep 1
done
curl -fsS "http://127.0.0.1:$preview_port/" | cmp - xsolutions-site/index.html
curl -fsSI "http://127.0.0.1:$preview_port/" | grep -iq '^Cache-Control: no-store'
echo 'Production and preview configuration, every public file, release identity, health, source exclusion and reverse-proxy integration passed.'
