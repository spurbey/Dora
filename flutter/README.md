# Dora Flutter App

Primary mobile client for Dora (offline-first architecture, Supabase auth, Mapbox editor flows, export studio/history surfaces).

## Current State (2026-03-16)

- Feature modules for auth, feed/search, create/editor, trips, profile, and export are integrated.
- Export workflow includes:
  - per-trip Export Studio (`/trips/:id/export`)
  - global Export Hub (`/trips/exports`)
  - status polling, cancel, download, and share actions
- Offline sync and media upload workers are active at app bootstrap.
- Recent commits (March 2026) focused on release readiness, navigation UX, route/editor UX, and backend-integration hardening.

## Architecture

### 1) Layering

```text
lib/
  core/       platform/infrastructure (auth, map, network, storage, sync, theme)
  features/   product modules by domain
  shared/     shared widgets/utilities
```

Core patterns:

- State management: Riverpod (`flutter_riverpod`)
- Local persistence: Drift (SQLite), schema version `11`
- API transport: Dio with auth and retry interceptors
- API contract client: generated local package `packages/dora_api`
- Routing: `go_router`
- Auth: `supabase_flutter`
- Maps: `mapbox_maps_flutter` via adapter abstraction

### 2) Offline and Sync

- Drift tables include trips, places, routes, media, public/user trips, sync tasks.
- `EntitySyncWorker` processes queued trip/place/route sync tasks with retry/backoff and dependency ordering.
- `UploadQueueWorker` handles media queue lifecycle (compress, upload, retry, state updates).
- Both workers are bootstrapped on app startup via providers.

### 3) Export Module

Main files:

- Data: `lib/features/export/data/export_repository.dart`
- Domain: `lib/features/export/domain/*`
- UI/providers: `lib/features/export/presentation/*`

Key behavior:

- Local pre-submit guards validate sync/media readiness before create-export call.
- Uses backend export endpoints:
  - `POST /api/v1/trips/{trip_id}/export`
  - `GET /api/v1/exports`
  - `GET /api/v1/exports/{job_id}`
  - `POST /api/v1/exports/{job_id}/cancel`
  - `GET /api/v1/exports/{job_id}/download-url`
  - `GET /api/v1/exports/{job_id}/share`

### 4) Navigation

Primary routes are defined in `lib/core/navigation/routes.dart`:

- Tabs/shell: `/feed`, `/create`, `/trips`, `/profile`
- Auth: `/login`, `/signup`
- Editor flow: `/trips/:id/edit`, place/city search, media upload
- Export: `/trips/:id/export`, `/trips/exports`

## Environment and Configuration

Runtime config is injected through Dart defines (`String.fromEnvironment` in `lib/core/config/env_config.dart`).

Required keys:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `MAPBOX_TOKEN`
- `API_BASE_URL`
- `SENTRY_DSN`
- `ENVIRONMENT` (`development|staging|production`)

Optional feature-flag overrides:

- `ENABLE_EXPORT=true|false|auto`
- `ENABLE_ROUTE_DRAWING=true|false|auto`

Prepare env file:

```powershell
copy .env.example .env
```

Important: clean `.env.example` values before use. Keep `API_BASE_URL` as a single valid URL (no inline comments).

## Local Development

### Prerequisites

- Flutter SDK 3.27.x (CI uses 3.27.4)
- Dart 3.x
- Android/iOS toolchains via `flutter doctor`
- Backend API running (default expected at `http://localhost:8000`)

### Install and generate

```bash
cd flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Run app

```bash
flutter run --dart-define-from-file=.env
```

Notes:

- Android emulator localhost rewrite is handled in `ApiClient` (`localhost` -> `10.0.2.2`).
- Mapbox token must be set for map rendering.
- Supabase auth callback for Google sign-in is hardcoded as `com.dora.travel://login-callback/`.

## Build and Release

Production AAB example:

```bash
flutter build appbundle \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.dora.app \
  --dart-define=SENTRY_DSN=<flutter-sentry-dsn> \
  --dart-define=SUPABASE_URL=<supabase-url> \
  --dart-define=SUPABASE_ANON_KEY=<supabase-anon-key> \
  --dart-define=MAPBOX_TOKEN=<mapbox-token>
```

Release references:

- Runbook: `docs/ops/mobile-production-release-runbook.md`
- Readiness checklist: `docs/ops/release-readiness-checklist.md`
- CI build workflow: `../.github/workflows/flutter-build.yml`

## OpenAPI Client Workflow (`dora_api`)

Current canonical path:

- package location: `packages/dora_api`
- generator config: `openapi-generator-config.yaml`
- generator version config: `openapitools.json`

Regeneration flow:

```bash
# from repo root, with backend running
curl http://localhost:8000/openapi.json -o flutter/openapi.json

cd flutter
npx @openapitools/openapi-generator-cli generate -c openapi-generator-config.yaml
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

If the generated API changes, bump `packages/dora_api/pubspec.yaml` version.

## Testing and Quality

Run full checks:

```bash
flutter analyze --no-pub
flutter test
```

Useful targeted runs:

```bash
flutter test test/core/sync/entity_sync_worker_test.dart
flutter test test/features/create/media_upload_integration_test.dart
flutter test test/features/export/export_repository_precheck_test.dart
```

## Documentation Precedence (stale-conflict policy)

Use this order when docs disagree:

1. Code under `lib/` and tests under `test/`
2. Newer Phase 6 and ops docs (March 2026), especially:
   - `docs/handoffs/phase6e-nav-ux-changelog.md` (2026-03-15)
   - `docs/handoffs/phase6e-export-hub-memory.md` (2026-03-15)
   - `docs/ops/mobile-production-release-runbook.md` (2026-03-12)
   - `docs/ops/release-readiness-checklist.md` (2026-03-12)
   - `docs/phases/Phase-6-PRD.md` and `Phase-6-Execution-Checklist.md` (2026-03-08)
3. Older architecture notes (`docs/architecture.md`, `docs/rules.md`) as historical guidance only

Known stale pattern to ignore:

- Older docs that reference generated API under `lib/generated/api/`; current project uses `packages/dora_api`.

## Sentry Verification

Sentry is initialized in `lib/main.dart`. After a production build, trigger one controlled exception on a test device and confirm it appears in the configured Sentry project.
