# Project Status - Dora

Last Updated: 2026-02-20
Current Focus: Flutter Phase 4C complete — ready for Phase 5
Overall Progress: Flutter P1-P4C complete

---

## Current Workstream

### Flutter Phase 4 Rebuild
Status: Phase 4C complete ✅

Completed:
- Baseline Phase 4 implementation:
  - `2e6f655` - complete Phase 4 editor + mapbox migration
  - `8f52781` - Phase 4 editor UX/map polish
- Phase 4A rebuild:
  - `cf8a2b1` - domain/storage/repository expansion for city + multi-modal route model
  - `a654b94` - Phase 4A business-logic test suite
- Phase 4B:
  - `ad9ba89` - city search, geocoding, bottom-sheet forms, layout fixes
  - `53494f3` - ElevatedButton layout fix in detail forms
- Phase 4C (pending commit):
  - Bug fixes: timeline connector, route DAO ordering, draft leakage, sync guard, synthetic connectors
  - Route creator UX: From/To form panel, no auto-draw, loading states
  - Directions API: BackendDirectionsAdapter (Dio), haversine fallback
  - Route edit toolbar + waypoints: editRoute mode, Drift v5→v6, flip/add/remove waypoints

In progress / next:
- Phase 5: see `flutter/docs/phases/Phase-5-PRD.md`

---

## Backend Status (context)
- V2 backend phases A1, A2, A3 implemented.
- V2 frontend web phases B, C, D implemented.
- Current immediate delivery focus is Flutter editor quality.

---

## Quality and Verification
- `flutter analyze --no-pub` — zero new issues across all Phase 4C files
- `dart run build_runner build --delete-conflicting-outputs` — run 3× successfully
- Test files:
  - `flutter/test/features/create/phase4a_business_logic_test.dart`
  - `flutter/test/features/create/phase4c_business_logic_test.dart`

---

## Known Risks
- Schema/model updates require codegen sync before reliable runtime testing.
- Route transport mode naming: `foot` canonical, legacy `walk` compat maintained.
- `BackendDirectionsAdapter` requires backend `POST /api/v1/routes/generate` endpoint to be live for real road geometry; haversine fallback active otherwise.
- Drift v5→v6 migration runs automatically on first app launch after update.

---

## Recent Commits (latest first)
- `53494f3` fix(theme): avoid infinite-width ElevatedButton layout in create detail forms
- `ad9ba89` feat(create): phase 4B — city search, geocoding, bottom sheet forms, layout fixes
- `a654b94` test(create): add Phase 4A business-logic coverage for editor and route generation
- `cf8a2b1` feat(flutter): phase 4A — expand editor models, Drift migration v5, multi-modal routing support
- `cfed2ec` feat(flutter): add Android Firebase setup
