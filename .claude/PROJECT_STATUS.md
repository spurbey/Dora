# Project Status - Dora

Last Updated: 2026-03-01  
Current Focus: Phase 6C video export cloud scale  
Overall Progress: Phase 6A complete, Phase 6B complete, Phase 6C in progress (6C-1 complete in local diff, 6C-2 started)

---

## Current Workstream

### Phase 6A - Control Plane and Product Wiring
Status: Completed

Delivered:
- Backend export model/schema/service/router/worker and migration
- Export endpoints: create/status/cancel/download/share
- Durable worker claim loop with retries, stale recovery, and cancel/race handling
- Flutter export scaffolding, pre-submit guards, and routing
- Contract freeze and renderer API contract docs

Validation:
- Backend export tests passed in dependency-ready local env (`17/17`).

### Phase 6B - Remotion MVP Renderer
Status: Completed

Delivered:
- Local renderer service with frozen HTTP contract
- Real Remotion `Classic` composition pipeline
- Backend `LocalRemotionRenderer` integration
- Stage-complete worker flow (`snapshotting` -> `finalizing`)
- Full Flutter export UX for all export states
- 6B evidence report

### Phase 6C - AWS Lambda Scale
Status: In progress (6C-1 complete in local diff, 6C-2 started)

Frozen 6C contract is documented in:
- `flutter/docs/phases/Phase-6-PRD.md`
- `flutter/docs/phases/Phase-6-Execution-Checklist.md`
- `flutter/docs/handoffs/phase6-contract-freeze.md` (6C addendum)
- `flutter/docs/handoffs/phase6c-kickoff-procedure.md`

Planned execution order:
1. Renderer Lambda path (`video-renderer`) and deploy scripts (local diff complete)
2. Backend cloud integration and guardrails (in progress)
3. IAM/lifecycle/evidence closure (`phase6c-cloud-scale-report.md`)

---

## Open Gates and Risks

- Lambda runtime path is implemented in local diff but still requires AWS-side provisioning and integration validation.
- Presigned S3 download path is implemented in local diff but still needs dependency-ready endpoint test verification.
- `video-renderer/package-lock.json` refresh is pending because npm registry access is blocked in this sandbox (`ENOTCACHED`).
- 6D-scoped features remain deferred:
  - share-token revocation hardening
  - `pinned_at` retention wiring
  - generated export thumbnail artifact

---

## Recent Commits (latest first)

- `4e6d687` chore(renderer): update README and add lockfile
- `d041ca6` docs(phase6): sync 6B docs with latest 6B-3 commits
- `25a8e05` docs(phase6b): write evidence report and close 6B gate
- `a345901` fix(export): apply 5 post-review fixes to 6B-3 Flutter UX
- `f30274d` feat(6b-3): Flutter export UX - TemplatePicker, polling, status matrix, SharePreviewScreen
