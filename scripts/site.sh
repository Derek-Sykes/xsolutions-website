#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
action="${1:-start}"
export XSOLUTIONS_REVISION
XSOLUTIONS_REVISION=$(git rev-parse HEAD)
compose=(docker compose -f compose.local.yaml)
case "$action" in
  update)
    branch=$(git branch --show-current)
    [[ "$branch" == dev || "$branch" == main ]] || { echo 'Update requires the dev or main branch.' >&2; exit 1; }
    [[ -z $(git status --porcelain --untracked-files=all) ]] || { echo 'Commit or stash local changes before updating.' >&2; exit 1; }
    git fetch origin "$branch"
    git merge --ff-only "origin/$branch"
    XSOLUTIONS_REVISION=$(git rev-parse HEAD)
    "${compose[@]}" build
    "${compose[@]}" up -d --no-build --wait --wait-timeout 90
    echo "Local website: http://localhost:${XSOLUTIONS_PORT:-8787} (branch $branch)"
    ;;
  build) "${compose[@]}" build ;;
  start)
    "${compose[@]}" build
    "${compose[@]}" up -d --no-build --wait --wait-timeout 90
    echo "Local website: http://localhost:${XSOLUTIONS_PORT:-8787}"
    ;;
  stop) "${compose[@]}" down ;;
  status) "${compose[@]}" ps ;;
  logs) "${compose[@]}" logs --tail 80 ;;
  check) bash scripts/check.sh ;;
  *) echo 'Usage: bash scripts/site.sh {build|start|update|stop|status|logs|check}' >&2; exit 2 ;;
esac
