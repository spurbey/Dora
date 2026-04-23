# Mobile Production Release Runbook

Last Updated: 2026-03-12  
Owner: Mobile Lead + Release Manager  
Scope: Dora Android release to Google Play Closed Testing (first rollout path)

## 1. Canonical Release Values

- Package/bundle ID: `com.dora.travel`
- OAuth mobile callback: `com.dora.travel://login-callback/`
- Legal base URL: `https://doratravelapp.netlify.app`
- Privacy URL: `https://doratravelapp.netlify.app/privacy_policy.html`
- Terms URL: `https://doratravelapp.netlify.app/terms_conditions.html`
- Support URL: `https://doratravelapp.netlify.app/support.html`
- Account deletion URL: `https://doratravelapp.netlify.app/delete_account.html`
- Play first rollout strategy: Closed Testing

## 2. Preflight Checklist (Before Build)

1. Confirm release branch/commit is frozen.
2. Confirm `com.dora.travel` is present in:
   - Android `applicationId` and `namespace`
   - Android manifest deep-link scheme
   - iOS bundle identifier + URL scheme
3. Confirm `flutter/android/app/google-services.json` contains `com.dora.travel`.
4. Confirm Supabase redirect list includes `com.dora.travel://login-callback/`.
5. Confirm Google OAuth callback for Supabase is `https://<project-ref>.supabase.co/auth/v1/callback`.
6. Confirm legal pages are live at Netlify URLs above.
7. Confirm `upload-keystore.jks` exists locally and release signing env vars are available.

## 3. Signed Android AAB Generation

### Local PowerShell build

```powershell
cd C:\Users\sumit\Downloads\Dora\flutter
$env:KEYSTORE_PASSWORD="<keystore_password>"
$env:KEY_ALIAS="upload"
$env:KEY_PASSWORD="<key_password>"
flutter clean
flutter pub get
flutter build appbundle --release --dart-define=ENVIRONMENT=production --dart-define=API_BASE_URL=<prod_api_url> --dart-define=SUPABASE_URL=<supabase_url> --dart-define=SUPABASE_ANON_KEY=<supabase_anon> --dart-define=MAPBOX_TOKEN=<mapbox_token> --dart-define=SENTRY_DSN=<flutter_sentry_dsn>
```

Expected output:
- `flutter/build/app/outputs/bundle/release/app-release.aab`

### CI build path

- Use `.github/workflows/flutter-build.yml`.
- Ensure GitHub secrets exist:
  - `KEYSTORE_BASE64`
  - `KEYSTORE_PASSWORD`
  - `KEY_ALIAS`
  - `KEY_PASSWORD`
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
  - `MAPBOX_TOKEN`
  - `API_BASE_URL`
  - `SENTRY_DSN_FLUTTER`

## 4. Required Env/Secrets Map

| Secret | Used By | Purpose |
|---|---|---|
| `KEYSTORE_BASE64` | Flutter CI | Decodes release keystore |
| `KEYSTORE_PASSWORD` | Local + CI | Unlocks keystore |
| `KEY_ALIAS` | Local + CI | Selects signing key alias |
| `KEY_PASSWORD` | Local + CI | Unlocks key entry |
| `SUPABASE_URL` | App runtime | Supabase endpoint |
| `SUPABASE_ANON_KEY` | App runtime | Supabase client auth |
| `MAPBOX_TOKEN` | App runtime | Map rendering/token auth |
| `API_BASE_URL` | App runtime | Backend base URL |
| `SENTRY_DSN_FLUTTER` | App runtime | Crash/error telemetry |

## 5. Play Closed Testing Submission Order

1. Open Play Console app.
2. Upload signed `.aab` to Closed Testing track.
3. Fill/confirm in this order:
   - App Access
   - Data Safety
   - App Content declarations
   - Ads declaration
   - Privacy policy URL
4. Add closed tester email list/group.
5. Add release notes.
6. Start closed testing rollout.
7. Save release URL and dashboard screenshots.

## 6. Post-Upload Validation

1. Install from testing track on physical Android device.
2. Validate:
   - Email login/signup/logout
   - Google sign-in callback
   - Trip create/edit/upload
   - Export request/completion/share
   - In-app account deletion
   - Legal links open externally
3. Record evidence:
   - Auth smoke-test video
   - Account deletion smoke-test video
   - Play dashboard screenshots
   - Any crash/error logs

## 7. Rollback Triggers and Actions

Trigger rollback if any of the following occurs after rollout:
- Login failures above acceptable baseline.
- Export completion failures above acceptable baseline.
- Crashes blocking auth/trip/export/delete flow.
- Policy/compliance rejection signal from Play review.

Rollback actions:
1. Pause/stop new rollout on Play Console.
2. Disable risky feature flags (if applicable).
3. Ship fixed build to Closed Testing before wider rollout.
4. Log incident summary and root cause in release notes/docs.

## 8. Owner Checklist

### Founder/Business Owner

1. Approve package/app identity, display name, support email.
2. Approve legal URLs and policy wording.
3. Complete Play declarations and reviewer access details.
4. Decide go/no-go for rollout start.

### Engineering Owner

1. Produce signed AAB and verify integrity.
2. Confirm env/secrets and OAuth callbacks.
3. Execute device smoke tests and capture evidence.
4. Monitor first 24-72 hours and manage rollback if needed.
