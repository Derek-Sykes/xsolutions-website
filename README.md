# X Solutions website

The website at **https://xsolutionsmd.com**, served by a versioned Caddy container on Oracle. Work on `dev`; merge `dev` into `main` when you want to publish.

## Start on a desktop or laptop

Install Git and Docker Desktop (Linux containers), then clone once:

```bash
git clone --branch dev https://github.com/Derek-Sykes/xsolutions-website.git
cd xsolutions-website
bash start.sh
```

Open **http://localhost:8787**. Edit public files in `xsolutions-site/`, then run `bash start.sh` again to rebuild and see changes. Each computer has its own clone; Git transfers committed changes between them.

| Task | Bash (Git Bash, Linux, macOS, WSL) | Windows PowerShell |
|---|---|---|
| Build container | `bash build.sh` | `.\website.ps1 build` |
| Build and start preview | `bash start.sh` | `.\website.ps1 start` |
| Pull current branch, rebuild and start | `bash update.sh` | `.\website.ps1 update` |
| Stop preview | `bash stop.sh` | `.\website.ps1 stop` |
| Check container and public files | `bash scripts/site.sh check` | `.\website.ps1 check` |
| View status / logs | `bash scripts/site.sh status` / `logs` | `.\website.ps1 status` / `logs` |

If Windows blocks the PowerShell script, use Git Bash or `powershell -ExecutionPolicy Bypass -File .\website.ps1 start` for that invocation. No permanent policy change is needed.

Update follows the currently selected `dev` or `main` branch. It refuses uncommitted changes, feature branches and diverged history instead of overwriting work. It builds before replacing the running local container. Set `XSOLUTIONS_PORT` in your shell if 8787 is occupied. Preview listens only on your computer.

## Develop, test, release

1. On the desktop, work on `dev` (or merge a feature branch into `dev`), check changes, commit and push.
2. On the laptop, run `bash update.sh` or `.\website.ps1 update`, then test the local site.
3. In [GitHub Pull requests](https://github.com/Derek-Sykes/xsolutions-website/pulls), create a PR with **base: main**, **compare: dev**.
4. Wait for **Check website container** to pass, then merge. Keep the long-lived `dev` branch.
5. Watch [Actions](https://github.com/Derek-Sykes/xsolutions-website/actions). **Publish and deploy to Oracle** succeeds after verifying the expected revision and page content over HTTPS.

Only main releases deploy. Dev pushes check the site and leave the live version alone. No Action merges branches automatically. Continue working on dev after release; merging main back into dev is optional unless main received separate changes.

## How deployment works

```text
dev → reviewed merge into main → container checks
    → build AMD64 + ARM64 images → GitHub Container Registry
    → publish release manifest with exact image digest
    → Oracle downloads and checks release → replace website container
    → GitHub confirms live revision and page content
```

Oracle's small system timer checks main about once a minute and downloads that exact commit's published release when ready. Builds and tests happen on GitHub's machines. Expect a few minutes from merge to completed deployment. Your computers can be off.

The server uses outbound HTTPS and public release/image downloads. No GitHub runner, GitHub credential or additional SSH port is installed on Oracle. Source and image contain only the public site and safe configuration. GitHub uses its temporary workflow token to publish.

The updater accepts only this repository's image digest and current main revision, verifies ARM64/source labels, tests a temporary candidate, then updates the existing `xsolutions` stack. The image contains the website and Caddy configuration. Existing certificate volumes stay attached. If live checks fail after replacement, it restores the previous container configuration. Replacement may cause a brief interruption.

`/version.json` identifies the running source commit and contains no secret. Release tags are `release-<full main commit>` with a `deployment.json` asset. Images are tagged `sha-<full main commit>` and deployed by digest. Superseded main workflows skip release publication/deployment.

## Files

- `xsolutions-site/`: edit the public website here.
- `Dockerfile`, `Caddyfile`: production image and HTTPS routing.
- `Caddyfile.local`, `compose.local.yaml`: local preview on port 8787.
- `compose.yaml`: Oracle stack using `XSOLUTIONS_IMAGE` and external certificate volumes.
- `.github/workflows/website.yml`: tests, publication and live verification.
- `server/`: installed Oracle updater, installer and timer.
- `scripts/` and root launchers: local build/start/update/check commands.
- `docs/VALIDATION.md`: actual setup and release test results.

The Docker context is explicitly limited to image inputs. Repository history and development credentials are excluded.

## Server operation and recovery

Use existing administrator SSH access, then:

```bash
sudo systemctl status xsolutions-update.timer
sudo journalctl -u xsolutions-update.service -n 60 --no-pager
sudo cat /var/lib/xsolutions-deploy/current.json
sudo docker compose --env-file /opt/xsolutions/release.env -f /opt/xsolutions/compose.yaml ps
```

Check immediately: `sudo systemctl start xsolutions-update.service`. Pause: `sudo systemctl stop xsolutions-update.timer` (use `disable --now` to persist across reboot). Resume: `sudo systemctl enable --now xsolutions-update.timer`.

For content rollback, revert the unwanted change on dev and merge the correction into main. Automatic failure recovery retains the previous Compose/image settings under `/var/lib/xsolutions-deploy/`; the initial static definition is saved as `original-compose.yaml`.

The existing daily backup still saves `/opt/xsolutions`. Current site content is now in versioned GitHub source and images, not the legacy static folder on the VM. Preserve both certificate volumes; never run `down -v` or a global Docker prune. Old images can be removed deliberately when no longer needed; retention is not automated yet.

HTML/assets, Dockerfile and Caddyfile changes travel through the image. Changes to the installed updater or production Compose require an administrator to pull reviewed source and rerun `sudo bash server/install.sh`. Those server scripts are not silently executed from GitHub every release. The manual static-copy script is retired.

## Replacement server setup

The installer targets an existing `/opt/xsolutions` deployment with Docker/Compose and the named Caddy volumes. Recreate that baseline first when recovering a lost VM, restore routing/access, clone this repository and run `sudo bash server/install.sh`. The updater then fetches the latest tested release. Set Actions variable `ORACLE_HOST` to the replacement public IP for TLS-verified origin checks.

The GHCR package must be public for anonymous downloads, matching the public source. No Actions secret is required. The `production` environment is limited to main. Main requires the container check and a pull request; repository administrators can change those settings.

References: [GitHub container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry), [Docker multi-platform builds in Actions](https://docs.docker.com/build/ci/github-actions/multi-platform/).
