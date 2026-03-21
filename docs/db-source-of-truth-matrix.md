# DB Source-of-Truth Matrix (Alembic Recovery)

## Snapshot
- Captured on: 2026-03-21
- Inputs:
  - `schema_matrix_raw.json` (model metadata vs upgraded DB snapshot)
  - `alembic check` output from `backend`
  - migration history (`alembic history --verbose`)

## Drift Totals
- Affected tables: 19
- Column drift entries: 96
- Comment-only drift entries: 86
- Nullability drift entries: 9
- Missing-in-model entries: 1 (`alembic_version.version_num`)
- DB-only indexes: 52
- Model-only indexes: 13
- DB-only unique constraints: 1
- FK drift entries: 0

## Root Causes (Evidence-Based)
- Comment churn without follow-up migrations:
  - many models added/rewrote `comment=` text after initial migrations.
  - this created 86 comment-only autogenerate ops.
- Index contract drift:
  - migrations use explicit `idx_*`/`uq_*` names (including composite/partial indexes),
  - several models use `index=True` which generates `ix_*` names and simpler indexes.
- Incomplete index declaration in models:
  - metadata/live-tracking/perf indexes exist in DB migrations but are absent from model `__table_args__`.
- Legacy nullable signal columns:
  - `a6cdd60d760c_create_signal_tables.py` created nullable signal fields,
  - current models later switched several fields to `nullable=False` without reconciliation migration.
- Internal table included in diff:
  - `alembic_version` is reflected and compared, but it is not an app-managed table.
- Migration graph complexity:
  - route schema evolved through branch + merge (`6e11ad2da6d0`, `90383dc1f729`, `a2f6b9c1d0e2`, `cca061e41224`), increasing drift risk when model/index policy is not strict.

## Source-of-Truth Decisions (Project-Health Oriented)

| Table | Drift Pattern | Source of Truth | Reconciliation Action |
|---|---|---|---|
| `alembic_version` | missing model column | Alembic internals | Exclude from compare via `include_object`. |
| `api_idempotency_records` | comments + DB-only indexes | DB schema for indexes | Keep `idx_*`/`uq_*`; mirror explicit indexes in model; ignore comment drift in check gate. |
| `export_jobs` | comments + `idx_*` vs `ix_*` | DB schema for indexes | Remove `index=True` from model fields; add explicit DB index definitions in model/migration contract. |
| `export_share_tokens` | comments + unique/index representation mismatch | DB schema for uniqueness/indexes | Keep named unique constraint + composite active index; stop relying on implicit `index=True` indexes. |
| `place_metadata` | DB-only perf indexes | DB schema for indexes | Add explicit model index declarations matching DB names/types. |
| `trip_metadata` | DB-only perf indexes | DB schema for indexes | Add explicit model index declarations matching DB names/types. |
| `route_metadata` | comments + DB-only perf indexes | DB schema for indexes | Add explicit model index declarations; comment diffs ignored by gate. |
| `routes` | comments + DB-only indexes | DB schema for indexes | Preserve DB index set; make model explicit and deterministic (no implicit index naming). |
| `waypoints` | DB-only index | DB schema for indexes | Add explicit model index declaration for `idx_waypoints_route`. |
| `trip_places` | comments + DB-only indexes | DB schema for indexes | Preserve existing search/source/candidate indexes; declare explicitly in model contract. |
| `trip_tracking_sessions` | comments + DB-only indexes | DB schema for indexes | Preserve state/active-session indexes; declare explicitly in model contract. |
| `trip_location_points` | comments + DB-only indexes | DB schema for indexes | Preserve session/time and trip/time indexes; declare explicitly in model contract. |
| `trip_checkin_candidates` | comments + DB-only indexes | DB schema for indexes | Preserve status and partial unique fingerprint index; declare explicitly in model contract. |
| `trip_moments` | comments + DB-only indexes | DB schema for indexes | Preserve time-window indexes; declare explicitly in model contract. |
| `trip_auto_entity_tombstones` | comments + DB-only indexes | DB schema for indexes | Preserve cooldown + partial uniqueness behavior; declare explicitly in model contract. |
| `trips` | comments + DB-only index | DB schema for indexes | Preserve `idx_trips_status`; declare explicitly in model contract. |
| `search_events` | nullable mismatch + `idx_*` vs `ix_*` | DB nullability, DB index design | Keep nullable ingestion columns for robustness; align model nullability and explicit index declarations. |
| `place_views` | nullable mismatch + `idx_*` vs `ix_*` | DB nullability, DB index design | Keep nullable ingestion compatibility in schema; enforce stricter validation in service layer if needed. |
| `place_saves` | nullable mismatch + `idx_*` vs `ix_*` | DB nullability, DB index design | Keep nullable ingestion compatibility in schema; enforce stricter validation in service layer if needed. |

## Policy-Level Decisions to Apply Immediately
- Comments are documentation metadata, not migration gate criteria.
- No implicit index naming for important tables; use explicit index declarations with stable names.
- Never rewrite applied migration history; all fixes are forward reconciliation migrations.
- One migration owner queue during stabilization.

## Open Decisions Requiring Signoff
- None currently blocking Alembic drift-gate stability.

## Post-Phase 5A Status (2026-03-21)
- Added explicit model index declarations to match DB contract across export, metadata, routes, and live-tracking tables.
- Added forward reconciliation migration:
  - `f3a7b8c9d0e1_drop_legacy_routes_trip_index.py` (drops duplicate `ix_routes_trip_id`)
- `alembic check` now returns: `No new upgrade operations detected.`

## Phase 6 Update (2026-03-21)
- SQLAlchemy cycle warning for `trip_checkin_candidates` <-> `trip_places` resolved by setting:
  - `trip_places.candidate_id` FK with explicit existing name `fk_trip_places_candidate_id`
  - `use_alter=True` to break DDL sort-cycle while preserving both FK relationships
- `alembic check` remains clean after this change and no cycle warning is emitted.

## Phase 7/8 Update (2026-03-21)
- Fresh-bootstrap validation exposed duplicate route-branch table creation in historical revision `90383dc1f729`.
- Remediation: revision now short-circuits when `routes` already exists, preserving deterministic `upgrade head` on clean databases.
- Validation status:
  - fresh DB: `upgrade head` + `check` passed
  - upgraded dataset clone DB: `upgrade head` + `check` passed
- Governance lock-in now includes repository PR template checklist for migration evidence and contract compliance.
