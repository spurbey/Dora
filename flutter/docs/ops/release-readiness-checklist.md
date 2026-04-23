# Mobile Release Readiness Checklist

Last Updated: 2026-03-12
Owner: Release Manager + Mobile Lead + Backend Lead
Scope: Dora Android + iOS production release

How to use:
1. Work top to bottom.
2. Do not submit to stores until all required checks are complete.
3. Attach evidence links (screenshots, PRs, console screenshots) for each section.

---

## Current Progress Log (2026-03-12)

Completed in repo:
- Account deletion flow is implemented in-app (Settings > Delete Account) and wired to backend delete endpoint.
- Public legal/support pages are published at `https://doratravelapp.netlify.app/`:
  - `privacy_policy.html`
  - `terms_conditions.html`
  - `support.html`
  - `delete_account.html`
- App legal links are updated to the Netlify URLs.
- Mobile package identity migration is complete for Android + iOS with `com.dora.travel`.
- OAuth deep-link callback migration is complete in app code and manifests: `com.dora.travel://login-callback/`.
- Android release signing config now uses `signingConfigs.release` with keystore/env-based credentials.
- Supabase mobile redirect URL has been updated to `com.dora.travel://login-callback/`.
- Railway backend stack (api, worker, renderer) is deploying and online.

Key remaining release blockers:
- Signed Android `.aab` artifact proof from release signing path is still pending.
- Play Console policy forms/declarations are not completed yet.
- Closed testing rollout evidence (track URL, testers group, rollout start) is still pending.
- Device QA evidence (auth + export + share + delete account) is still pending.
- App Store Connect evidence remains pending if iOS release is included in this cycle.
- Code references for above blockers:
  - `flutter/android/app/build.gradle.kts` (`namespace`, `applicationId`, `signingConfigs.release`)
  - `flutter/android/app/src/main/AndroidManifest.xml` (OAuth deep-link scheme)
  - `flutter/lib/core/auth/auth_service.dart` (`redirectTo`)
  - `flutter/ios/Runner.xcodeproj/project.pbxproj` (bundle identifiers)
  - `flutter/ios/Runner/Info.plist` (URL schemes)
  - `flutter/android/app/google-services.json` (Firebase package name includes `com.dora.travel`)

Reference commits:
- `d2798a3` `feat(account): add in-app account deletion flow and backend endpoint`
- `ad9b0e0` `docs(policy): convert legal/support pages to html`
- `7f9c9b6` `chore(links): point policy and support urls to netlify pages`
- `83b22db` `docs(policy): update internal legal page links to netlify urls`

---

## 0. Go/No-Go Summary

- [ ] Go decision owner assigned
- [ ] Release branch/tag selected
- [ ] Release version finalized (`versionName`, `versionCode`, iOS build number)
- [ ] All blocking items below resolved
- [ ] Final GO sign-off recorded (date + owner)

GO/NO-GO:
- Status: `TBD`
- Date:
- Owner:
- Notes:

---

## 1. Identity and Build Basics

### 1.1 Package/Bundle Identity (must be final, not placeholder)

- [x] Android `applicationId` is final and production-owned (`com.dora.travel`)
- [x] Android `namespace` matches final package structure
- [x] iOS bundle identifier is final for Debug/Release/Profile (`com.dora.travel`)
- [x] Firebase Android config includes final package (`google-services.json` contains `com.dora.travel`)
- [ ] Firebase iOS config alignment verified (`GoogleService-Info.plist` if iOS Firebase is enabled)

Evidence:
- [ ] Screenshot/link: Android `applicationId` + `namespace` in build config
- [ ] Screenshot/link: Android OAuth deep-link scheme in manifest
- [ ] Screenshot/link: iOS `PRODUCT_BUNDLE_IDENTIFIER` values
- [ ] Screenshot/link: Firebase Android app configuration for `com.dora.travel`
- [ ] Screenshot/link: iOS Signing & Capabilities (if iOS release in this cycle)

### 1.2 Signing and Build

- [x] Android release keystore configured
- [x] Android release signing config uses `signingConfigs.release` (not debug signing)
- [ ] Android App Bundle (`.aab`) builds successfully
- [ ] iOS release archive builds successfully in Xcode
- [ ] iOS signing/provisioning profile valid
- [ ] Crash reporting environment tags validated (dev vs prod)

Evidence:
- [ ] Android release build log (local)
- [ ] Android release build log (CI workflow run URL)
- [ ] iOS archive/export log

---

## 2. Authentication and Account Requirements

### 2.1 Core Auth

- [ ] Email/password login works end-to-end
- [ ] Signup works end-to-end
- [ ] Logout works cleanly
- [ ] Expired session handling tested

### 2.2 Google Sign-In (if enabled)

- [ ] Google provider enabled in Supabase (console verification screenshot pending)
- [x] Correct Google OAuth redirect URI configured: `https://<project-ref>.supabase.co/auth/v1/callback`
- [x] Supabase Additional Redirect URLs include mobile callback URI: `com.dora.travel://login-callback/`
- [x] App calls `signInWithOAuth(OAuthProvider.google, redirectTo: ...)`
- [x] Android deep-link callback is configured in manifest
- [x] iOS URL scheme callback is configured in Info.plist
- [ ] Google sign-in flow tested end-to-end on physical device(s)

Evidence:
- [ ] Screenshot: Supabase Google provider enabled
- [ ] Screenshot: Supabase redirect URL list includes `com.dora.travel://login-callback/`
- [ ] Video/link: successful Google login on Android
- [ ] Video/link: successful Google login on iOS (if iOS release in this cycle)

### 2.3 Apple Sign-In (required for iOS if third-party login is offered)

- [ ] Apple provider configured in Supabase or native Apple sign-in flow integrated
- [ ] Apple login button present on iOS when Google/social login exists
- [ ] Apple callback + nonce/id-token flow validated

### 2.4 Account Deletion (store policy critical)

- [x] In-app path exists to request/perform account deletion
- [x] Backend deletion path and data handling verified
- [x] Public deletion support URL exists (for Play policy compliance)
- [ ] Deletion flow reflected accurately in privacy declarations

Evidence:
- [ ] Auth success video (Android + iOS)
- [ ] Account deletion walkthrough screenshot/video
- [x] Code references:
  - `flutter/lib/features/profile/presentation/screens/settings_screen.dart`
  - `backend/app/api/v1/users.py`
  - `backend/app/services/user_service.py`
  - `backend/tests/test_users.py`
- [x] Deletion support page: `https://doratravelapp.netlify.app/delete_account.html`

---

## 3. App Completeness and Placeholder Sweep

- [ ] No user-facing "Coming soon" in critical user flows
- [ ] No crash path from `UnimplementedError` reachable in production
- [ ] No broken buttons in onboarding/auth/core trip/edit/export flows
- [ ] Reviewer can complete app's primary use case without hidden blockers

Evidence:
- [ ] Manual QA checklist run attached
- [ ] Placeholder audit report attached

---

## 4. Privacy, Legal, and User Data

### 4.1 Public URLs

- [x] Privacy Policy URL is live and public
- [x] Terms of Service URL is live and public
- [x] Support/Contact URL or email is live
- [ ] URLs in app settings open correctly

### 4.2 Data Disclosures

- [ ] Google Play Data Safety form completed accurately
- [ ] Google Play App Content declarations completed
- [ ] App Store Connect App Privacy section completed accurately
- [ ] Third-party SDK data collection reflected (Supabase, Firebase, Sentry, etc.)

### 4.3 Permissions

- [ ] Every declared runtime permission is justified and used
- [ ] Permission request copy is clear and accurate
- [ ] Play permission declarations completed for sensitive scopes (if applicable)

Evidence:
- [x] Policy URLs
  - `https://doratravelapp.netlify.app/privacy_policy.html`
  - `https://doratravelapp.netlify.app/terms_conditions.html`
  - `https://doratravelapp.netlify.app/support.html`
  - `https://doratravelapp.netlify.app/delete_account.html`
- [ ] Console screenshots (Play + App Store privacy sections)

---

## 5. Quality and Reliability Gates

### 5.1 Automated Checks

- [ ] `flutter analyze` clean
- [ ] Flutter tests pass for core modules
- [ ] Backend API/export tests pass in release environment
- [ ] No high-severity crash in recent QA run

### 5.2 Manual Device Validation

- [ ] Android physical device smoke test complete
- [ ] iOS physical device smoke test complete
- [ ] Offline/poor-network behavior checked
- [ ] Auth + upload + export + share core loop validated

### 5.3 Export-Specific Readiness

- [ ] Export happy path completes from app to downloadable artifact
- [ ] Error/retry/cancel states behave correctly
- [ ] Download/share URL behavior verified
- [ ] No regression in media upload and sync queue

Evidence:
- [ ] Test report link
- [ ] Crash-free session metrics screenshot

---

## 6. Google Play Console Checklist

### 6.1 Store Setup

- [ ] App name, short description, full description finalized
- [ ] Feature graphic/screenshots/videos uploaded
- [ ] Content rating questionnaire complete
- [ ] Target audience + content declarations complete

### 6.2 Policy Setup

- [ ] App Access section completed with valid reviewer credentials
- [ ] Data Safety submitted and no unresolved warnings
- [ ] Ads declaration correct
- [ ] Privacy policy URL set and valid

### 6.3 Release (Google Play Closed Testing - first rollout)

- [ ] Release notes written for closed testing build
- [ ] Signed `AAB` uploaded to Closed Testing track
- [ ] Tester list/group configured for Closed Testing
- [ ] Pre-launch report reviewed (if generated)
- [ ] Closed testing rollout start approved and monitored

Evidence:
- [ ] Play Closed Testing dashboard screenshot
- [ ] Closed Testing track URL
- [ ] Signed `AAB` artifact link

---

## 7. Apple App Store Connect Checklist

### 7.1 App Information

- [ ] App name/subtitle/category finalized
- [ ] Screenshots for required devices uploaded
- [ ] Age rating completed and current
- [ ] Privacy Policy URL set

### 7.2 Review Requirements

- [ ] Demo/test account credentials provided in Review Notes
- [ ] Any gated feature instructions clearly written for reviewer
- [ ] In-app purchases configured correctly (if applicable)
- [ ] Account deletion details available to reviewer

### 7.3 Submission

- [ ] Build selected and attached to version
- [ ] Export compliance answered
- [ ] Submit for review completed
- [ ] Release strategy chosen (manual/automatic)

Evidence:
- [ ] App Store Connect submission screenshot

---

## 8. Launch Operations

- [ ] Monitoring dashboard ready (API errors, crashes, auth failures, export failures)
- [ ] On-call owner assigned for first 72 hours
- [ ] Rollback plan documented
- [ ] User support response template prepared

---

## 9. Evidence Index

- [ ] Signed AAB artifact link (local path + CI artifact URL):
- [ ] QA report link:
- [ ] Auth smoke-test video (Android):
- [ ] Account deletion smoke-test video:
- [x] Policy URL list:
  - `https://doratravelapp.netlify.app/privacy_policy.html`
  - `https://doratravelapp.netlify.app/terms_conditions.html`
  - `https://doratravelapp.netlify.app/support.html`
  - `https://doratravelapp.netlify.app/delete_account.html`
- [ ] Play Closed Testing release URL:
- [ ] Play Console evidence screenshots:
  - Data Safety
  - App Content
  - App Access
  - Ads declaration
- [ ] Play Console submission link (if production rollout is attempted):
- [ ] App Store submission link:
- [ ] Final sign-off note link:
