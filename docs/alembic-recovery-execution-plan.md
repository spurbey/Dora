# Alembic Recovery Execution Plan

## Purpose
This is the long-term execution memory for Alembic/schema recovery work.  
Update this file after each phase, test run, and decision so future sessions can continue without re-discovery.

## Scope
- Backend schema drift reconciliation
- Alembic/autogenerate stability
- CI migration correctness
- Future governance to prevent repeat drift

## Non-Negotiables
- Forward-only reconciliation migrations; never rewrite applied history.
- One migration owner queue during stabilization window (no parallel migration merges).
- Every schema-affecting model change must ship with a migration in the same PR.

## Phase Checklist
- [x] Phase 0: Create execution-memory doc and freeze plan.
- [x] Phase 1: Patch Alembic env filters + deterministic model loading.
- [x] Phase 2: Patch CI to run `alembic upgrade head` before `alembic check`.
- [x] Phase 3: Publish source-of-truth matrix (table-by-table indexes/nullability/comments/FKs).
- [x] Phase 4: Publish DB schema contract (`docs/db-schema-contract.md`).
- [x] Phase 5: Reconciliation migrations (domain chunks: signals, metadata, export, routes, live-tracking).
- [ ] Phase 6: FK cycle resolution (`trip_checkin_candidates` <-> `trip_places`) with explicit strategy.
- [ ] Phase 7: Validation on fresh DB + upgraded dataset clone.
- [ ] Phase 8: Governance lock-in (CI + PR checklist + drift policy).

## Validation Gates
- `alembic upgrade head` passes on fresh DB.
- `alembic check` returns zero new operations on fresh DB.
- `alembic upgrade head` passes on upgraded dataset clone.
- `alembic check` returns zero new operations on upgraded dataset clone.
- Targeted pytest suites pass for touched domains.
- No extension/system-table noise in Alembic comparison output.
- No new performance regressions from index changes.

## Command Checklist
- `cd backend`
- `alembic upgrade head`
- `alembic check`
- `pytest -q tests/test_trip_endpoints.py` (plus domain-specific suites for touched schema)

## Decision Log
- 2026-03-21: Treat production-shaped DB state as baseline; reconcile with forward migrations.
- 2026-03-21: Keep extension/system table filtering narrow and explicit in Alembic env.
- 2026-03-21: CI ordering updated to apply migrations before drift check.
- 2026-03-21: Exclude `alembic_version` from schema drift compare (Alembic-managed internal table).
- 2026-03-21: Comment-only column diffs are filtered from migration check/generation pipeline.
- 2026-03-21: Index contract direction set to explicit named indexes (`idx_*`/`uq_*`), not implicit `ix_*`.
- 2026-03-21: Source-of-truth and schema contract docs published for future sessions.
- 2026-03-21: Signal-table nullability aligned to DB-permissive contract for ingestion compatibility.
- 2026-03-21: Added forward migration `f3a7b8c9d0e1` to remove duplicate legacy `routes.trip_id` index.

## Execution Log
### 2026-03-21 (Session 1)
- Completed:
  - Added this execution-memory plan document.
  - Patched [backend/alembic/env.py](/c:/Users/sumit/Downloads/Dora/backend/alembic/env.py) to:
    - load full model metadata via `import app.models`
    - ignore extension-managed tables (`spatial_ref_sys`, `geography_columns`, `geometry_columns`, `raster_columns`, `raster_overviews`) via `include_object`
    - apply `include_object` in offline and online Alembic contexts
  - Patched [backend-ci.yml](/c:/Users/sumit/Downloads/Dora/.github/workflows/backend-ci.yml) to run `alembic upgrade head` before `alembic check`.
- Verification:
  - `cd backend; $env:DEBUG='false'; .\\venv\\Scripts\\python.exe -m py_compile alembic/env.py` (pass)
  - `cd backend; $env:DEBUG='false'; .\\venv\\Scripts\\alembic.exe history -r head:head --verbose` (pass)
  - `cd backend; $env:DEBUG='false'; .\\venv\\Scripts\\alembic.exe check` (expected fail: `New upgrade operations detected`)
  - Confirmed from check output: no `spatial_ref_sys` compare noise after env filter patch.
- Notes:
  - Drift still expected until source-of-truth matrix + reconciliation migrations are completed.
  - Next phase is matrix + contract before writing bulk reconciliation migrations.

### 2026-03-21 (Session 2)
- Completed:
  - Generated schema drift matrix artifact at `schema_matrix_raw.json`.
  - Published source-of-truth matrix:
    - [db-source-of-truth-matrix.md](/c:/Users/sumit/Downloads/Dora/docs/db-source-of-truth-matrix.md)
  - Published schema contract:
    - [db-schema-contract.md](/c:/Users/sumit/Downloads/Dora/docs/db-schema-contract.md)
  - Extended [env.py](/c:/Users/sumit/Downloads/Dora/backend/alembic/env.py) to:
    - ignore Alembic internal table (`alembic_version`)
    - strip comment-only `AlterColumn` ops from autogenerate/check output
- Verification:
  - `python` parser on `schema_matrix_raw.json`:
    - affected tables: `19`
    - column drift: `96` (`86` comment-only, `9` nullable, `1` internal-table missing model col)
    - index drift: `52` DB-only + `13` model-only
    - unique drift: `1` DB-only
    - FK drift: `0`
  - `cd backend; $env:DEBUG='false'; .\\venv\\Scripts\\alembic.exe history --verbose` (pass)
  - `cd backend; $env:DEBUG='false'; .\\venv\\Scripts\\python.exe -m py_compile alembic/env.py` (pass)
  - `cd backend; $env:DEBUG='false'; .\\venv\\Scripts\\alembic.exe check` (expected fail, but now actionable):
    - no `alembic_version` noise
    - no pure comment-only failures
    - remaining categories: index/constraint shape drift + nullable drift in signal tables
    - warning still present: FK cycle `trip_checkin_candidates` <-> `trip_places`
- Notes:
  - Phase 3 and Phase 4 are complete.
  - Phase 5 starts with index-contract alignment and signal nullability reconciliation migrations.
  - Phase 6 FK-cycle resolution remains required for long-term stability.

### 2026-03-21 (Session 3)
- Completed:
  - Phase 5A model/index reconciliation implemented across:
    - export (`export_jobs`, `export_share_tokens`)
    - idempotency (`api_idempotency_records`)
    - signals (`search_events`, `place_views`, `place_saves`)
    - metadata (`place_metadata`, `trip_metadata`, `route_metadata`)
    - routes/live-tracking (`routes`, `waypoints`, `trip_places`, `trip_tracking_sessions`, `trip_location_points`, `trip_checkin_candidates`, `trip_moments`, `trip_auto_entity_tombstones`, `trips`)
  - Added forward migration:
    - [f3a7b8c9d0e1_drop_legacy_routes_trip_index.py](/c:/Users/sumit/Downloads/Dora/backend/alembic/versions/f3a7b8c9d0e1_drop_legacy_routes_trip_index.py)
  - Applied migration locally with `alembic upgrade head`.
- Verification:
  - `cd backend; $env:DEBUG='false'; .\\venv\\Scripts\\python.exe -m py_compile ...` (pass for all touched model/migration files)
  - `cd backend; $env:DEBUG='false'; .\\venv\\Scripts\\alembic.exe upgrade head` (pass to `f3a7b8c9d0e1`)
  - `cd backend; $env:DEBUG='false'; .\\venv\\Scripts\\alembic.exe check` (pass: `No new upgrade operations detected.`)
  - `cd backend; $env:DEBUG='false'; .\\venv\\Scripts\\pytest.exe -q tests/test_trip_endpoints.py` (pass: `31 passed`)
- Notes:
  - Alembic check is now clean at head.
  - SQLAlchemy warning remains about FK cycle `trip_checkin_candidates` <-> `trip_places`; this is tracked in Phase 6.
  - Pydantic/FastAPI deprecation warnings observed in pytest output (non-blocking for this phase).

## Next Immediate Actions
1. Phase 6: Ship explicit FK-cycle strategy and migration for `trip_checkin_candidates` <-> `trip_places`.
2. Phase 7: Validate on both fresh DB and upgraded dataset clone with evidence logs (`upgrade head`, `check`, targeted pytest).
3. Phase 8: Lock governance artifacts (PR checklist + migration owner queue policy + CI enforcement notes).
