# Subsystem Specs Index

This folder contains implementation-grade specs for each V2 subsystem.

## Entry point

1. [Master Blueprint](./master-blueprint.md)

## Subsystem docs

1. `local-journal-and-resolver-spec.md`
- Local schema, resolver states, manual-lock rules, unresolved inbox contract.

2. `session-commit-worker-spec.md`
- Session-stop local staging model, immutable snapshot artifacts, lease/recovery, UX states.

3. `trip-publish-spec.md`
- Explicit publish/save flow, payload freeze, idempotency, retry semantics.

4. `local-timeline-compiler-spec.md`
- Deterministic local compilation rules, incremental invalidation, UI projection tables.

5. `backend-ingest-and-projection-spec.md`
- Publish-only server ingest, server-side compile, bounded read models, cross-device restore behavior.

6. `live-editor-ui-contract-spec.md`
- Shared unresolved panel behavior, live/editor action semantics, local-vs-publish status copy rules.

7. `command-lane-spec.md`
- Start/stop server contract, pause/resume local-only behavior, stop reconciliation during publish commit.

## Cross-reference rule

Every subsystem doc should include:

1. A link to [Master Blueprint](./master-blueprint.md).
2. A "Depends on" section listing required sibling subsystem docs.
3. A "Used by" section listing downstream subsystem docs.
