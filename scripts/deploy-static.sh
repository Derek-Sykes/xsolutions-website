#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "--check" ) ]]; then
  echo 'Usage: bash scripts/deploy-static.sh [--check]' >&2
  exit 2
fi
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
source_dir="$repo/xsolutions-site"
target_dir=/opt/xsolutions/xsolutions-site
for command in git rsync curl; do
  command -v "$command" >/dev/null || { echo "Missing dependency: $command" >&2; exit 1; }
done
[[ -s "$source_dir/index.html" ]] || { echo 'Missing public index.html' >&2; exit 1; }
[[ -d "$target_dir" && ! -L "$target_dir" ]] || { echo 'Expected existing live directory is absent or a symlink' >&2; exit 1; }
[[ -z "$(git -C "$repo" status --porcelain)" ]] || { echo 'Commit or resolve local repository changes before deploying' >&2; exit 1; }
if [[ -n "$(find "$source_dir" -type l -print -quit)" ]]; then
  echo 'Public folder contains a symlink; review before publishing' >&2
  exit 1
fi
commit=$(git -C "$repo" rev-parse --short HEAD)
if [[ "${1:-}" == '--check' ]]; then
  sudo rsync -rt --delete --dry-run --itemize-changes --chown=root:root --chmod=D755,F644 "$source_dir/" "$target_dir/"
  echo "Preview complete for commit $commit. No website files changed."
  exit 0
fi

backup_dir=/var/backups/xsolutions/deployments
sudo install -d -m 700 "$backup_dir"
backup_file="$backup_dir/site-$(date -u +%Y%m%dT%H%M%S%N)-before-$commit.tar.gz"
sudo tar -czf "$backup_file" -C /opt/xsolutions xsolutions-site
sudo chmod 600 "$backup_file"
sudo rsync -rt --delete --itemize-changes --chown=root:root --chmod=D755,F644 "$source_dir/" "$target_dir/"
expected=$(sha256sum "$source_dir/index.html" | cut -d ' ' -f 1)
actual=$(curl --fail --silent --show-error --max-time 30 https://xsolutionsmd.com/ | sha256sum | cut -d ' ' -f 1)
[[ "$expected" == "$actual" ]] || { echo "HTTPS content verification failed. Backup: $backup_file" >&2; exit 1; }
echo "Deployed commit $commit; HTTPS index content verified. Backup: $backup_file"
