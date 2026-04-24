# Advisory Pipeline: Current Server Behavior Baseline

Baseline date: 2026-04-24  
Validation method: live EC2/SSM runtime trace + code inspection + sub-agent synthesis.

## Why This Document Exists

This is the handoff baseline so future developers/agents do not have to re-derive:
- how advisory currently runs on server,
- what is implemented vs stubbed,
- what failed in real runtime,
- what to fix first.

Use this as source-of-truth starting point before new changes.

## Inputs Used

1. Live server execution on EC2 instance `i-09e5067742dd683c4` via SSM.
2. Real DB snapshots from running API container (`trip_advisory_state`, `advisory_jobs`).
3. Worker log tails (`advisory_worker`, `advisory_cycle_worker`).
4. Code-path inspection in backend + Flutter.
5. Sub-agent outputs: commit evolution, production runbook, gap analysis.

## Current End-To-End Behavior (As Running On Server)

## 1) Trip creation and seed

- Trip creation endpoint triggers async brain seed: `POST /trips` -> `seed_on_trip_creation(...)`  
  (`backend/app/api/v1/trips.py`, `backend/app/services/trip_brain_service.py`).
- Seed computes class/cadence/mode from trip dates + routes:
  - no route or short distance -> `intra_city` -> `mode=radius`,
  - route with enough distance -> `mode=route`.

## 2) Live session activation

- V2 live start calls `enrich_on_tracking_start(...)` best-effort:
  - sets lifecycle to active (unless paused/completed/errored),
  - sets initial `next_eligible_at = now + cadence`.
  (`backend/app/api/v2/live_tracking.py`, `backend/app/services/trip_brain_service.py`)

## 3) Cycle worker selection

- Cycle worker polls due active brains.
- Claim step applies a 120-second lease (`next_eligible_at = now + lease`) before processing.
- For each trip it runs `pick_next_target(...)`:
  - `route` mode: project current GPS to polyline progress, pick next uncovered sample ahead.
  - `radius` mode: use rolling centroid logic (Redis points preferred; DB fallback).
  (`backend/app/workers/advisory_cycle_worker.py`, `backend/app/services/trip_brain_service.py`)

## 4) Advisory job execution

`location_trigger` jobs run these stages:
1. `route_segmentation` (for cycle: locality-focused query plan),
2. `reddit_scrape` (implemented),
3. `tripadvisor_scrape` (stub skip),
4. `gmaps_scrape` (implemented for cycle jobs only),
5. `llm_extraction`,
6. `scoring` (ranker for cycle jobs),
7. `delivery`.
(`backend/app/workers/advisory_worker.py`)

## 5) Delivery and memory update

- Delivery writes `trip_advisories`, attempts push, stores `_delivery` metadata in job plan.
- Worker then calls `mark_cycle_outcome(...)` with `delivered` or `no_pick` for cycle jobs.
- `mark_cycle_outcome` is the only place that should advance cadence memory:
  - `last_cycle_at`,
  - `next_eligible_at`,
  - dedupe memory (`advised_locality_keys`, `advised_poi_place_ids`, no-pick counters).

## What Was Observed On Real Server

Controlled trace trip:
- trip_id: `347f1cbc-c643-4b1c-8a0f-281d32710b45`
- mode: `radius`
- cadence: `5400s` (90 min)

Observed runtime pattern before manual intervention:
- cycle kept generating `location_trigger` jobs about every 2 minutes,
- jobs completed mostly with `delivered_count=0`, occasional non-zero,
- cadence memory did not advance as expected.

Observed log signal:
- advisory ranker intermittently received OpenRouter 503 (`no healthy upstream`), non-fatal fallback behavior.

Observed state after explicit committed mark test:
- `last_cycle_at` set,
- `next_eligible_at` jumped to cadence window (`+90m`),
- rapid 2-minute churn stopped for that trace trip.

## Critical Finding: Cadence Persistence Bug Risk

Primary suspected bug in current runtime path:
- cycle/worker call `mark_cycle_outcome(...)` but do not enforce outer commit boundary afterward.
- `mark_cycle_outcome` uses nested transaction when session already in transaction.
- In that context, updates can fail to persist as intended in normal flow, leaving lease-driven requeue behavior.

Relevant files:
- `backend/app/workers/advisory_worker.py`
- `backend/app/workers/advisory_cycle_worker.py`
- `backend/app/services/trip_brain_service.py`

Status: not patched in this baseline yet. Treat as active P0 until fixed and verified on server.

## Live Hub vs Route-Mode Reality

Most recent live trips are entering radius mode because Live Hub trip creation currently sends metadata but not destination/route geometry.

Flutter path:
- `flutter/lib/features/live_capture/presentation/screens/live_hub_screen.dart`
- `flutter/lib/features/create/data/trip_repository.dart`

Because of that:
- backend has no route legs for those trips,
- `shape_from_trip` classifies as intra-city/unclassified,
- route sample branch is skipped,
- advisory is locality-at-current-position style, not along-upcoming-corridor style.

This is the largest product behavior mismatch versus expected road-trip advisory behavior.

## LLM Integration Status (Now)

Implemented:
- Reddit extraction uses OpenRouter.
- Cycle scoring/ranking uses ranker path with LLM-assisted pick behavior.

Not fully wired:
- `clarify_intent` stage is documented but not actually in worker stage order.
- model/schema constraints for advisory job stages do not include `clarify_intent`.
- `/conversation/answer` endpoint exists and can resume jobs, but the stage producer is incomplete.

## Upstash/Cache Wiring Status (Now)

Implemented in `advisory_cache`:
- brain cache invalidation/read helpers,
- mode cache,
- centroid points API (`push_centroid_point`, `get_centroid_points`),
- push throttle counter,
- geocode/weather/reddit seed caches,
- conversation cache + pending question cache.

Gap:
- hot centroid writer from V2 ingest path is not clearly wired in live ingest flow.  
  Current V2 publish path definitely writes DB `trip_route_raw_point`; Redis centroid writes appear absent in ingest code path.

Impact:
- radius mode can still work via DB fallback, but less immediate and potentially noisier.

## Stage Completion Matrix

| Capability | State | Notes |
|---|---|---|
| Trip brain seed/classify | Implemented | runs from trip creation |
| Tracking start enrichment | Implemented | best-effort async |
| Cycle worker claim + enqueue | Implemented | 30s poll, 120s lease |
| Route target pick | Implemented | needs routes present |
| Radius target pick | Implemented | Redis-first, DB fallback |
| Reddit scrape | Implemented | requires OpenRouter availability |
| TripAdvisor scrape | Stub | currently skipped |
| GMaps scrape (cycle jobs) | Implemented | runtime/config dependent |
| GMaps scrape (on-demand jobs) | Skipped by design now | policy not generalized |
| LLM extraction/merge | Implemented | after scrape stages |
| Cycle rank/scoring | Implemented | ranker path |
| Delivery to advisories | Implemented | pushes best-effort |
| Clarify-intent stage | Partial/Not wired | docs ahead of runtime |
| Ignore sweep expiry loop | Implemented | pause push not wired |
| Quiet-hours push suppression | Not implemented | mentioned but not enforced |

## Priority Gaps (Actionable)

## P0

1. Fix cycle outcome persistence/commit boundary so cadence memory always advances correctly.
2. Add destination/route capture in Live Hub flow and create backend route rows at live trip creation.

## P1

1. Wire `clarify_intent` stage end-to-end (worker stage order + model check + cache/question flow contract).
2. Wire centroid Redis writes from V2 ingest/hot path.
3. Implement TripAdvisor stage or remove from stage order until supported.
4. Decide and implement explicit on-demand GMaps policy (`never/conditional/always`).
5. Implement quiet-hours enforcement in push path.
6. Emit inactivity pause push from ignore sweep transition path.

## P2

1. Improve structured observability for skip/terminal reasons.
2. Add deterministic server-like E2E advisory test harness.
3. Align architecture/status docs with actual runtime state regularly.

## Commit Evolution Snapshot (Condensed)

High-level progression from sub-agent/git synthesis:
- 2026-04-15: advisory schema + APIs + worker skeleton + Reddit integration.
- 2026-04-16: trip brain + cycle + feedback + lifecycle hooks.
- 2026-04-17: V1 live tracking removal.
- 2026-04-18: data-flow fixes and live/navigation restructuring.
- 2026-04-19 to 2026-04-24: hosted GMaps scraping hardening, deploy/runtime fixes.

## Start-From-Here Guidance For Next Engineer/Agent

Do this order:
1. Patch and verify cadence persistence on server (P0-1).
2. Patch Live Hub destination->route generation path (P0-2).
3. Add server validation script for `last_cycle_at/next_eligible_at` progression after one completed job.
4. Then proceed to clarify-intent and centroid hot-write improvements.

Do not restart with broad rediscovery. Use this baseline and the server runbook:
- `docs/deployment/advisory-server-debug-runbook.md`

