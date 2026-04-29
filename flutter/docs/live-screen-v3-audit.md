# Live Screen V3 — Phase 0 Audit Report

> Last updated: 2026-04-29
>
> Plan: `~/.claude/plans/glistening-sniffing-reef.md`

This file documents Phase 0 audit findings — what we confirmed before starting Phase 1. Future agents reading this avoid re-running the same checks.

---

## 1. Mapbox SDK API surface (mapbox_maps_flutter ^2.18.0)

All required APIs are confirmed available. **Phase 0 audit PASSES.**

| Required API | Status in 2.18.0 | Exact name |
|---|---|---|
| Add a Layer (Line/Symbol/Circle/FillExtrusion) | ✅ | `mapboxMap.style.addLayer(Layer)` and `addLayerAt(Layer, LayerPosition)` |
| Add a Source (GeoJsonSource, RasterDemSource) | ✅ | `mapboxMap.style.addSource(Source)` |
| Register a style image (sprite) | ✅ | `mapboxMap.style.addStyleImage(...)` |
| Remove a style image | ✅ | `mapboxMap.style.removeStyleImage(imageId)` |
| Runtime paint property update (for warn pulse animation) | ✅ | `mapboxMap.style.setStyleLayerProperty(layerId, property, value)` |
| 3D terrain | ✅ | `style.setStyleTerrain(properties)` + `setStyleTerrainProperty(property, value)` |
| Map coord → screen pixel (callout positioning) | ✅ | `mapboxMap.pixelForCoordinate(Point)` returns `ScreenCoordinate` |
| Screen pixel → map coord | ✅ | `mapboxMap.coordinateForPixel(ScreenCoordinate)` |
| Tap-to-feature | ✅ | `mapboxMap.queryRenderedFeatures(...)` returns `List<QueriedRenderedFeature?>` |
| Camera-change subscription (callout re-anchor on pan/zoom/rotate) | ✅ | **Declarative prop** `MapWidget(onCameraChangeListener: ...)` — NOT `addListener` after creation. Must be wired through the widget config. |
| Style-loaded subscription (re-register sprites on style reload) | ✅ | **Declarative prop** `MapWidget(onStyleLoadedListener: ...)` — already used elsewhere in this codebase (`live_capture_map_widget.dart:188`, `app_map_view.dart:226`). |
| Data-driven `icon-rotate` from feature property | ✅ | `SymbolLayer.iconRotateExpression: List<Object>` — pass an expression like `['get', 'rotation']` to read from feature property. **No fallback needed.** |
| Line gradient | ✅ | `LineLayer.lineGradientExpression` (with `interpolate` expression on `line-progress`). Source must have line-metrics enabled. |
| Animated dasharray | ✅ | `LineLayer.lineDasharray` + runtime updates via `setStyleLayerProperty('layer-id', 'line-dasharray', [..])` |

### Style-reload re-registration plan

When the style reloads (e.g., dimensional mode toggle if it ever swaps style URL, dark/light flip), all `addStyleImage` sprites + custom sources/layers are wiped. Subscribe via `MapWidget.onStyleLoadedListener` prop and call a single `_registerCustomStyleAssets()` method that:
1. Re-registers all sprites via `addStyleImage`
2. Re-adds all custom sources (GPS trail, memories, 3 event types)
3. Re-adds all custom layers (in correct z-order: glow, gradient, dasharray, memory, note, geotag, warn, warn-pulse)

This same method is called on first style-load and on every reload, idempotently.

### Camera-listener wiring caveat

Unlike a typical "add/remove listener" pattern, Mapbox 2.18.0 only accepts ONE `onCameraChangeListener` declaratively at widget construction. The `LiveCaptureMapWidget` already uses `onStyleLoadedListener` this way; we'll add `onCameraChangeListener` via the same prop pattern. Internally, the controller fans out to multiple subscribers (callout overlay, follow-mode logic) since the SDK doesn't support multi-listener registration here.

---

## 2. Pubspec dependencies

| Package | Status | Action |
|---|---|---|
| `mapbox_maps_flutter` | ✅ `^2.18.0` | Use as-is |
| `google_fonts` | ❌ Not present | **No add this sprint.** Use existing app typography |
| `battery_plus` | ❌ Not present | **No add this sprint.** Drop battery-suggester from cinematic toggle (it's not load-bearing — toggle works without battery awareness) |
| `flutter_riverpod` | ✅ Present | State management — used as-is |
| `mapbox_maps_flutter` | ✅ `^2.18.0` | Map SDK |

---

## 3. App typography surface

The app currently uses an existing display font surface. `DoraTypography` will compose `TextStyle` presets from this font with weight/size/tracking tuning to deliver the storybook display feel:
- Display variants: `fontWeight: FontWeight.w600` or `w700`, +1 to +2 size bump, slightly looser tracking (`letterSpacing: 0.2`)
- Body variants: existing weight, existing tracking
- Bubble/callout text: `w500`, slightly tighter line-height for compact readability

(Specifics finalized when `dora_theme.dart` is built — pending check of which existing font surface is in use.)

---

## 4. V1 banner audit

All three V1 banners are confirmed **dead code in the V2 lane**. Safe to delete in Phase 6 with no V3 replacement needed (V2 already replaced their function via the inbox-based resolver review surface).

| Banner (in `live_capture_screen.dart`) | Trigger condition | V2 status | Verdict |
|---|---|---|---|
| `_SyncBlockedCallout` (lines 1483–1529) | `!useV2Lane && syncStatus?.kind == blocked && hasBlockedMedia` (lines 276–279). `syncStatusAsync` is hardcoded `null` in V2 (line 218). | Dead in V2 — gated on `!useV2Lane` AND status never written | **DELETE.** No V3 replacement. |
| `_UnresolvedCaptureBanner` (lines 1531–1600) | `!useV2Lane && unresolvedSummary.hasReviewRequired` (lines 284–287). `unresolvedSummary` hardcoded empty in V2 (lines 239–244). Comment: "V1 unresolved summary provider removed — V2 uses inbox-based review". | Dead — count always 0; `!useV2Lane` gate. V2 surfaces unresolved via top-bar resolver badge (line 372: `resolverBadgeCount: v2InboxItems.length`) | **DELETE.** Top-bar badge already serves this function. The plan's `V2UnresolvedChip` in the timeline header is a *supplementary* tap target, not a replacement for the badge. |
| `_ProbablePlacePromptCard` (lines 1602–1678) | `!useV2Lane && reviewEvent != null && reviewHints.isNotEmpty` (lines 271–274). `reviewHints` always empty in V2 (line 243). All action handlers are V1 stubs. | Dead — V2 resolver replaces this entirely via inbox in editor | **DELETE.** No V3 replacement. (The plan called for "inline prompt anchored to event pin via callout" — that's only valuable if there's a real ambiguity surface. V2 already handles this in editor inbox.) |

**Update to plan:** the original plan said `_UnresolvedCaptureBanner` and `_ProbablePlacePromptCard` need V3 replacements. **They don't.** V2 already moved both functions elsewhere (top-bar badge + editor inbox). All 3 banners can be straight-deleted in Phase 6 cleanup. The new `V2UnresolvedChip` in the timeline header is still a worthwhile add (visible secondary signal when bottom sheet is expanded) but it's enhancement, not regression-prevention.

---

## 5. Repository write-method audit

The read-first rule is more conservative than expected. Several actions don't have backing repo methods at all.

### `LiveCaptureJournalRepository` / `V2EventJournalRepository`
- `updateEvent(eventId, ...)` for editing note/warn/geotag *content* — **❌ does not exist.** Payload is immutable post-creation. Closest: `V2EventJournalRepository.updateResolverOutcome()` (event_journal_repository.dart:99–125) updates resolver state + place bindings only.
- `deleteEvent(eventId)` — **❌ does not exist.**
- `addNote` / `addWarn` / `addGeotag` — **partial.** Only generic `createEventNow()` (line 75) accepting an `eventType` enum. Used as-is.

### Media (`MediaDao`)
- `insertMedia()` — ✅ media_dao.dart:15
- `updateCaption(mediaId, caption)` — **❌ does not exist.** No caption field on the media table at all. (Side note: this means the F2 spec for editable caption was based on a wrong assumption — there's no caption to edit.)
- `deleteMedia(mediaId)` — ✅ media_dao.dart:19; soft-delete also at :22
- `attachToPlace(mediaId, placeId)` — **❌ on MediaDao.** Available via `MediaAttachmentsDao.insertAttachment()` (line 13) + `listForTarget(targetKind='trip_place', targetLocalId)` (line 50)
- "Share via system" — not a repo method; platform channel call from UI layer.

### `PlaceRepository` (create/data/place_repository.dart)
- `addPlaceToTrip(tripId, placeId)` — partial. `addPlace(place)` (line 42) creates a new place inside a trip. No "save existing place to plan" flow.
- `removePlaceFromTrip(tripId, placeId)` — ✅ via `deletePlace(id)` (line 68)
- `getPlace(id)` — ✅ line 37
- "Get attached photos for a place" — **❌ no direct method.** Compose via `MediaAttachmentsDao.listForTarget` + `MediaDao.listByIds`.
- "Get attached notes for a place via `place_bind_id`" — **❌ no direct method.** Compose via `EventJournalRepository.listEventsForTrip()` + client-side filter on `placeBindId`.

### Action button decisions for Phase 2 (read-first rule applied)

| Detail type | Action | Repo support? | Phase 2 decision |
|---|---|---|---|
| `CapturedMediaDetail` | Open in Maps | platform channel | ✅ ship in v1 |
| `CapturedMediaDetail` | Share via system | platform channel | ✅ ship in v1 |
| `CapturedMediaDetail` | Edit caption | ❌ no field | **omit v1** (caption doesn't exist on schema) |
| `CapturedMediaDetail` | Attach to place | partial (via MediaAttachmentsDao composition) | **omit v1** — needs UX for place-picker, defer |
| `CapturedMediaDetail` | Delete | ✅ MediaDao.deleteMedia / softDelete | ✅ ship in v1 |
| `EventDetail` | Open in Maps | platform channel | ✅ ship in v1 |
| `EventDetail` | Edit | ❌ payload immutable | **omit v1** |
| `EventDetail` | Delete | ❌ no method | **omit v1** (read-only) |
| `PlaceDetail` | Open in Maps | platform channel | ✅ ship in v1 |
| `PlaceDetail` | Add to plan | partial | **omit v1** (no clean primitive) |
| `PlaceDetail` | Remove from trip | ✅ via deletePlace | ✅ ship in v1 |

**Net Phase 2 scope:** detail screens are **mostly read-only.** Delete is available for media + place. Open in Maps + Share are platform-channel calls, no repo dependency. Everything else is omitted v1 and deferred to a follow-up sprint that adds `updateEventPayload`, `mediaCaption` schema field, and a real "save existing place to plan" path.

---

## 6. Coords data audit

The null-island filter is **only required for vault-origin media**. Other paths reject inserts when GPS is unavailable.

### `EventJournal` (note/warn/geotag captures)
- Schema: `latitude` and `longitude` are **non-nullable** (`event_journal_table.dart:29–30`).
- Insert paths (`live_capture_journal_repository.dart`):
  - `createEventNow()` (lines 75–116) and `createMediaCaptureNow()` (lines 118–224) both throw `V2LiveCaptureWriteException(code: 'location_unavailable')` if lat/lng is null (lines 84, 129).
  - GPS acquisition uses a 10-second timeout with last-known-position fallback (`camera_capture_controller.dart:121–125`).
- **Result: no EventJournal row exists with NULL or (0, 0) coords.** Trustworthy for direct map rendering. Null-island filter still added as defense-in-depth (cheap).

### `MediaFile` (Drift `media` table)
- Schema: `latitude` and `longitude` are **nullable** (`media_table.dart:42–43`).
- Two insert paths:
  - **Trip-attached** (`camera_capture_controller.dart:214–263`) — calls journal repo's `createMediaCaptureNow()` which enforces the null check. Trustworthy.
  - **Vault** (`camera_capture_controller.dart:265–307`) — inserts directly to `MediaDao` with `Value(latitude)` and `Value(longitude)` (lines 291–292), **no null check.** Vault rows can have NULL coords.
- **Result: vault-origin media may have NULL coords.** Filter is **required**, not just defense-in-depth.

### Provider filter spec (`tripCapturedMediaProvider`)

Query needs to filter by both:
1. `originScope` — only `live_capture` (or `live_capture` + any other live-tracking scope; vault-only media is out of scope for the live screen)
2. `latitude IS NOT NULL AND longitude IS NOT NULL AND NOT (latitude = 0 AND longitude = 0)`

The `originScope` filter actually does most of the work — vault-origin media wouldn't be relevant to a live trip's map anyway. The lat/lng filter is then strictly defense-in-depth for live-capture scope.

---

## Net Phase 0 outcome

| Audit | Result |
|---|---|
| Mapbox 2.18.0 APIs | ✅ all required APIs present, fallback paths documented |
| Feature flag | ✅ added (`enableLiveScreenV3`, default false) |
| Pubspec / typography | ✅ no `google_fonts`, no `battery_plus`; use existing app font; drop battery suggester |
| V1 banner audit | ✅ all 3 banners safe to delete; **no V3 replacements needed** (revision to plan) |
| Repository write methods | ✅ enumerated; **most edit/delete actions omitted from v1** detail sheets per read-first rule |
| Coords data audit | ✅ EventJournal trustworthy; Media `originScope` filter is the primary gate, lat/lng filter is defense-in-depth |

**Plan adjustments based on audit findings (to be reflected in execution):**
1. `V2UnresolvedChip` in timeline header is enhancement only, not banner replacement
2. `CapturedMediaDetail` has NO editable caption field (schema doesn't carry one) — adjust UI spec
3. Phase 2 detail sheets are largely read-only with Delete + Open in Maps + Share as the only universal actions
4. Provider filter primary gate is `originScope = 'live_capture'`, lat/lng null-island check is secondary safety net


---

## 7. Notes for future agents

- This sprint adds **zero backend changes**. All data dependencies (event lat/lng, media place_lat/place_lng, advisory display_kind) are already on the wire.
- Phase 5 (cinematic mode) is **MVP-cuttable**. Phases 1–4 are the true MVP.
- Feature flag `FeatureFlags.enableLiveScreenV3` defaults `false` even after sprint completion. Production rollout via the same env mechanism the app uses for other flags — not a hardcoded default change.
- No-coords invariant: providers MUST filter rows where `latitude IS NULL OR longitude IS NULL OR (latitude = 0 AND longitude = 0)` before emitting GeoJSON. This is the null-island guard.
