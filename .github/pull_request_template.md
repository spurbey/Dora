## Summary
- What changed:
- Why:

## Validation
- [ ] `alembic upgrade head` executed
- [ ] `alembic check` executed (zero new operations)
- [ ] Targeted tests executed (list below)

Commands run:
```bash
# Paste exact commands and outcomes
```

## Schema / Migration Checklist
- [ ] No applied migration history was rewritten/deleted.
- [ ] Every schema-affecting model change has a migration in this PR.
- [ ] Index names follow contract (`idx_*` / `uq_*`) and are explicitly declared.
- [ ] Nullability changes include data/backfill safety notes.
- [ ] Rollback intent is documented for new migration files.
- [ ] Drift policy and contract reviewed:
  - `docs/db-schema-contract.md`
  - `docs/alembic-recovery-execution-plan.md`

## Risk Notes
- Data migration risk:
- Lock/contention risk:
- Performance/index risk:

