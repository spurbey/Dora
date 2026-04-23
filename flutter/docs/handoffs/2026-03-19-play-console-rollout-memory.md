# Play Console Rollout Memory (2026-03-19)

Owner: `sumit`  
Context: Android first release via Google Play Closed Testing, Shorebird-enabled build pipeline.

---

## 1) Canonical Release Identity

- App package: `com.dora.travel`
- App name in Play Console: `Dora: Travel Social Explore`
- App type: `App`
- Monetization at creation: `Free`
- Default language: `en-US`
- Legal base URL: `https://doratravelapp.netlify.app`

---

## 2) Build/Release Events Already Completed

### 2.1 Build pipeline and signing

- GitHub Actions workflow used: `.github/workflows/flutter-build.yml`
- Shorebird setup path is active in workflow.
- Keystore secrets wired in Actions (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`).

### 2.2 Key commits during rollout

- `8b8da96` `chore(mobile): upgrade sentry sdk for release compatibility`
  - Upgraded Sentry to resolve Android 16 KB page-size compatibility blocker seen in Play bundle explorer.
- `281afdc` `chore(mobile): bump version for shorebird release`
  - Version moved from `1.0.0+1` to `1.0.1+2` after Shorebird rejected duplicate release version.

### 2.3 AAB upload state

- Closed testing bundle uploaded: `App bundle: 2 (1.0.1)`.
- Play bundle details now show: `Memory page size: Supports 16 KB` (previous blocker resolved).

---

## 3) Play Console Declarations/Selections Made

## 3.1 App Access

- App is treated as restricted access (login required for full functionality).
- Reviewer access credentials/instructions flow has been handled in Play setup process.

## 3.2 Ads declaration

- Ads declaration was discussed and used as a release blocker gate item.
- Keep declaration aligned with actual shipped behavior for each release:
  - If no user-facing ads in current release: declare no ads.
  - If ads are active in current release: declare ads.

## 3.3 Content Rating (IARC)

- Questionnaire completed.
- Result shown in console: generally `12+ / Teen` class ratings across regions.

## 3.4 Target audience and content

- Selected age groups include:
  - `13-15`
  - `16-17`
  - `18+`

## 3.5 Data Safety (current submitted shape)

Current submission indicates:

- Data shared with third parties: `No data shared with third parties`
- Data collected:
  - Personal info: Name, Email address, User IDs
  - Location: Approximate location
  - Photos and videos: Photos
  - App info/performance: Crash logs, Diagnostics
  - App activity: App interactions, In-app search history, Other user-generated content, Other actions
  - Device or other IDs
- Security practice: `Data is encrypted in transit`
- Account deletion URL set: `https://doratravelapp.netlify.app/delete_account.html`
- Privacy policy URL set: `https://doratravelapp.netlify.app/privacy_policy.html`

Important note for future agents:
- Keep this declaration strictly synced with actual runtime SDK/data behavior.
- If telemetry/ads/data collection changes, update Data Safety before rollout.

## 3.6 Photo/Video permission declaration

- Play required photo/video permission justification due `READ_MEDIA_IMAGES`.
- Submitted rationale (short form):
  - Users select and upload travel photos for trips/places/profile images.
  - App reads only user-selected images, not background scanning.

## 3.7 App Content pending/blocked items seen

- `Advertising ID` declaration appeared as required.
- `Health apps` declaration appeared as required.

These must stay completed and accurate before each review submission.

---

## 4) Export Feature Incident During Internal Test

## 4.1 Symptom

- Internal Play build showed:
  - Exports entry not visible in Trips header
  - `Export is not enabled yet.` toast on export action

## 4.2 Root cause found in code

- Export is feature-flag gated by `FeatureFlags.enableExport`.
- Production defaults to export disabled unless Remote Config enables it.
- Relevant file: `flutter/lib/core/config/feature_flags.dart`
  - Remote Config key: `enable_export`

## 4.3 Action taken in Firebase

- Firebase Console -> Remote Config (Client) parameter created/updated:
  - key: `enable_export`
  - type: `Boolean`
  - value: `true`
- Changes published in Firebase.

Operational note:
- App fetch interval is 1 hour in code, but reinstall/clear data usually forces fresh fetch on next launch.

---

## 5) What Is Left From This Point

1. Ensure all remaining App Content declarations are complete and accurate each submission:
   - Advertising ID
   - Health apps
2. Finalize closed testing release notes and rollout.
3. Confirm tester opt-in and install path works end-to-end.
4. Re-verify export flow after Remote Config publish in real internal-test install.
5. Keep Data Safety answers synchronized with live SDK behavior before moving tracks (open/production).

---

## 6) Quick Handoff Checklist for Incoming Agent

- Confirm latest uploaded bundle in Play is `1.0.1` and still shows `Supports 16 KB`.
- Confirm `enable_export=true` is published in Firebase Remote Config (correct production project).
- Confirm internal tester can see Exports UI and submit export job.
- Confirm no unresolved red policy blockers in Play Console.
- Confirm release notes, tester group, and rollout state are recorded.
