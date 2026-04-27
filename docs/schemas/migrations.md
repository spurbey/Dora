# Dora Migration History and Runbook

Last updated: 2026-04-03  
Migration source: `backend/alembic/versions/*`

## 1) Current Revision State

- Current head revision: `f4b8c9d1e2a3`
- Alembic config: `backend/alembic.ini`
- Migration directory: `backend/alembic/versions`

## 2) Chronological Revision Timeline

## 2.1 Foundation and Core Domain

| Revision | Date (from file) | Scope | Summary |
|---|---|---|---|
| `034e6815354f` | 2026-01-22 | Core bootstrap | Creates `users`, `trips`, `trip_places` with PostGIS geography index. |
| `fc795732477e` | 2026-01-26 | Media | Creates `media_files`. |
| `6cfcf98fd21b` | 2026-01-28 | Search | Adds `trip_places.search_vector` + trigger + GIN index. |
| `a6cdd60d760c` | 2026-01-28 | Signals | Creates `search_events`, `place_views`, `place_saves`. |
| `ae14fa145f26` | 2026-02-02 | Metadata | Creates `trip_metadata`, `place_metadata`. |

## 2.2 Route Evolution and Branch Reconciliation

| Revision | Date | Scope | Summary |
|---|---|---|---|
| `6e11ad2da6d0` | 2026-02-02 | Initial routes | Creates early `routes` + `route_metadata` schema. |
| `a2f6b9c1d0e2` | 2026-02-02 | PRD upgrade | Upgrades routes to PRD shape, adds `waypoints`, migrates/renames route fields, route metadata refresh. |
| `fdacf42ca8c0` | 2026-02-02 | Merge | Merges (`a6cdd60d760c`, `ae14fa145f26`). |
| `90383dc1f729` | 2026-02-02 | Alternate route branch | Idempotent route-table branch guarded against duplicate creation. |
| `cca061e41224` | 2026-02-03 | Merge | Merges (`90383dc1f729`, `a2f6b9c1d0e2`). |
| `44f915b7a490` | 2026-02-03 | Timeline view | Adds `trip_components_view`. |
| `f3a7b8c9d0e1` | 2026-03-21 | Index cleanup | Drops duplicate legacy `ix_routes_trip_id`. |

## 2.3 Export System

| Revision | Date | Scope | Summary |
|---|---|---|---|
| `b1e4c7d9f2a1` | 2026-02-27 | Export control plane | Creates `export_jobs` plus queue/claim indexes and update trigger. |
| `d6f9a8b4c321` | 2026-03-08 | Export sharing | Creates `export_share_tokens` plus update trigger/indexes. |

## 2.4 Live Tracking (Phase 1 -> Phase 2)

| Revision | Date | Scope | Summary |
|---|---|---|---|
| `e9b3f0a7c1d2` | 2026-03-21 | Live tracking base | Adds trip tracking status columns; creates `trip_tracking_sessions`, `trip_location_points`, `trip_checkin_candidates`, `trip_moments`, tombstones, idempotency table; adds source/confidence fields on places/routes. |
| `c2d4f6a8b0e1` | 2026-03-21 | Push tokens | Creates `user_device_tokens`. |
| `b7c2e1d4f9a3` | 2026-03-22 | Inference cursor | Adds `inference_cursor_at`, `inference_updated_at` to tracking sessions. |
| `d4e9c2a1b7f0` | 2026-03-22 | Uninferred marker | Adds `oldest_uninferred_point_at` to tracking sessions. |
| `f1c5a9e2d4b6` | 2026-03-22 | Token ownership hardening | Reconciles duplicate push tokens and switches uniqueness to global `push_token`. |
| `a7d9c4e1f2b3` | 2026-03-22 | Notification state | Creates `trip_tracking_notifications`. |
| `b3f1d8c7e2a4` | 2026-03-22 | Notification audit | Creates append-only `trip_tracking_notification_events`. |
| `f8e2a1d9c4b7` | 2026-03-25 | Delivery-state extension | Adds `suppressed_foreground` notification state. |
| `c9e4b7a1d2f6` | 2026-03-31 | Event ingestion | Creates `trip_tracking_events`; backfills legacy trip statuses to `planned`. |

## 2.5 Compiled Projection

| Revision | Date | Scope | Summary |
|---|---|---|---|
| `9d1c4e7b2a6f` | 2026-04-01 | Compiler storage | Creates compiled projection state/items/route segments/overrides tables. |
| `f4b8c9d1e2a3` | 2026-04-01 | Media compiler expansion | Creates `trip_tracking_event_media`; expands compiled source kinds to include media rows. |

## 3) Production Migration Runbook

## 3.1 Standard Apply Flow

```bash
cd backend
alembic upgrade head
alembic check
```

Expected after successful reconciliation: `alembic check` reports no new upgrade operations.

## 3.2 CI / Release Gate Expectations

- Apply migrations before app/worker rollout.
- Run targeted regression tests for affected domains:
  - live tracking (`backend/tests/test_live_tracking_endpoints.py`)
  - exports (`backend/tests/test_export_endpoints.py`)
  - compiled projection (`backend/tests/test_compiled_projection_endpoints.py`)

## 3.3 Drift Governance Rules

Authoritative policy lives in:

- `docs/db-schema-contract.md`
- `docs/db-source-of-truth-matrix.md`
- `docs/alembic-recovery-execution-plan.md`

Operational rules:

- Forward-only migration policy (no rewriting applied revisions).
- Schema model change and migration revision ship in the same PR.
- Prefer explicit index naming (`idx_*`, `uq_*`) over implicit `index=True` naming on critical tables.

## 3.4 Rollback Reality

- Most downgrades are destructive for domain state (tracking/export/compiler data loss).
- Treat downgrade as emergency-only.
- Primary recovery strategy should be:
  - point-in-time restore + forward fix migration,
  - not routine downgrade in production.

## 4) Quick Verification Commands

```bash
cd backend
alembic current
alembic history --verbose
alembic heads
```

Use these to confirm the deployed database matches expected head `f4b8c9d1e2a3`.
