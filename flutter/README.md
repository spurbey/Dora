# Dora Flutter App

## Environment Setup

Runtime config is injected via Dart defines (read by `String.fromEnvironment` in `lib/core/config/env_config.dart`).

Use the checked-in local env file for development:

```bash
flutter run --dart-define-from-file=.env
```

`.env.example` documents required keys:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `MAPBOX_TOKEN`
- `API_BASE_URL`
- `SENTRY_DSN`
- `ENVIRONMENT`

## Production Build

For production builds, pass production values explicitly:

```bash
flutter build appbundle \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.dora.app \
  --dart-define=SENTRY_DSN=<your-production-sentry-dsn> \
  --dart-define=SUPABASE_URL=<your-production-supabase-url> \
  --dart-define=SUPABASE_ANON_KEY=<your-production-supabase-anon-key> \
  --dart-define=MAPBOX_TOKEN=<your-production-mapbox-token>
```

## Sentry Verification

Sentry is initialized in `lib/main.dart`. After a production build, trigger one intentional exception on a test device and verify the event appears in Sentry.
