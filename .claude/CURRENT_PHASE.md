# Current Phase: Phase 6B - Remotion MVP Renderer Kickoff

Phase: Flutter-Phase-6B | Status: Kickoff started, 6A delivered

## Active Branch
- `phase-6-video-export`

## 6A Delivered (Control Plane + Flutter Wiring)
- Backend export control plane and worker:
  - `export_jobs` migration/model/schema/service/router/worker
  - endpoint and worker test suites for submit/status/cancel/recovery/retry/race paths
- Flutter export scaffolding:
  - export feature module (`features/export/**`)
  - export routing and feature-flag route guard
  - submit-time precheck revalidation and hardened error parsing
  - route delete dependency fix for sync-blocking detection
- Contracts and orchestration docs:
  - `phase6-contract-freeze.md`
  - renderer contract (`video-renderer/docs/renderer-api-contract.md`)
  - local runtime orchestration (`docker-compose.dev.yml`, `Procfile.dev`)

## Validation Snapshot (2026-02-28)
- Backend Phase 6A tests (dependency-ready local env): `17/17` passed.
- Flutter Phase 6A export tests: passed in local env after latest guard/error-string alignment.
- Current sandbox limitation: backend test rerun is blocked here by missing `sqlalchemy` dependency.

## Immediate 6B Procedure
1. Verify 6B precondition gate from checklist (contract freeze + 6A evidence + no pending schema drift).
2. Implement local `video-renderer/` Express + Remotion service against frozen HTTP contract.
3. Integrate `LocalRemotionRenderer` in backend worker with stage-level progress/cancel flow.
4. Upgrade Flutter Export Studio from 6A single-template submit to 6B template + progress/share UX.
5. Capture 6B evidence report with artifact playability and full stage logs.
