# Workflow validation

## Manual Dylan dev gateway route — September 10, 2026

- Added only `dev-demo.xsolutionsmd.com` to the shared gateway for the separately authorized dev environment: public root to `dylan-dev-web:8080`, owner portal/API/OAuth to `dylan-dev-admin:8082`, and exact `/admin/version.json` rewrite for the booking release receipt.
- The Dylan repository's `scripts/test-dev-proxy.py` extracted this route block and passed actual isolated HTTPS routing, trusted temporary certificate, public/admin assets, redirects, version metadata, authentication, CSRF, OAuth callback URL and public-listener isolation checks. No live credentials or existing app volumes entered the test.
- Backed up the installed gateway file, validated the additive configuration inside the existing gateway, and reloaded it gracefully. Public HTTPS certificate validation succeeded for the new hostname before its first image was ready (expected 502 at that stage).
- Immediately after reload, company revision remained `cd90c70e31519a461fa05188e0f6373fed298ae3`, demo revision remained `ad5313a07d05f61e829ba6e288a09d433c35505d`, and all three existing container IDs were preserved: company `02454210ea73`, demo `d4a28c919b7b`, gateway `bf60d8c05cc3`.
- This is a separately installed gateway change committed on dev. No company main merge or company image release was performed. Live dev application release evidence belongs to the Dylan repository's booking validation record.

## First release — September 9, 2026

- PR #1 merged dev into main at `b4ce895a91631a72a2964a18fc8f64c64d94474f`.
- [Workflow 34320018208](https://github.com/Derek-Sykes/xsolutions-website/actions/runs/34320018208) passed container checks, AMD64/ARM64 publication, release instruction publication and live Oracle verification.
- Oracle independently reported a healthy container and matching revision. The update happened through the timer without a manual deployment command.
- Public package visibility was verified in GitHub. No Oracle GitHub credential or extra inbound port was needed.
- Local Windows PowerShell start and Git Bash update passed. Both refused uncommitted source. The container check verified all four original public assets, revision identity, Caddy configuration and exclusion of Git files.

## Second release and dev isolation

- Dev `8dfb14b7e2752d5a2be9ed6e261766a1ef29092c` added a non-visible HTML comment. Its checks passed, while deployment was skipped.
- A separately cloned copy advanced from `9f42202` to `8dfb14b` using `website.ps1 update`, built and started on a separate local port/project, and served the exact new revision and marker. This simulates another computer's clone on this desktop; the physical laptop was not accessed.
- During dev-only testing and an automatic server timer pass, Oracle retained first-release revision `b4ce895` without the marker.
- PR #2 then merged dev into main at `e67295d1fa4fcaee3ff29dae6b06aa614eb674df`.
- [Workflow 34320283836](https://github.com/Derek-Sykes/xsolutions-website/actions/runs/34320283836) succeeded. Oracle automatically served the new revision and marker; both original named Caddy certificate volumes remained attached.

## Final placeholder cleanup release

- PR #3 merged at `14b6f10f8cfb0effc26c30a4eedf61a58cb646b2`; [workflow 34320527079](https://github.com/Derek-Sykes/xsolutions-website/actions/runs/34320527079) succeeded and restored the placeholder without the temporary marker.
- The separate clone also advanced to `94d8500` through the Bash updater and served the restored page. Its temporary container/network were removed afterward.
- This test revealed that discovery through GitHub's latest-release URL can lag publication. The installed updater now checks main directly and requests its exact release URL with cache avoidance. A not-yet-published release keeps the existing website running and is retried on the next timer check. A fourth release verifies this refinement.
- The replacement landing page was excluded from these infrastructure tests. Derek subsequently authorized publishing the finished page after workflow tests and builder QA; that is a separate reviewed release.

Main is protected with a required pull request and `Check website container`, including administrators. Production accepts main only. Repository auto-merge is off. The updater's failure rollback exists but has not been fault-injected against the production server.

## Fourth release: exact-revision discovery

- PR #4 merged at `6f4fbc5264701c91f044ed420ef8a103a1854b69`; [workflow 34320877029](https://github.com/Derek-Sykes/xsolutions-website/actions/runs/34320877029) succeeded.
- The refined timer first observed that main was still building and retained the healthy previous version, then automatically deployed the exact published revision. No manual deployment command was used.
- Oracle is healthy on image digest `sha256:f3ec686fd9b97e9b1b0ce23f0402567e9eddb4749f335f4413079ef82c67bdb7`. The timer is enabled and active.
- Both Caddy volumes retain creation time `2026-09-09T05:47:31Z`, before the first automated release. HTTPS apex returns the page; www returns 301 to the apex; HTTP returns 308 to HTTPS. The actual domain also loaded normally in Chrome.
- Four main release workflows passed. Three were placeholder promotion/content tests; the fourth verified refined discovery. Dev-only pushes skipped production deployment. The visible placeholder design is unchanged and the test comment is gone.

## Finished landing-page release

- The user separately authorized publication after page QA. Tested dev revision `6e6210762c2b472e734caff2466c754a91fb6329` passed container checks, byte equality for all seven public files, JavaScript syntax, mobile navigation and FAQ interaction. Layouts from 320 to 1440 pixels had no horizontal overflow in the builder's browser review.
- [PR #5](https://github.com/Derek-Sykes/xsolutions-website/pull/5) passed its required check and merged normally into main at `4a25f98d4e28717b4cc6f2ae734a20410bfc7083`.
- [Workflow 34322381764](https://github.com/Derek-Sykes/xsolutions-website/actions/runs/34322381764) was triggered by that merge and succeeded. Oracle's timer automatically deployed and verified the release at 07:09:46 UTC on September 9. No manual workflow dispatch or server copy was used.
- Live image: `ghcr.io/derek-sykes/xsolutions-website@sha256:1c169374d109ba878adfca9552c2c473e131d0f80da910d94a07d967555a1ab1`. The container is healthy and the updater timer is enabled/active.
- Independent HTTPS checks confirmed the exact main revision and byte equality for all seven public files, including CSS, JavaScript and the generated WebP. All internal fragment destinations exist. www redirects to the apex and HTTP redirects to HTTPS.
- The live page loaded normally in Chrome with its image. Contact-section navigation, the mobile menu opening/closing after navigation, and FAQ expansion passed. At 390 pixels there was no horizontal overflow; the browser error log was empty.
- Email and phone destinations are `xsolutionsmd@gmail.com` and `+14437975882`. Their links were verified without sending an email or placing a call. There is no inquiry form or backend; inbox delivery and call answering were not tested.

Five automatic main releases succeeded, including the actual finished page. Workflow setup and initial page publication are complete. Future main merges still require separate release authorization.

## Business phone update — September 9, 2026

- The user explicitly authorized this small fix to progress through dev verification and main merge without another approval. Displayed phone is now `667-383-5993`; the tap-to-call destination is `tel:+16673835993`, superseding the earlier release's number.
- Tested dev revision `ee30d9d62a2253421c08878917321f312e87462b` passed local `website.ps1 check` (container configuration, served HTML and core assets, revision identity and Git-source exclusion). A separate assertion confirmed the new phone text and link and absence of the old number in the page. No call was placed.
- Dev push [workflow 34369884555](https://github.com/Derek-Sykes/xsolutions-website/actions/runs/34369884555) and [PR #6](https://github.com/Derek-Sykes/xsolutions-website/pull/6) checks passed before the normal protected merge to main `faf997523c1f84b25d79a55ee4d8c1bcd9e74dfe`.
- Main [workflow 34369948834](https://github.com/Derek-Sykes/xsolutions-website/actions/runs/34369948834) succeeded, including automatic Oracle deployment and live verification. Independent HTTPS requests confirmed the exact revision, complete HTML equality with the tested page, and the new displayed number and tap-to-call link.
- This was a phone-text/link substitution with no layout or behavior changes; no new browser layout review was performed. Call answering and external advertising accounts were not tested or changed.

## Shared gateway backend preparation — September 10, 2026

- Derek authorized a shared reverse proxy on Oracle, keeping the company domain on this website and hosting separately deployed demo containers on subdomains. This task includes the coordinated server migration and tested main release; it does not establish standing authorization for later releases.
- Implementation revision `b3d5d8c079e9174aa7ccec5dd086a42b7f535582` passed `website.ps1 check` on Docker Desktop AMD64. The image was built with that exact revision. Both Caddy configurations validated, every source public file matched its served bytes, `/version.json` matched the revision with `Cache-Control: no-store`, the internal `:8081` health endpoint responded, and Git source stayed excluded.
- An isolated Docker network and temporary Caddy proxy routed `Host: xsolutions.test` to the production backend through alias `xsolutions-site:80`. The HTML matched and security/version cache headers survived the proxy. A separate local-preview container also returned the matching page with development no-cache headers. All temporary test containers and the test network were removed.
- The rendered production Compose retained project `xsolutions` and service `web`, had no public port bindings or certificate mounts, and referenced external network `xsolutions-proxy` with unique alias `xsolutions-site`. Shell syntax and whitespace checks passed. Website content and launcher commands did not change.
- The updater now preflights the shared network and tests the production HTTP configuration. Its existing HTTPS live comparison and previous-Compose/image rollback remain in place. The installer preserves the original deployment backup and supports `--paused` for the coordinated gateway migration. Production rollback has not been fault-injected by these local checks.
- These are local preparation results only. Gateway installation, certificate preservation, ARM64 publication and live migration require their own verified release record below.

### Recovery and disposable backend storage refinement

- Implementation `ec448cc682e755984fa8cfd261dbabb06711304f` adds transaction-wide failure/TERM recovery, atomic release-state publication, retained recovery files if rollback fails, and a two-minute systemd stop allowance. The independently managed gateway is unchanged by this commit.
- `python3 scripts/test-updater.py` passed eight isolated Linux cases using the actual Bash updater with temporary deployment paths and simulated Docker/network commands: successful release, failed Compose start, HTTPS revision mismatch, configuration-write failure, state-write failure, TERM during deployment, TERM immediately after state rename, and failed rollback. Failed releases restored the previous configuration/state; failed rollback retained the recovery directory. This is fault injection in a local harness, not on Oracle.
- Production, preview, candidate and validation containers now use tmpfs at `/data` and `/config`. The container/proxy suite passed again for this working tree before commit (image revision label `b4552316dd86c567e89fab28826fd123e0cde0e5`); inspection confirmed the tested backend had no Docker volume mounts. Rendered production Compose confirmed both tmpfs mounts without public ports or persistent backend volumes. The CI container-check job now also runs the recovery harness.

### Shared gateway live release

- [PR #7](https://github.com/Derek-Sykes/xsolutions-website/pull/7) passed actual dev push and pull-request checks, then merged normally at `aa87b505472028fafe5b6162eb2a60adcfd2e2fb`. The resulting main-push [workflow 34449439306](https://github.com/Derek-Sykes/xsolutions-website/actions/runs/34449439306) succeeded, including ARM64 publication, automatic Oracle deployment and exact live HTTPS verification.
- The shared gateway now owns public TCP 80/443, routes the apex to `xsolutions-site:80`, redirects www to the apex, and routes `demo.xsolutionsmd.com` to the independent demo container. Both website containers publish no host ports and have no persistent certificate volumes. The gateway retains `xsolutions_caddy_data` and `xsolutions_caddy_config`, including their original September 9 creation timestamps.
- An independent live audit matched all seven company public files to the published main revision. The separate demo remained healthy on its own release while this company container was replaced. Both update timers were enabled and active; both installed updaters included release-state restoration and retained recovery files on failed rollback.
- Wildcard DNS covers future subdomains, while the current Caddy configuration serves only the explicitly configured sites. The gateway container stayed running during the company image update. Gateway routing changes and updater/Compose installation remain reviewed administrator operations; normal image releases update only their own website service.
- The company and demo loaded in Chrome with their images and no desktop horizontal overflow. The demo's project controls responded and retained noindex headers; private source paths returned 404. Website presentation was unchanged, so prior mobile design QA remains applicable; this release did not repeat a mobile layout review or send contact messages.
- Migration recovery copies were retained. The existing daily backup was extended to all three deployment directories and an archive was verified. These are configuration backups on the same VM, excluding certificate volumes; independent disk-loss recovery and production failure injection were not tested. See [gateway operations](../server/gateway/README.md).
