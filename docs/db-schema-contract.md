# DB Schema Contract (Alembic)

## Status
- Drafted: 2026-03-21
- Purpose: freeze a stable migration contract that scales with parallel feature work and prevents recurring Alembic drift.

## Contract Rules
1. Forward-only migration policy:
   - Never rewrite or delete applied migration history.
   - Reconcile drift using new forward revisions only.
2. Schema change ownership:
   - Every schema-affecting model change must include its migration in the same PR.
   - During stabilization windows, one migration owner queue controls merge order.
3. CI gate order:
   - `alembic upgrade head` must run before `alembic check`.
   - `alembic check` must return zero new operations.
4. System/extension object exclusion:
   - Alembic comparisons exclude extension-managed objects and internal migration tables.
5. Index naming and declaration:
   - Use explicit index declarations for contract tables.
   - Preferred naming: `idx_<table>_<purpose>` for non-unique indexes.
   - Preferred naming: `uq_<table>_<purpose>` for unique constraints/partial-unique indexes.
   - Avoid implicit `index=True` on critical tables where deterministic names matter.
6. Nullability changes:
   - Any `NULL -> NOT NULL` change requires a lock-safe migration pattern:
     - data audit
     - backfill/remediation
     - constraint enforcement
   - Nullability decisions must be documented in source-of-truth matrix before migration generation.
7. Comment policy:
   - Column comments are documentation metadata and do not block migration drift gate.
   - Comment-only changes can be batched separately when needed.
8. FK-cycle policy:
   - New FK cycles are disallowed.
   - Existing cycles require explicit design decision and migration notes.
9. Validation matrix:
   - Validate on fresh DB and upgraded DB clone for every reconciliation batch:
     - `alembic upgrade head`
     - `alembic check`
     - targeted pytest suites for impacted domain
10. Connection schema determinism:
   - Runtime and test DB engines must enforce deterministic `search_path` defaults.
   - Shared engine helpers should be reused instead of ad-hoc `create_engine(...)` calls.

## Required PR Checklist (Schema PRs)
- [ ] Model changes and migration revision are in same PR.
- [ ] Migration is deterministic and idempotent for reruns.
- [ ] Rollback intent is documented.
- [ ] Index names follow contract naming.
- [ ] Nullability transitions include data remediation plan.
- [ ] `alembic upgrade head` and `alembic check` outputs are attached.
- [ ] Repository PR template checklist is completed:
  - `.github/pull_request_template.md`

## Current Reconciliation Scope
- Source-of-truth table decisions are tracked in:
  - [db-source-of-truth-matrix.md](/c:/Users/sumit/Downloads/Dora/docs/db-source-of-truth-matrix.md)
- Execution progress and evidence log are tracked in:
  - [alembic-recovery-execution-plan.md](/c:/Users/sumit/Downloads/Dora/docs/alembic-recovery-execution-plan.md)
