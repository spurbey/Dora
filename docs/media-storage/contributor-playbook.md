# Contributor Playbook

## Purpose

This playbook is the operational checklist for changing the media/camera/vault/stories system without causing lane regressions.

## Change categories

1. Flutter local schema changes (`media`, `media_attachments`, local `stories`)
2. Backend stories schema/API changes
3. Camera runtime behavior changes
4. Vault/filter/viewer behavior changes
5. OpenAPI contract changes

Handle them in that order when one change spans multiple layers.

## Mandatory guardrails

1. Do not hand-edit generated files:
   - `flutter/packages/dora_api/**`
   - Drift-generated `*.g.dart`
2. Keep lane separation:
   - Place-review uploads use queue worker
   - Live-capture uploads use V2 session commit
   - Story publish uses stories API directly
3. Preserve local-first behavior:
   - Capture persists locally first
   - Publish/network failure must not drop local media

## Flutter schema change workflow (Drift)

1. Update table/DAO files under:
   - `flutter/lib/core/storage/tables/`
   - `flutter/lib/core/storage/daos/`
2. Bump `schemaVersion` in `flutter/lib/core/storage/drift_database.dart`
3. Add migration block in `onUpgrade`
4. Regenerate Drift code:

```powershell
cd flutter
dart run build_runner build --delete-conflicting-outputs
```

5. Verify all affected DAOs/providers compile against regenerated types.

## Backend schema change workflow (Alembic)

1. Add/adjust SQLAlchemy model(s)
2. Create Alembic revision in `backend/alembic/versions/`
3. Apply migration locally from backend venv:

```powershell
cd backend
.\venv\Scripts\Activate
alembic upgrade head
```

4. Verify health:

```powershell
alembic current
alembic heads
```

## OpenAPI regeneration workflow (required on API contract change)

If backend request/response models or routes change, regenerate `dora_api`:

```powershell
# from repo root with backend serving latest OpenAPI
curl http://localhost:8000/openapi.json -o flutter/openapi.json

cd flutter
npx @openapitools/openapi-generator-cli generate -c openapi-generator-config.yaml
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Then:

1. Update Flutter wrapper call sites (for example `features/stories/data/stories_api.dart`)
2. Bump `flutter/packages/dora_api/pubspec.yaml` version if generated output changed

## Targeted verification matrix

## Backend stories

- `backend/tests/test_stories_endpoints.py`
- Validate publish limits, idempotency, feed ordering/filtering, mute/report/delete/moderation-hide, retention logic

## Flutter stories/vault/capture

- Stories feed + publish providers:
  - `flutter/lib/features/stories/presentation/providers/stories_providers.dart`
- Camera runtime + orchestrator:
  - `flutter/lib/features/capture/presentation/screens/camera_runtime_screen.dart`
  - `flutter/lib/features/capture/domain/capture_orchestrator.dart`
- Vault providers/widgets:
  - `flutter/lib/features/vault/presentation/providers/vault_provider.dart`
  - `flutter/lib/features/vault/presentation/widgets/vault_map.dart`
  - `flutter/lib/features/vault/presentation/widgets/vault_carousel.dart`

## Regression hotspots (check every time)

1. Trip publish enqueues only place-review media, never pure live-capture items.
2. Resolver mirror attachment only for `trip_place_local` bindings.
3. Story publish failure keeps:
   - media row
   - live event attachment (if active session)
   - retryable local story row
4. Camera resume fallback still forces tier-3 reset on broken resume probe.
5. Vault map <-> carousel two-way binding still works after filter changes.

## Definition of done

A change is complete only when:

1. Schema and migration history are updated in both code and docs.
2. OpenAPI + generated Flutter client are regenerated when needed.
3. Lane contracts above remain true.
4. Product states are testable in UI:
   - Capture to Vault
   - Capture during active trip
   - Story publish success/failure + retry/delete

