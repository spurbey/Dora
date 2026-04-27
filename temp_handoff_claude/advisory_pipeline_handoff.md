# Advisory Pipeline Incremental Event Ledger (2026-04-18)

Purpose: dense chronological handoff for the next agent.  
Scope: major conversation, design, implementation, validation, and failure events.

## Phase 1: Session Re-entry and Scope Selection

1. User asked what work was in progress.
2. Agent checked recent commits and reported two active tracks:
   - Advisory pipeline (recent committed work).
   - Live Tracking V2 (uncommitted edits in backend + Flutter).
3. User explicitly selected `advisory pipeline`.
4. Agent summarized advisory status as MVP working end-to-end:
   - schema/models/migration present,
   - advisory endpoints live,
   - worker pipeline stages wired,
   - Reddit scraper integrated,
   - test run produced insights.
5. Agent listed remaining items then believed these were next:
   - Redis cache,
   - TripAdvisor scraper,
   - GMaps integration,
   - push delivery,
   - Flutter advisory UI.

## Phase 2: Planning Friction and Auto-trigger Misalignment

6. User asked for a finish plan but said:
   - skip Flutter UI in this slice,
   - focus only on remaining backend work.
7. Agent raised `location_trigger` behavior and initially framed predictive "approaching next place" behavior.
8. User challenged feasibility (route certainty, geojson decoding, reroutes, confidence).
9. Agent re-explored code and acknowledged prior assumptions were wrong/hand-wavy.
10. Agent reported actual backend state:
    - `route_geojson` exists as opaque geometry storage,
    - no robust route-projection/off-route/corridor subsystem.
11. User asked "what is trip_place?"
12. Agent clarified `trip_places` means user-pinned itinerary places; not auto-generated route cities.
13. Interim conclusion at this point:
    - proactive city-approach inference was not implemented,
    - stronger infra needed for real predictive trigger logic.

## Phase 3: Requirement Pivot (User Defines True Target Architecture)

14. User overrode defer recommendation and required fixing auto-trigger.
15. User specified desired trigger approach:
    - reverse geocode upcoming route points periodically (time or distance cadence),
    - cache location/context,
    - run scraping using past advisory/trip metadata state.
16. Agent reframed architecture around persistent "trip brain/state".
17. User corrected scraper mapping:
    - `scraper_lean` = GMaps (Bright Data based prototype),
    - `scraper_reddit` = Reddit,
    - do not assume `scraper_gmaps` as actual prod path.
18. User asked agent to explore commits/migrations/docs first, then plan.

## Phase 4: Deep Exploration and Design Convergence

19. Agent ran broad exploration (code/docs/history) and surfaced operational findings:
    - cycle worker behavior conditions,
    - env/feature-flag diagnostics,
    - push dependencies,
    - unresolved runtime checks.
20. Explicit decisions crystallized through iterative Q/A:
    - Flutter redesign deferred to later slice.
    - Weather + time-of-day are required ranking inputs.
    - TripAdvisor deferred for current slice (Reddit-first signal path).
    - Auto-trigger remains required for usefulness.
21. Plan editing loop became large:
    - repeated `/plan` updates,
    - multiple "concern rounds" from Codex/agent review,
    - race conditions, caching keys, units, off-route notes, SQL/guardrails were discussed and patched in plan text.
22. User approved plan saved as `~/.claude/plans/cosmic-knitting-rabbit.md`.

## Phase 5: Backend Implementation Execution (Large Build-out)

23. Agent started coding against approved plan (backend first).
24. Added core state models and migration:
    - `user_metadata`,
    - `trip_advisory_state` (trip brain),
    - route/advisory model extensions,
    - Alembic revision `a1b2c3d4e5f6...`.
25. Added/configured services:
    - `advisory_cache.py`,
    - `geocoding_service.py`,
    - `weather_service.py`,
    - `route_sampler.py`,
    - `trip_classifier.py`,
    - later `trip_brain_service.py`.
26. Added GMaps scraper service integration path:
    - `app/services/scrapers/gmaps_scraper.py`
    - explicitly as API-driven/service path (not local browser-profile workflow).
27. Added/updated ranking and cycle logic:
    - `advisory_ranker.py`,
    - `advisory_worker.py` gained `location_trigger` branches,
    - target extraction, cycle-job handling, dedupe handling.
28. Added background workers:
    - `advisory_cycle_worker.py`,
    - `advisory_ignore_sweep_worker.py`.
29. API/lifecycle hooks extended:
    - advisory endpoints adjusted (self-heal paths and state checks),
    - trip hooks + push wiring integrated in backend services.
30. Push service extended for advisory notification dispatch path.
31. Migration conflict handled:
    - two alembic heads detected,
    - merge migration created,
    - upgrade verified.
32. Large backend commit landed:
    - commit `0a90f21`,
    - ~25 files, ~+5k lines.

## Phase 6: Validation and Stabilization After Backend Merge

33. Agent checked whether missing hook items were already handled by another commit.
34. Confirmed overlap with existing commit `7a69be8`; net state included those hooks.
35. Added resilience tests:
    - `backend/tests/test_advisory_resilience.py`.
36. Hit transaction error in `trip_brain_service.py` during tests.
37. Refactored transaction handling (removed bad quick hack, used proper pattern).
38. Re-ran advisory suite:
    - resilience tests passed,
    - broader advisory tests reported passing.
39. Updated architecture docs to reflect cycle/brain/current flow and deferrals.
40. Backend phase reported as complete for planned steps.

## Phase 7: Flutter/OpenAPI Integration Slice

41. New scope kicked in: OpenAPI regen then Flutter advisory wiring.
42. OpenAPI export/regeneration performed; advisory endpoints confirmed in spec.
43. Generated API client artifacts and build_runner outputs.
44. Built Flutter advisory data layer:
    - API providers wiring,
    - `advisory_repository`,
    - `advisory_providers`,
    - typed `advisory_brain_state` model,
    - advisory feature guard.
45. Added advisory debug screen and feature flag wiring.
46. Fixed enum/type fallout from generated-model changes.
47. Fixed unrelated compile breakages triggered by regen in:
    - create route repository,
    - feed API.
48. Flutter analysis reached zero errors.
49. Large Flutter commit landed:
    - commit `00b4f47` (many regenerated files + advisory wiring).
50. Follow-up bug in create/update route path fixed and committed:
    - commit `4652221`.
51. Advisory debug entry wired into editor overflow menu.

## Phase 8: Runtime Failure Report and Final Critical Fix

52. User reported advisory still broken in runtime:
    - trip creation UI mismatch concerns,
    - advisory debug all red,
    - brain-state unavailable,
    - start/query/jobs/insights returning 404 trip-not-found.
53. Agent diagnosed root cause:
    - Flutter passed local Drift `tripId` to advisory backend,
    - backend expects server PostgreSQL UUID.
54. Implemented local->server ID resolution for advisory flows using existing sync resolver:
    - added `serverTripIdProvider`,
    - advisory providers now resolve server trip ID before calls,
    - debug screen actions (`start`, `pause`, `resume`) use resolved server ID.
55. Files changed for this fix:
    - `flutter/lib/features/advisory/providers/advisory_providers.dart`
    - `flutter/lib/features/advisory/presentation/screens/advisory_debug_screen.dart`
56. Static verification:
    - `flutter analyze lib/features/advisory/` reported zero errors.
57. Fix committed as:
    - `dac1070`.

## Phase 9: Abrupt Session Interruption

58. Immediately after `dac1070`, model commands started failing with invalid model identifier errors.
59. Session ended without user-confirmed runtime retest of the 404 fix.

## Confirmed Outcomes

- Significant backend advisory architecture build-out was implemented and committed.
- Flutter advisory integration and debug surface were implemented and committed.
- Critical advisory 404 ID-mismatch bug was fixed in `dac1070`.

## Unverified / Still Risky at End of Transcript

- Runtime verification of `dac1070` in app session was not completed in transcript.
- User-reported trip creation template/flow mismatch remained open in last message.
- Final production confidence depends on full integrated run:
  - backend workers + migration state + flutter runtime path + push/env flags.

## Immediate Next Steps for New Agent

1. Reproduce user's latest scenario on current HEAD and confirm whether `dac1070` resolves advisory 404s.
2. Validate trip creation/editor behavior mismatch the user reported (separate from advisory debug).
3. Run full advisory E2E smoke:
   - pre-trip start,
   - query/jobs/insights,
   - cycle worker trigger path,
   - state visibility in debug screen.
4. If failures persist, collect exact local ID/server ID mapping evidence before further architecture changes.
