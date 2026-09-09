# Website workflow

Read README.md and docs/VALIDATION.md before changes. The public website lives in xsolutions-site/. Use dev for development; main is the explicit release gate and deploys to Oracle automatically. Never merge dev into main without release authorization. Initial workflow release tests were completed on September 9, 2026; their authorization is not standing permission for future releases.

Keep credentials, machine-specific SSH paths, business research and private files out of this public repository and image. Use the explicit Docker context allowlist. Preserve existing Caddy certificate volumes and unrelated Docker resources. Production uses ARM64; release images support ARM64 and AMD64.

Run container checks for website/container changes. Server deployment changes require an integration check. Record actual tested revisions. Shell launchers and website.ps1 should offer equivalent local behavior.
