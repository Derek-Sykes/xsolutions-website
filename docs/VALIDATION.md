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
