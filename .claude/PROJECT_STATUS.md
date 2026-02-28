# Project Status - Dora

Last Updated: 2026-02-28
Current Focus: Phase 6 video export platform - 6A complete, 6B kickoff
Overall Progress: Flutter P1-P5 complete, Phase 6A delivered

---

## Current Workstream

### Phase 6A - Control Plane and Product Wiring
Status: Completed implementation and local validation

Delivered:
- Backend export stack
  - export model/schema/service/router/worker and DB migration
  - endpoints: create/status/cancel/download/share
  - durable claim loop with `skip_locked`, cancel semantics, stale recovery, retry/backoff
- Flutter export stack
  - export feature module, provider, repository, studio screen
  - route-level feature flag guard and export action wiring from trips/editor
  - submit-time guard revalidation and nested 409/422 backend error parsing
  - route delete dependency tracking for accurate export precheck blocking
- Contracts/docs
  - `flutter/docs/handoffs/phase6-contract-freeze.md`
  - `video-renderer/docs/renderer-api-contract.md`
  - `docker-compose.dev.yml` and `Procfile.dev`

Validation notes:
- Backend export tests (user local env): 17/17 pass (8 endpoint + 9 worker).
- Flutter export tests: user-confirmed pass after latest message/alignment fixes.
- In this sandbox, backend pytest rerun is blocked by missing dependency (`sqlalchemy`).

### Phase 6B - Remotion MVP Renderer (Current)
Status: Kickoff in progress

Planned execution order:
1. Close 6A evidence pack and status docs.
2. Scaffold `video-renderer/` runtime from frozen HTTP contract.
3. Implement backend `LocalRemotionRenderer` integration and stage-complete worker flow.
4. Expand Flutter export UX to 6B states (template/polling/progress/completion/share).
5. Produce `phase6b-remotion-mvp-report.md` evidence bundle.

---

## Open Gates and Risks

- `dora_api` export endpoints are still not generated; current Flutter export transport is temporary `ExportApi` adapter.
- `video-renderer/` service is contract-defined but not implemented yet.
- Local backend test reruns in this workspace need Python deps installed before reproducible execution.

---

## Recent Commits (latest first)

- `a8ee884` fix(flutter): harden phase 6A export guards and routing gates
- `19b11ad` feat(flutter): scaffold phase 6A export studio and guard checks
- `eff1807` fix(phase6a-worker): persist output_url and harden stale tests with mocked time
- `1698b8d` fix(phase6a-worker): preserve late-cancel completion and clear stale renderer ids
- `06ea1bd` fix(phase6a): harden export worker recovery, race handling, and status contract
- `70326a0` feat(phase6a): scaffold export control plane, worker, and contracts
