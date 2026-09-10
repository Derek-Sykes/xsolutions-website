#!/usr/bin/env bash
# Installed root-owned; only follows this repository's published main releases.
set -euo pipefail
umask 077
repo=Derek-Sykes/xsolutions-website
root=/opt/xsolutions
state=/var/lib/xsolutions-deploy
mkdir -p "$state"
exec 9>"$state/update.lock"
flock -n 9 || exit 0
work=$(mktemp -d "$state/check.XXXXXX")
candidate="xsolutions-candidate-$$"
deployment_started=false
committed=false
had_current=false
compose=(docker compose --project-directory "$root" --env-file "$root/release.env" -f "$root/compose.yaml")
next_compose=(docker compose --project-name xsolutions --project-directory "$root" --env-file "$work/next.env" -f "$work/next-compose.yaml")
rollback() {
  echo 'New release failed or was interrupted; restoring the previous container definition.' >&2
  cp "$work/previous-compose.yaml" "$root/compose.yaml" || return 1
  cp "$work/previous.env" "$root/release.env" || return 1
  "${compose[@]}" up -d --no-build --wait --wait-timeout 90 || return 1
  if [[ "$had_current" == true ]]; then
    cp "$work/previous-current.json" "$state/current.json.new" || return 1
    mv "$state/current.json.new" "$state/current.json" || return 1
  else
    rm -f -- "$state/current.json" "$state/current.json.new" || return 1
  fi
}
cleanup() {
  status=$?
  trap - EXIT
  trap '' TERM INT
  recovered=true
  if [[ "$deployment_started" == true && "$committed" != true ]]; then
    if ! rollback; then
      recovered=false
      status=1
      echo "Automatic recovery failed; recovery files retained in $work. Inspect xsolutions-update.service immediately." >&2
    fi
  fi
  docker rm -f -v "$candidate" >/dev/null 2>&1 || true
  if [[ "$recovered" == true ]]; then rm -rf -- "$work"; fi
  exit "$status"
}
trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT
main=$(timeout 30 git ls-remote "https://github.com/$repo.git" refs/heads/main | cut -f1)
[[ "$main" =~ ^[0-9a-f]{40}$ ]] || { echo 'Cannot determine current main revision.' >&2; exit 1; }
if [[ -f "$state/current.json" ]] && python3 -c 'import json,sys; sys.exit(json.load(open(sys.argv[1]))["revision"] != sys.argv[2])' "$state/current.json" "$main"; then exit 0; fi
# Address the exact commit, avoiding cached latest redirects and negative responses
# observed while an image was still being published.
status=$(curl -LsS --connect-timeout 15 --max-time 60 --retry 2 -w '%{http_code}' \
  "https://github.com/$repo/releases/download/release-$main/deployment.json?check=$(date +%s)" -o "$work/deployment.json")
if [[ "$status" == 404 ]]; then echo 'Current main is still building; keeping the healthy website.'; exit 0; fi
[[ "$status" == 200 ]] || { echo "Release download failed (HTTP $status)." >&2; exit 1; }
mapfile -t release < <(python3 - "$work/deployment.json" <<'PY'
import json,re,sys
from pathlib import Path
p=Path(sys.argv[1])
assert p.stat().st_size < 4096, 'Oversized release manifest'
d=json.loads(p.read_text())
assert re.fullmatch(r'[0-9a-f]{40}',d['revision']), 'Invalid revision'
assert re.fullmatch(r'ghcr.io/derek-sykes/xsolutions-website@sha256:[0-9a-f]{64}',d['image']), 'Invalid image'
print(d['revision']); print(d['image'])
PY
)
[[ ${#release[@]} == 2 ]] || { echo 'Invalid release manifest' >&2; exit 1; }
revision=${release[0]}
image=${release[1]}
if [[ -f "$state/current.json" ]] && cmp -s "$state/current.json" "$work/deployment.json"; then exit 0; fi
[[ "$revision" == "$main" ]] || { echo 'Waiting for a release of the current main revision.'; exit 0; }
docker network inspect xsolutions-proxy >/dev/null || {
  echo 'Required xsolutions-proxy network is missing; keeping the existing deployment.' >&2
  exit 1
}
docker pull "$image"
[[ $(docker image inspect "$image" --format '{{.Architecture}}') == arm64 ]]
[[ $(docker image inspect "$image" --format '{{index .Config.Labels "org.opencontainers.image.revision"}}') == "$revision" ]]
[[ $(docker image inspect "$image" --format '{{index .Config.Labels "org.opencontainers.image.source"}}') == "https://github.com/$repo" ]]
docker run --rm --tmpfs /data --tmpfs /config --entrypoint caddy "$image" validate --config /etc/caddy/Caddyfile --adapter caddyfile
# Exercise the candidate without touching public ports or certificate storage.
docker run -d --name "$candidate" --tmpfs /data --tmpfs /config -p 127.0.0.1::80 "$image"
port=$(docker port "$candidate" 80/tcp | awk -F: '{print $NF}')
ready=false
for attempt in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:$port/version.json" | grep -Fq "$revision"; then ready=true; break; fi
  sleep 1
done
[[ "$ready" == true ]]
curl -fsS "http://127.0.0.1:$port/" -o "$work/candidate.html"
test -s "$work/candidate.html"
docker rm -f -v "$candidate" >/dev/null
# Recheck after the pull/test in case another main commit arrived.
[[ "$revision" == "$(git ls-remote "https://github.com/$repo.git" refs/heads/main | cut -f1)" ]] || exit 0
cp "$root/compose.yaml" "$work/previous-compose.yaml"
if [[ -f "$root/release.env" ]]; then cp "$root/release.env" "$work/previous.env"; else touch "$work/previous.env"; fi
if [[ -f "$state/current.json" ]]; then
  cp "$state/current.json" "$work/previous-current.json"
  had_current=true
fi
cp /usr/local/share/xsolutions/compose.yaml "$work/next-compose.yaml"
printf 'XSOLUTIONS_IMAGE=%s\n' "$image" > "$work/next.env"
"${next_compose[@]}" config --quiet
deployment_started=true
cp "$work/next-compose.yaml" "$root/compose.yaml"
cp "$work/next.env" "$root/release.env"
"${compose[@]}" up -d --no-build --wait --wait-timeout 90
verified=false
for attempt in $(seq 1 30); do
  if curl -fsS --max-time 10 --resolve xsolutionsmd.com:443:127.0.0.1 https://xsolutionsmd.com/version.json | grep -Fq "$revision" \
    && curl -fsS --max-time 10 --resolve xsolutionsmd.com:443:127.0.0.1 https://xsolutionsmd.com/ -o "$work/live.html" \
    && cmp -s "$work/candidate.html" "$work/live.html"; then verified=true; break; fi
  sleep 2
done
[[ "$verified" == true ]]
cp "$work/previous-compose.yaml" "$state/previous-compose.yaml"
cp "$work/previous.env" "$state/previous.env"
cp "$work/deployment.json" "$state/current.json.new"
mv "$state/current.json.new" "$state/current.json"
committed=true
echo "Deployed and verified $revision ($image)."
