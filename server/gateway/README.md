# Shared Oracle gateway

Caddy owns the server's public TCP ports 80 and 443 and manages HTTPS. Website containers join the external Docker network `xsolutions-proxy` with unique aliases and have no published host ports.

| Hostname | Internal destination |
|---|---|
| `xsolutionsmd.com` | `xsolutions-site:80` |
| `www.xsolutionsmd.com` | Redirect to the company domain |
| `demo.xsolutionsmd.com` | `dylan-demo:8080` |

The installed gateway lives at `/opt/xsolutions-gateway`. Its configuration is a separate administrator-managed deployment. Ordinary company or demo image releases never install or overwrite these files. The website updaters have independent release state and rollback paths.

## Change a route or add a website

1. Deploy the application's image with a working HTTP server, a unique network alias, and a connection to `xsolutions-proxy`. Keep its application ports unpublished. Build for Oracle's ARM64 architecture.
2. The wildcard A record `*.xsolutionsmd.com` points to Oracle, covering new demo subdomains without another DNS edit. Existing explicit records take precedence. Other domains still need their own DNS setup. Switching an existing hostname's container does not require a DNS change.
3. Edit `config/Caddyfile` here, review the change, and copy the configuration into the installed gateway's `config/Caddyfile`. Keep a backup of the previous file. Validate and reload as shown below, then test the affected hostname over HTTPS. Restore the backup and reload if validation or behavior fails.

For example, a future `demo1.xsolutionsmd.com` route could use `reverse_proxy another-demo:8080`. That example is not currently configured. Do not point a route at a container until the container is ready.

```bash
cd /opt/xsolutions-gateway
sudo docker compose exec -T caddy caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
sudo docker compose exec -T caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
sudo docker compose ps
```

Reloading applies routing changes without replacing the gateway container. The bind mount covers the configuration directory so file replacement is visible inside the container. The admin API and health endpoint are not published on the VM.

## Initial migration and recovery

This Compose file replaces the old company container as the public HTTPS listener. Before first installation, pause the company update timer, save its current Compose/image/updater state, and prepare the new internal company container. Create `xsolutions-proxy`, install this directory under `/opt/xsolutions-gateway`, and reuse the existing `xsolutions_caddy_data` and `xsolutions_caddy_config` volumes. Stop the old public listener before starting the new gateway. Never delete those volumes or run `down -v`.

Install the reviewed company updater and internal Compose template together. The old updater template would reclaim public ports on a later release. Verify company HTML and revision through the gateway before resuming its timer. Preserve any pre-migration recovery copies separately; normal website rollback must use the internal Compose definition.

The demo has its own installer and update timer in its repository. Restore DNS, the shared network, gateway configuration, certificates, and each application's current release configuration when replacing a lost VM. Restart policies recover containers after a Docker/VM restart. `backup.sh`, installed as `/usr/local/sbin/xsolutions-backup`, extends the existing daily configuration backup to all three deployment directories. These archives stay on the VM and do not include the certificate volumes or protect against disk loss.

References: [Caddy reverse proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy), [Docker Compose networking](https://docs.docker.com/compose/how-tos/networking/).
