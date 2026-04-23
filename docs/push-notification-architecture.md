# Push Notification Architecture

## Purpose
This document captures the current push notification architecture, the recent notification-related changes, and the operational checklist needed to keep push delivery reliable.

## Scope
- Device token lifecycle (register and deactivate).
- Firebase transport configuration and dispatch.
- Advisory push generation and delivery path.
- Push deep-link routing in Flutter.

## Recent Changes
### Backend
- Added v1 notification router registration in FastAPI app boot.
- Added authenticated device token lifecycle endpoints:
  - `POST /api/v1/notifications/device-tokens/register`
  - `POST /api/v1/notifications/device-tokens/deactivate`
- Added strict idempotency for token mutations using `api_idempotency_records`.
- Added deterministic replay semantics:
  - Same idempotency key + same payload -> `200` replay response with `idempotency_replayed=true`.
  - Same idempotency key + different payload -> `409 idempotency_conflict`.
- Added Firebase push env keys in backend config and `.env.example`.

### Flutter
- Added `PushTokenLifecycleBootstrap` to keep backend token state in sync with:
  - auth sign-in/sign-out transitions,
  - app resume,
  - FCM token refresh events.
- Added a logout deactivation hardening in `DioLiveTrackingApi`:
  - deactivate call can reuse last known bearer header if auth provider already cleared token.
- Added advisory-specific deep-link routing:
  - advisory pushes route to live capture with side panel open.
  - advisory payload with `advisory_id` focuses that advisory in UI.
- Added tests covering token lifecycle, auth-header fallback, and advisory deep-link route behavior.

## End-to-End Architecture

### 1) Client Token Sync Path
1. App starts and Riverpod bootstraps `PushTokenLifecycleBootstrap`.
2. If user is signed in, client requests notification permission from Firebase Messaging.
3. Client obtains current FCM token.
4. Client calls `POST /api/v1/notifications/device-tokens/register` with:
   - `Idempotency-Key` header,
   - `client_event_id`,
   - `platform`, `push_token`, `seen_at`, optional metadata.
5. Backend upserts `user_device_tokens` row by `push_token` and marks it active.
6. On FCM token refresh or app resume, register is called again.

### 2) Logout Deactivation Path
1. Auth state transitions to signed-out.
2. Bootstrap drains any in-flight register operation.
3. Client calls `POST /api/v1/notifications/device-tokens/deactivate`.
4. Deactivate call uses cached auth header fallback when auth provider already cleared token.
5. Backend marks token inactive for the current authenticated user.

### 3) Advisory Dispatch Path
1. Advisory worker creates advisory candidates.
2. Push-eligible advisory calls `PushNotificationService.send_advisory_notification`.
3. Service enforces per-user throttle via advisory cache.
4. Service resolves active tokens from `user_device_tokens`.
5. Service initializes Firebase Admin app from env credentials.
6. Service sends FCM notification + data payload (`type`, `trip_id`, `advisory_id`, `category`, `action`).
7. Service updates token state:
   - success -> reset failure count and timestamps,
   - invalid token error -> deactivate token (`is_active=false`),
   - retryable errors -> status reflects retryable failure.

### 4) Notification Tap Deep Link Path
1. Flutter receives opened push payload (`getInitialMessage` or `onMessageOpenedApp`).
2. `LiveTrackingDeepLinkBootstrap` deduplicates by `message_id`/`notification_id`.
3. For advisory types (`advisory`, `advisory_paused`, `advisory_clarifying`):
4. Resolve local trip id, then navigate to:
   - `/trips/{localTripId}/live?advisoryFocus={advisory_id}&openSidePanel=1`, or
   - `/trips/{localTripId}/live?openSidePanel=1`.
5. For non-advisory payloads, route by session state to live/editor.

## API Contract

### Register Token
- Endpoint: `POST /api/v1/notifications/device-tokens/register`
- Auth: required.
- Headers:
  - `Idempotency-Key` required.
  - `X-Idempotency-Key` accepted as legacy fallback.
- Request fields:
  - `client_event_id` (required)
  - `platform` (`ios|android|web`)
  - `push_token`
  - `seen_at` (optional, server defaults now)
  - `device_id`, `app_version`, `locale` (optional)
- Response:
  - `token` object (or null),
  - `idempotency_replayed` boolean.

### Deactivate Token
- Endpoint: `POST /api/v1/notifications/device-tokens/deactivate`
- Auth: required.
- Headers:
  - `Idempotency-Key` required.
  - `X-Idempotency-Key` accepted as legacy fallback.
- Request fields:
  - `client_event_id` (required)
  - `push_token`
  - `deactivated_at` (optional, server defaults now)
- Response:
  - `token` object when found, `null` when no matching token for user,
  - `idempotency_replayed` boolean.

## Data Model

### `user_device_tokens`
- One row per unique `push_token` (global unique constraint).
- Ownership can move to a new user on re-register.
- Tracks platform, device metadata, `is_active`, `last_seen_at`, `last_sent_at`, `failure_count`.

### `api_idempotency_records`
- Keyed by unique tuple: `(user_id, endpoint_signature, idempotency_key)`.
- Stores request hash + original response payload/status.
- TTL window: 72 hours.
- Replay increments `replay_count`.

## Configuration

### Backend Environment
- `FIREBASE_PUSH_ENABLED` (must be `true` for real delivery).
- `FIREBASE_PROJECT_ID`.
- One credential source:
  - `FIREBASE_CREDENTIALS_JSON`, or
  - `FIREBASE_CREDENTIALS_PATH`.

### Runtime Notes
- Local docker compose (`docker-compose.dev.yml`) loads `backend/.env` for API and workers.
- Deployed environments (for example Coolify) need the same Firebase vars in deployment env settings.
- If env is missing or invalid, push service returns `transport_unavailable` with `firebase transport not configured`.

## Failure Modes and Quick Diagnosis
- `POST /api/v1/notifications/device-tokens/register` returns `404`:
  - backend deploy is stale or notifications router is not included.
- Register/deactivate returns `400 invalid_payload`:
  - missing `Idempotency-Key`.
- Register/deactivate returns `409 idempotency_conflict`:
  - same idempotency key reused with different payload.
- Advisory worker logs `firebase transport not configured`:
  - `FIREBASE_PUSH_ENABLED=false` or missing credentials/project id.
- No push on logout cleanup:
  - check deactivate call auth; cached header fallback is best-effort only.

## Validation Checklist
1. Login on device and grant push permission.
2. Confirm backend logs show `POST /api/v1/notifications/device-tokens/register` as `200`.
3. Confirm token row exists and `is_active=true` in `user_device_tokens`.
4. Logout and confirm deactivate call hits `200` and token becomes inactive.
5. Trigger advisory push path and verify worker logs a send status (`sent`/`throttled`/other explicit status).
6. Tap advisory notification and verify live route opens with side panel query params.

## Code Map
- Backend API routes: `backend/app/api/v1/notifications.py`
- Backend schema contract: `backend/app/schemas/notification_token.py`
- Backend token model: `backend/app/models/user_device_token.py`
- Backend idempotency model: `backend/app/models/api_idempotency_record.py`
- Backend push service: `backend/app/services/push_service.py`
- Advisory worker integration: `backend/app/workers/advisory_worker.py`
- App router registration: `backend/app/main.py`
- Flutter API client bridge: `flutter/lib/core/network/live_tracking_api.dart`
- Flutter token lifecycle bootstrap: `flutter/lib/core/notifications/push_token_lifecycle_bootstrap.dart`
- Flutter deep-link bootstrap: `flutter/lib/core/notifications/live_tracking_deep_link_bootstrap.dart`
- Flutter bootstrap providers: `flutter/lib/core/notifications/push_token_lifecycle_provider.dart`, `flutter/lib/core/notifications/live_tracking_deep_link_provider.dart`
- Tests: `backend/tests/test_notification_device_tokens.py`, `flutter/test/core/network/live_tracking_api_test.dart`, `flutter/test/core/notifications/push_token_lifecycle_bootstrap_test.dart`, `flutter/test/core/notifications/live_tracking_deep_link_bootstrap_test.dart`
