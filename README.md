# Dora

Dora is a travel creation and export platform built as a monorepo:

- `backend/`: FastAPI + PostgreSQL/PostGIS + Supabase integration.
- `flutter/`: primary mobile client (offline-first).
- `video-renderer/`: Remotion renderer service used by backend export jobs.
- `infra/remotion/`: IAM/lifecycle policy templates for Lambda-scale rendering.
- `frontend/`: legacy/parallel web client.

## Current Snapshot (2026-03-16)

- Phase 6 export system is implemented end-to-end (control plane, worker, renderer adapters, Flutter export UX, export history hub).
- Cloud-scale Lambda path is documented as completed in the Phase 6 handoff docs, with 6D/6E quality and UX work continuing in newer Flutter handoffs.
- Release-readiness docs were refreshed on 2026-03-12 for mobile production rollout.
- Recent commits on 2026-03-16 add backend storage/runtime hardening and additional Flutter editor/map UX fixes.

## Recovered Project Timeline (from last 11 revisions of `.claude/PROJECT_STATUS.md`)

The current `.claude/PROJECT_STATUS.md` is focused on Phase 6. Earlier revisions contained important historical context:

- 2026-01-21: project/session plan initialized (0% baseline).
- 2026-01-23: foundation completed (Supabase + FastAPI bootstrap, Phase 0 closed).
- 2026-01-25: core backend CRUD progression (users, trips, places, spatial queries) through Session 10.
- 2026-02-04: consolidated milestone state: core backend phases complete, V2 metadata/routes/components shipped, web V2 phases B-D closed, semantic tagging planned.
- 2026-02-19 to 2026-02-20: Flutter Phase 4A/4B/4C rebuild and stabilization.
- 2026-02-28: Phase 6A (export control plane) marked complete, 6B kickoff.
- 2026-03-01: Phase 6B marked complete, 6C cloud-scale started.

This recovered timeline is now reflected in this README and the backend/flutter READMEs so onboarding does not depend only on the latest, narrower status file.

## Documentation Precedence (stale-conflict policy)

When docs conflict, use this order:

1. Code and tests in the working tree (`backend/app/**`, `flutter/lib/**`, `backend/tests/**`, `flutter/test/**`).
2. Newer Phase 6/ops docs (mostly March 2026):
   - `flutter/docs/phases/Phase-6-PRD.md`
   - `flutter/docs/phases/Phase-6-Execution-Checklist.md`
   - `flutter/docs/handoffs/phase6*.md`
   - `flutter/docs/ops/*.md`
3. Older architecture docs as historical reference only:
   - `docs/architecture.md`
   - `Detailed_Architecture.md`
   - `backend/ARCHITECTURE.md`
   - `flutter/docs/architecture.md`

Note: `.claude/CURRENT_PHASE.md` and `.claude/PROJECT_STATUS.md` were last updated on 2026-03-02 and do not include all newer 6E/editor updates.

## Repository Layout

```text
Dora/
  backend/          FastAPI API, services, SQLAlchemy models, Alembic, tests
  flutter/          Flutter app (Riverpod + Drift + Supabase + Mapbox)
  video-renderer/   Node/Express Remotion renderer (local + lambda modes)
  infra/remotion/   IAM + S3 lifecycle templates for renderer cloud path
  docs/             legacy and phase docs (some stale, see precedence rules)
  frontend/         React web client (legacy/parallel surface)
```

## Quick Start (full local stack)

### Prerequisites

- Python 3.11+
- Node.js 20+
- Flutter 3.27.x (CI uses 3.27.4)
- PostgreSQL 15+ (or Docker)
- Supabase project keys (auth + storage)
- Mapbox token

### 1) Prepare env files

```powershell
copy backend\.env.example backend\.env
copy flutter\.env.example flutter\.env
copy video-renderer\.env.example video-renderer\.env
```

Fill real values (Supabase, Mapbox, API base URL, AWS keys for lambda mode if needed).

### 2) Start backend + worker + renderer

Option A (recommended for local integration):

```bash
docker compose -f docker-compose.dev.yml up --build
```

Option B (manual terminals):

```bash
# terminal 1
cd backend
pip install -r requirements.txt
alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

```bash
# terminal 2
cd backend
python -m app.workers.export_worker
```

```bash
# terminal 3
cd video-renderer
npm install
npm run dev
```

### 3) Run Flutter app

```bash
cd flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define-from-file=.env
```

## CI/CD Workflows

- Backend CI: `.github/workflows/backend-ci.yml`
- Flutter CI: `.github/workflows/flutter-ci.yml`
- Flutter release builds: `.github/workflows/flutter-build.yml`
- Railway deploy (api + worker + renderer): `.github/workflows/deploy-railway.yml`

## Primary References

- Backend deep guide: `backend/README.md`
- Flutter deep guide: `flutter/README.md`
- Export renderer API contract: `video-renderer/docs/renderer-api-contract.md`
- Export infra notes: `infra/remotion/README.md`
- Security backlog (deferred): `docs/security-deferred.md`
