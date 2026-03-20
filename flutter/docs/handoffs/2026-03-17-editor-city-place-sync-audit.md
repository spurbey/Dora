# Editor City/Place + Sync Audit (2026-03-17)

## Context
- Requested focus:
  - Add City / Add Place flow consistency
  - Media attachment availability during/after add flow
  - Sync safety (avoid regressions and retry storms)
  - Cross-check backend support vs current frontend behavior

## What Was Observed

### 1) Add flow UX is inconsistent
- `PlaceSearchScreen` uses a modern card-based, animated UX.
- `CitySearchScreen` is still a simpler list-based UI with older interaction style.
- Result: switching between "add city" and "add place" feels like different products.

Evidence:
- `flutter/lib/features/create/presentation/screens/place_search_screen.dart`
- `flutter/lib/features/create/presentation/screens/city_search_screen.dart`

### 2) Add Place flow has no direct "attach media now" branch
- After adding from search, flow returns to editor immediately.
- Media can be added later from details, but not as an explicit step in add flow.

Evidence:
- `flutter/lib/features/create/presentation/screens/place_search_screen.dart:54`
- `flutter/lib/features/create/presentation/screens/editor_screen.dart:787`

### 3) City details path does not expose media actions
- Editor routes city selection to `CityDetailForm`, which lacks media manage/view actions.
- Backend media upload is place-id based (`trip_place_id`) and can support city entries as well.

Evidence:
- `flutter/lib/features/create/presentation/screens/editor_screen.dart:776`
- `flutter/lib/features/create/presentation/widgets/city_detail_form.dart`
- `backend/app/api/v1/media.py:30`

### 4) Backend-supported place classification is not fully used on add
- Search result includes `category`.
- `createFromSearchResult` does not map `category -> placeType`.
- Backend supports `place_type` in create/update.

Evidence:
- `flutter/lib/features/feed/data/models/place_search_result.dart:11`
- `flutter/lib/features/create/data/place_repository.dart:138`
- `backend/app/schemas/place.py:35`

### 5) Sync behavior can cause high redundant traffic
- Every edit schedules auto-save in 30s.
- Auto-save currently calls `savePlaces(current.places)`, which marks all places pending and enqueues place sync tasks for all places.
- This amplifies retries when backend has intermittent errors.

Evidence:
- `flutter/lib/features/create/presentation/providers/editor_provider.dart:927`
- `flutter/lib/features/create/presentation/providers/editor_provider.dart:919`
- `flutter/lib/features/create/data/place_repository.dart:109`
- `flutter/lib/features/create/data/place_repository.dart:127`

### 6) Deploy log check (requested)
- City/place creation sequence is successful in the latest log window:
  - `POST /api/v1/places` -> `201`
  - `PATCH /api/v1/places/{id}` -> `200`
- Separate intermittent backend error found:
  - `GET /api/v1/trips` -> `500`
  - Cause: `duplicate key value violates unique constraint "users_pkey"` during user auto-create in auth dependency.

Evidence:
- `deploy_logs.txt:298`
- `deploy_logs.txt:299`
- `deploy_logs.txt:116`
- `deploy_logs.txt:237`
- `backend/app/dependencies.py:127`

## Plan of Action

### Phase 1: Sync-safe behavior first (risk control)
1. Stop bulk place re-queueing on timed save.
2. Keep immediate per-entity writes for add/update/delete.
3. Persist reorder changes without full `savePlaces` re-enqueue.
4. Preserve current retry policy behavior unless explicitly changed.

### Phase 2: Backend contract alignment
1. Map search `category` into place `placeType` for create flow.
2. Keep payloads consistent with backend-supported fields without changing existing API shape.

### Phase 3: UI/UX consistency and media flow
1. Bring city add screen visual language in line with place add screen.
2. Add explicit add-path option to attach media immediately after adding a place.
3. Ensure city detail path exposes media management access (same editor flow expectations).

### Phase 4: Validation
1. Verify add city, add place, attach media, and return-to-editor flow.
2. Verify sync queue behavior after edits/reorder (no all-place flood from timer).
3. Confirm no dependency break in map/editor/providers.

## Safety Notes
- No schema migration is required for the planned frontend changes.
- Backend race condition in `get_current_user` is separate but should be fixed to avoid random `500` on concurrent startup requests.
- Keep commit scope focused to editor/create flow + minimal backend reliability fix only if approved.
