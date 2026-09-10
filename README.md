# X Solutions website

The website at **https://xsolutionsmd.com**, served by a versioned website container on Oracle. The deployment configuration uses a separate, shared Caddy gateway for HTTPS and domain routing. Work on `dev`; merge `dev` into `main` when you want to publish. See [validation](docs/VALIDATION.md) for what has actually been deployed and tested.

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

The updater accepts only this repository's image digest and current main revision, verifies ARM64/source labels, tests the production HTTP configuration in a temporary candidate, then updates the existing `xsolutions` stack. The image contains the website and its internal static-file server. A failed or interrupted deployment restores the previous website configuration and release state, including when checks through the public HTTPS gateway fail. If recovery itself fails, the journal identifies the retained recovery directory. Replacement may cause a brief interruption for this website.

The independent `xsolutions-gateway` stack in `/opt/xsolutions-gateway` owns public ports 80 and 443 and the existing `xsolutions_caddy_data` / `xsolutions_caddy_config` volumes. It forwards `xsolutionsmd.com` requests to `xsolutions-site:80` on the external `xsolutions-proxy` Docker network. The company website keeps Compose project `xsolutions`, service `web`, and the unique network alias `xsolutions-site`. It publishes no host ports and mounts no certificate volumes. The gateway handles www-to-apex and HTTP-to-HTTPS redirects.

Other website containers can join that network with their own unique aliases and gateway domain rules. Updating the company website never updates the shared gateway or another website. Gateway configuration is installed and reloaded separately; see [gateway operations](server/gateway/README.md).

The backend, local preview and temporary checks use in-memory `/data` and `/config` mounts for Caddy's disposable internal state. Replacing them therefore does not accumulate anonymous Caddy volumes. The shared gateway alone retains the durable certificate volumes.

`/version.json` identifies the running source commit and contains no secret. Release tags are `release-<full main commit>` with a `deployment.json` asset. Images are tagged `sha-<full main commit>` and deployed by digest. Superseded main workflows skip release publication/deployment.

## Files

- `xsolutions-site/`: edit the public website here.
- `Dockerfile`, `Caddyfile`: production image and internal HTTP static-file serving.
- `Caddyfile.local`, `compose.local.yaml`: local preview on port 8787.
- `compose.yaml`: Oracle website stack using `XSOLUTIONS_IMAGE` and the external proxy network.
- `.github/workflows/website.yml`: tests, publication and live verification.
- `server/`: installed Oracle website updater, installer and timer.
- `server/gateway/`: separately managed shared HTTPS gateway and migration instructions.
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

Current site content is in versioned GitHub source and images, not the legacy static folder on the VM. Preserve `/opt/xsolutions`, the shared gateway directory, and both existing certificate volumes in server backups; verify backup coverage as part of the initial migration. Never run `down -v` or a global Docker prune. Old images can be removed deliberately when no longer needed; retention is not automated yet.

HTML/assets, Dockerfile and the internal Caddyfile changes travel through the image. Changes to the installed updater or production Compose require an administrator to pull reviewed source and rerun `sudo bash server/install.sh`. Those server scripts and `server/gateway/` are not silently executed from GitHub every release. The manual static-copy script is retired.

### Initial shared-gateway migration

An existing single-container deployment must be migrated before it can run these backend-only images. Pause the website updater, back up the installed Compose/release settings and certificate volumes, install the shared gateway and `xsolutions-proxy` network, then install this updater with `sudo bash server/install.sh --paused`. This option leaves the timer disabled until the coordinated gateway/website replacement and HTTPS checks have passed. Follow the [gateway migration instructions](server/gateway/README.md) for the actual cutover and recovery sequence. Do not start a gateway on public ports while the old website container still owns them.

The installer retains the first `original-compose.yaml` backup and requires an existing `/opt/xsolutions/compose.yaml` and `xsolutions-proxy` network. After migration verification, run `sudo systemctl enable --now xsolutions-update.timer`. Later website releases use the usual main workflow. Reverting all the way to an image from before this migration also requires its matching legacy deployment configuration; ordinary content rollback should use a new release that retains the backend architecture.

## Replacement server setup

Restore Docker/Compose, the shared gateway configuration, certificate volumes, and `xsolutions-proxy` network first when recovering a lost VM. Restore `/opt/xsolutions/compose.yaml` and `release.env`, clone this repository and run `sudo bash server/install.sh --paused`. Start the website and gateway using their restored configuration, verify HTTPS, then enable the updater timer to fetch the latest tested release. Set Actions variable `ORACLE_HOST` to the replacement public IP for TLS-verified origin checks.

The GHCR package must be public for anonymous downloads, matching the public source. No Actions secret is required. The `production` environment is limited to main. Main requires the container check and a pull request; repository administrators can change those settings.

References: [GitHub container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry), [Docker multi-platform builds in Actions](https://docs.docker.com/build/ci/github-actions/multi-platform/).
