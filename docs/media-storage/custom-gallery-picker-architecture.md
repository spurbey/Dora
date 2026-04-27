# Custom Gallery Picker Architecture (Android-First)

## Summary

This document defines the gallery picker architecture used by Dora media flows where users currently see generic system "Files" UI instead of a media-native gallery experience.

Decision lock:

1. Android-first custom picker implementation.
2. Shared picker path reused across camera runtime and trip media upload.
3. Story publish remains single-file.
4. Trip-side multi-photo selection remains capped at 10.

## Problem and Why System Picker Feels Wrong

Current gallery selection uses `image_picker` system intents in multiple places. On many Android devices this routes users to a generic file chooser, not a visual media browser with albums/folders and fast thumbnail grid interaction.

Observed impact:

1. Picker UX inconsistency across devices and OEMs.
2. Higher friction for rapid media selection.
3. Limited control over album navigation, selection affordances, and permission recovery states.

## Final Architecture Decision

Android uses `insta_assets_picker` as the gallery engine wrapped by one shared app contract. iOS remains on existing `image_picker` flow for this phase.

Core design:

1. One shared request/response contract for gallery selection.
2. One reusable picker surface (screen) for Android.
3. Existing downstream persistence contracts remain unchanged.

No backend/API contract changes are introduced.

## Shared Picker Contract

Internal request type (`GalleryPickerRequest`) includes:

1. `allowedMedia`: `images`, `videos`, or `imagesAndVideos`.
2. `maxSelection`: selection cap (single-select when `1`).
3. `launchContext`: source context (`fab`, `liveTracking`, `tripUpload`, fallback capture).
4. `preselectedAssetIds`: optional existing selection set.

Internal response type (`GalleryPickerResult`) includes:

1. `assets`: selected entries with
   - local file path,
   - media kind (`photo` or `video`),
   - source asset id.

Contract rules:

1. Empty/cancel returns `null` result.
2. Android selection always returns local file paths for existing assets.
3. Callers treat result as opaque selected media and continue existing persist/upload logic.

## Selection Rules by Product Context

1. Camera runtime, FAB/story flow:
   - photo mode: single image
   - video mode: single video
2. Camera runtime, `liveTracking`:
   - photo mode: multi-image allowed, max 10
   - video mode: single video
   - batch flow is vault/live attach only (no story batch publish)
3. Trip media upload:
   - multi-image allowed, max 10
4. Story publish:
   - still single-file publish only

## Permission Model

Permission semantics remain centralized in `MediaPermissions` and consumed by the picker.

Android picker flow:

1. Check media permission status before loading albums.
2. If denied (not permanent): show in-picker empty state with `Try Again`.
3. If permanently denied: show `Open Settings`.
4. On grant, load albums/assets immediately.

iOS in this phase:

1. Existing `image_picker` + current permission handling remains unchanged.

## Performance Model

Picker performance policy:

1. Paged asset loading from media store (`page` + `size`), not full-library load.
2. Thumbnail-first rendering in grid.
3. Deferred full-resolution file resolve only for selected assets.
4. Lazy load next page when near grid tail.

This keeps large galleries responsive and memory use bounded.

## Failure Modes and Fallbacks

1. Permission denied:
   - show explicit in-picker recovery actions (`Try Again` / `Open Settings`)
2. Album/assets load error:
   - show retry CTA in picker UI
3. Asset file missing/unreadable:
   - skip invalid asset and continue with remaining valid selections
4. Mixed unsupported assets:
   - filter by requested media type; unsupported assets are not selectable

No fallback to backend changes is required.

## Integration Boundaries

Integration points for this architecture:

1. Camera runtime gallery action.
2. Trip media upload gallery action.
3. Legacy capture gallery fallback action.

Non-goals for this phase:

1. iOS custom gallery implementation.
2. Backend stories/media schema changes.
3. Story multi-select publish.
