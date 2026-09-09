# Workflow validation

## First release — September 9, 2026

- PR #1 merged dev into main at `b4ce895a91631a72a2964a18fc8f64c64d94474f`.
- [Workflow 34320018208](https://github.com/Derek-Sykes/xsolutions-website/actions/runs/34320018208) passed container checks, AMD64/ARM64 publication, release instruction publication and live Oracle verification.
- Oracle independently reported a healthy container and matching revision. The update happened through the timer without a manual deployment command.
- Public package visibility was verified in GitHub. No Oracle GitHub credential or extra inbound port was needed.
- Local Windows PowerShell start and Git Bash update passed. Both refused uncommitted source. The container check verified all four original public assets, revision identity, Caddy configuration and exclusion of Git files.

Repeat-release and separate-clone update tests are in progress. A temporary HTML comment is used to verify content promotion without changing the visible page.
