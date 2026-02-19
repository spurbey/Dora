# Project Status - Dora

Last Updated: 2026-02-19
Current Focus: Flutter Phase 4 Rebuild (incremental)
Overall Progress: Flutter P1-P3 complete, Phase 4 baseline complete, Phase 4A rebuild complete

---

## Current Workstream

### Flutter Phase 4 Rebuild
Status: In progress

Completed:
- Baseline Phase 4 implementation previously landed:
  - `2e6f655` - complete Phase 4 editor + mapbox migration
  - `8f52781` - Phase 4 editor UX/map polish
- Phase 4A rebuild landed:
  - `cf8a2b1` - domain/storage/repository expansion for city + multi-modal route model
- Phase 4A test suite landed:
  - `a654b94` - business-logic tests for editor mode contracts and route generation rules

In progress / next:
- 4B: city search + geocoding + bottom-sheet detail forms
- 4C: route creation UX (air/car/walking), route detail and map behavior
- 4D: unified timeline reorder and final polish/QA

---

## Backend Status (context)
- V2 backend phases A1, A2, A3 implemented.
- V2 frontend web phases B, C, D implemented.
- Current immediate delivery focus is Flutter editor quality and PRD alignment.

---

## Quality and Verification
- Added dedicated Flutter test file:
  - `flutter/test/features/create/phase4a_business_logic_test.dart`
- Required validation for each sub-phase:
  1. `flutter analyze --no-pub`
  2. `dart run build_runner build --delete-conflicting-outputs` (when models/storage change)
  3. Targeted test run for changed area
  4. Manual editor flow check against PRD

---

## Known Risks
- Schema/model updates require codegen sync before reliable runtime testing.
- Route transport mode naming must stay consistent (`foot` canonical, legacy `walk` compatibility where needed).
- Timeline reorder correctness remains a high-risk area for regression and must be validated after 4D wiring.

---

## Recent Commits (latest first)
- `a654b94` test(create): add Phase 4A business-logic coverage for editor and route generation
- `cf8a2b1` feat(flutter): phase 4A - expand editor models, Drift migration v5, multi-modal routing support
- `cfed2ec` feat(flutter): add Android Firebase setup
- `8f52781` feat(flutter): polish Phase 4 editor UX + map interactions
- `2e6f655` feat(flutter): complete Phase 4 editor + mapbox migration
