# Current Phase: Flutter Phase 4C — Route UX + Bug Fixes ✅ COMPLETE

Phase: Flutter-Phase-4C | Status: Complete — ready for device testing

## Active Branch
- `Flutter-Dev`

## Latest Committed Milestones
- Phase 4B: city search, geocoding, bottom-sheet forms
- Phase 4C: route bug fixes, route creator UX, Directions API, edit toolbar + waypoints

## What Is Done (4C)

### Phase A — Bug Fixes
- **A1** `timeline_sidebar.dart`: ID-based route connector (was index-based, always showed wrong route)
- **A2** `route_dao.dart`: Deterministic `ORDER BY orderIndex, localUpdatedAt`
- **A3** `editor_provider.dart`: Fixed draft leakage in `setMode()` and `deselectAll()` — all 3 draft fields always cleared
- **A4** `app_map_view.dart`: Serial sync guard (`_syncInFlight + _needsResync`) — no concurrent `_syncOverlays()`
- **A5** `map_provider.dart` + `mapbox_adapter.dart`: Synthetic gray-dashed connectors; `_conn_` prefixed routes not tappable

### Phase B — Route Creator UX
- `EditorState`: added `routeEndItemId`, `isGeneratingRoute`
- `EditorProvider`: `selectRouteSource`, `selectRouteDestination`, `clearRouteDraft`, `cancelRouteMode`, `handleMapTap` — no auto-draw
- New `route_creator_form.dart`: From/To dropdowns (Air = cities only), loading indicator, disabled Create button
- `editor_screen.dart`: `_buildDetailContent(EditorState, EditorController)` — RouteCreatorForm in bottom panel, auto-expanded in route mode
- `map_canvas.dart`: Removed old instruction overlay

### Phase C — Directions API
- New `core/map/directions/`: `AppDirectionsService` abstract, `BackendDirectionsAdapter` (Dio → `POST /api/v1/routes/generate`, haversine fallback), `directionsServiceProvider`
- `RouteRepository.generateRouteViaApi()` with fallback
- Car/walk routes call API; air routes use arc generator

### Phase D — Route Edit Toolbar + Waypoints
- `EditorMode.editRoute` added
- `Route.waypoints: List<AppLatLng>` added; Drift schema v5→v6 (`waypointsJson` column + migration)
- New `route_edit_toolbar.dart`: Edit/Flip/Delete/Close glassmorphism toolbar
- `EditorProvider`: `toggleRouteEditMode`, `addWaypoint`, `removeWaypoint`, `flipRoute`
- `MapProvider`: waypoint markers (`_wp_` prefix, purple), 3x route width in editRoute, blue dest marker

## QA Status
- `flutter analyze` — zero new issues on all changed files
- `build_runner` run 3× (EditorState B1, directions C1, Route+Drift+EditorMode D1-D3) — all successful
- Business logic test: `flutter/test/features/create/phase4c_business_logic_test.dart`

## Next Phase (5)
- PRD at: `flutter/docs/phases/Phase-5-PRD.md`
- Checklist: `flutter/docs/phases/Phase-5-Execution-Checklist.md`
