# Current Phase: Flutter Phase 4 Rebuild

Phase: Flutter-Phase-4 | Status: Sub-Phase 4A complete, 4B ready

## Active Branch
- `Flutter-Dev`

## Latest Committed Milestones
- `cf8a2b1` - `feat(flutter): phase 4A — expand editor models, Drift migration v5, multi-modal routing support`
- `a654b94` - `test(create): add Phase 4A business-logic coverage for editor and route generation`

## What Is Done (4A)
- Expanded create-domain models:
  - `Place`: `placeType`, `rating`
  - `Route`: `name`, `description`, `routeCategory`, `startPlaceId`, `endPlaceId`, `orderIndex`, `routeGeojson`
  - `EditorMode`: city + multi-route modes (`addCity`, `addRouteAir`, `addRouteCar`, `addRouteWalking`)
  - `EditorState`: `routeStartItemId`, `routeStartItemType`
- Drift schema upgraded to v5 with place/route column additions.
- Repositories updated for new model-table mappings.
- Route generation path updated for multi-modal mode selection.

## QA Status
- Phase 4A business-logic tests added at:
  - `flutter/test/features/create/phase4a_business_logic_test.dart`
- Test execution should be run and recorded from local terminal:
  - `flutter test test/features/create/phase4a_business_logic_test.dart -r expanded`

## Next Phase (4B)
- Add city search flow and geocoding abstraction wiring.
- Implement bottom-sheet detail forms for city/place.
- Differentiate city/place marker rendering and timeline presentation.

## Notes
- Keep implementation incremental: finish and verify each sub-phase before moving to the next.
- Use PRD cross-check at each checkpoint (`flutter/docs/phases/Phase-4-PRD.md`).
