# Workflow validation

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

The temporary comment is removed in this revision. A third dev-to-main release will verify restoration of the original page content. The separate landing-page redesign is excluded from these releases and must remain dev-only until the owner authorizes publication.

Main is protected with a required pull request and `Check website container`, including administrators. Production accepts main only. Repository auto-merge is off. The updater's failure rollback exists but has not been fault-injected against the production server.
