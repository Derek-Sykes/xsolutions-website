# X Solutions website

The existing static coming-soon page at https://xsolutionsmd.com/, served by Caddy in Docker Compose. The full business website is future work.

## Files

- `xsolutions-site/`: public HTML, favicon, robots.txt and sitemap.
- `compose.yaml`: Caddy service, public ports and persistent certificate volumes.
- `Caddyfile`: domain routing, HTTPS and static-file configuration.
- `scripts/deploy-static.sh`: manually publish the checked-out static files to the existing Oracle server, with a backup and content verification.

Compose uses the official Caddy image pinned to a tested digest, so this static setup does not need a custom Dockerfile. A future server-side app can add its own Dockerfile and service.

## Update the existing Oracle website

1. Edit/test the site locally, commit and push to GitHub.
2. SSH into the existing Oracle server as `ubuntu`.
3. Run:

```bash
cd /home/ubuntu/xsolutions-website
git pull --ff-only
bash scripts/deploy-static.sh --check
bash scripts/deploy-static.sh
```

The check previews file changes. The deploy publishes only `xsolutions-site/` into `/opt/xsolutions/xsolutions-site/`; removed source files are also removed from that live public folder. It never publishes `.git`, secrets or the repository's other files. It preserves the running Caddy configuration and certificate volumes. GitHub pushes alone do not update the live website.

The deploy script requires Git, rsync, curl and sudo access on the Ubuntu VM. It checks for a clean checkout and an index.html, creates a dated backup of the current public folder, copies files and verifies that HTTPS returns the expected index content. Review errors before retrying. A plain static copy can briefly expose mixed old/new assets during a larger update.

Backups created by this script are under `/var/backups/xsolutions/deployments/`; prune old copies deliberately as disk usage grows. The existing daily site/config backup remains separate. To undo a code change, push a revert commit and pull/deploy it, or restore an appropriate backup. Database migrations are outside this static workflow.

## Inspect the live service

```bash
cd /opt/xsolutions
sudo docker compose ps
sudo docker compose logs --tail 50 web
```

Website file edits do not need a Caddy restart. Compose/Caddyfile changes require a separate reviewed deployment; this script intentionally deploys only public static files. Before changing Caddy configuration, back it up, validate it and reload it. Do not remove the named certificate volumes with `docker compose down -v`.

## Local preview

With Python installed, run from the repository root:

```bash
python -m http.server 8765 --directory xsolutions-site --bind 127.0.0.1
```

Open http://127.0.0.1:8765. This preview is local HTTP; production HTTPS is handled by Caddy.

## Fresh-server deployment

On a configured Linux host with Docker/Compose, point the domain at it, allow ports 80 and 443, then run `docker compose up -d` from this repository. Caddy obtains certificates once the domain is reachable. The existing Oracle deployment retains its original directory and volumes; do not start a second competing web stack from the server clone.

The repository is public and contains no administrator credentials. The Oracle server clones it over HTTPS with anonymous read access; no GitHub token or deploy key is needed. Administrative SSH credentials stay outside the repository. Changes to paid services, application hosting or automatic deployment are not part of this baseline.
