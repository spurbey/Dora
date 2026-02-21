# Phase 5 Step 0 Contract Freeze

Date: 2026-02-20  
Owner: Codex  
Status: Complete

## Scope
- Freeze Phase 5 implementation contracts before schema and feature coding.
- Eliminate ambiguous assumptions that would cause rework in queue/upload implementation.

## Frozen Decisions

1. Migration baseline:
- Drift migration target is `schemaVersion 6 -> 7`.
- Any older spec calling for `v5 -> v6` is outdated for this repo state.

2. Place identity contract for upload:
- Upload API requires backend `trip_place_id` UUID.
- Local place IDs are not guaranteed backend IDs.
- Phase 5 will add nullable `serverPlaceId` and use `ensureRemotePlaceId(localPlaceId)` prior to upload.

3. Queue idempotency:
- Queue processing must be claim/lock based.
- Repeated lifecycle/connectivity triggers must not duplicate upload attempts for the same row.

4. Worker bootstrap ownership:
- Queue worker lifecycle is centralized via a bootstrap/provider module started from app root.
- UI screens/providers do not create independent processing loops.

5. File lifecycle policy:
- Temp compressed files and thumbnails are app-managed artifacts.
- Cleanup required after uploaded/canceled/remove flows.
- Stale failed artifacts require retention-window cleanup.

6. Navigation contract:
- Media route will include both trip and place context:
  - `/trips/:tripId/places/:placeId/media`

7. Phase 4 baseline gate:
- Phase 4C route/editor expectations are baseline for regression and must remain stable through Phase 5.

## Source of Truth
- `flutter/docs/phases/Phase-5-PRD.md`
- `flutter/docs/phases/Phase-5-Execution-Checklist.md`
- `flutter/docs/handoffs/phase5-milestones-handoff.md`

## Open Risks Carried Into Step 1
- Drift/freezed codegen sync will be required after schema/model updates.
- Backend behavior for place/media identity mismatch remains a runtime risk if not handled through `ensureRemotePlaceId`.

## Next Milestone
- Start Step 1: schema and DAO migration (`v6 -> v7`) with queue metadata and backfill.

