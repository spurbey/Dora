# Vault Product Surface

## Scope

Vault is the local-first media experience for all captured media across lanes. It includes:

- Full-screen map + carousel view
- Time and radius filtering
- Story draft/publish management section

Core files:

- Full screen: `flutter/lib/features/vault/presentation/screens/vault_screen.dart`
- Profile entry tab: `flutter/lib/features/vault/presentation/screens/vault_tab.dart`
- Providers: `flutter/lib/features/vault/presentation/providers/vault_provider.dart`
- Map: `flutter/lib/features/vault/presentation/widgets/vault_map.dart`
- Carousel: `flutter/lib/features/vault/presentation/widgets/vault_carousel.dart`
- Filter bar: `flutter/lib/features/vault/presentation/widgets/vault_filter_bar.dart`
- Marker renderer/provider:
  - `flutter/lib/features/vault/presentation/utils/thumbnail_marker_renderer.dart`
  - `flutter/lib/features/vault/presentation/providers/vault_marker_provider.dart`

## Entry and navigation

1. Bottom navigation keeps `Profile` as tab.
2. Profile has a `Vault` sub-tab.
3. Vault sub-tab opens full-screen Vault via `Routes.vault`.

## Data source

- `vaultAllMediaProvider` streams all non-deleted media owned by current user (`media.ownerUserId`).
- No lane filtering by default; editor/live/vault origin all appear.

Current signed-out behavior:

- Shows empty sign-in state; no media queries executed.

## Filtering

Filter model:

- Time bucket: `Day | Week | Month | Year`
- Radius bucket: `1km | 5km | 25km | All`

Current radius center:

- User current location, not map center.
- If location permission is unavailable, radius controls are replaced by an enable-location prompt.

Provider flow:

1. `vaultFilterProvider` stores selected time/radius
2. `vaultLocationProvider` stores permission + current position
3. `vaultFilteredMediaProvider` applies in-memory filtering
4. `vaultGeotaggedMediaProvider` keeps map-eligible rows

## Map <-> carousel binding

Shared selection state:

- `vaultSelectedMediaIdProvider`

Two-way behavior:

1. Map marker tap sets selected media id.
2. Carousel listens and animates to selected media.
3. Carousel swipe updates selected media id.
4. Map listens and flies camera to selected item coordinates.

This is the main "hero interaction" contract. Preserve it when changing either widget.

## Marker rendering pipeline

Flow:

1. For each geotagged item, choose image source (`thumbnailLocalPath` then `localUri`)
2. Render marker bitmap with `ThumbnailMarkerRenderer`
3. Cache marker bytes in notifier state and bind to map marker icon bytes
4. If only full-size source exists, generate thumbnail asynchronously and update `media.thumbnailLocalPath`

Marker provider:

- `vaultMarkerControllerProvider`

## Vault story section

Rendered at bottom of Vault screen from `vaultStoryItemsProvider`.

Statuses shown:

- `draft`
- `publishing`
- `failed`
- `published`
- `expired`

Actions:

- `Publish` for `draft|failed` (calls `publishLocalStory`)
- `Delete` for non-publishing states (local delete for local states, server delete for remote states)

Remote delete path:

- For `published|expired|moderation_hidden|deleted` with `serverId`, call backend `DELETE /api/v1/stories/{story_id}` then mark local as deleted.

## UX contracts to keep

1. Vault remains useful offline: local media and local stories still visible.
2. Story publish failure does not remove media; failed drafts remain retryable from Vault.
3. Non-geotagged media should still appear in Vault list/carousel; only map excludes them.
4. Radius filter with active radius should exclude items missing coordinates.

## Known gaps and extension points

1. Radius is location-centered today. If map-center radius is required, change filter geometry in `vault_provider.dart` and update UX copy.
2. Story cards are in the same screen column as map/carousel. If moved to a separate tab/section, keep `vaultStoryItemsProvider` and publish/delete semantics unchanged.
3. If adding clustering/advanced map styling, keep selected-id synchronization contract untouched.

