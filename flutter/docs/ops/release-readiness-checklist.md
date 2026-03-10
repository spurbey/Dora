# Mobile Release Readiness Checklist

Last Updated: 2026-03-10
Owner: Release Manager + Mobile Lead + Backend Lead
Scope: Dora Android + iOS production release

How to use:
1. Work top to bottom.
2. Do not submit to stores until all required checks are complete.
3. Attach evidence links (screenshots, PRs, console screenshots) for each section.

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

- [ ] Android `applicationId` is final (not `com.example.*`)
- [ ] Android `namespace` matches final package structure
- [ ] iOS bundle identifier is final for Debug/Release/Profile
- [ ] Firebase config files match final IDs (`google-services.json`, `GoogleService-Info.plist` if used)

Evidence:
- [ ] Android build config screenshot/link
- [ ] iOS Signing & Capabilities screenshot/link

### 1.2 Signing and Build

- [ ] Android release keystore configured
- [ ] Android App Bundle (`.aab`) builds successfully
- [ ] iOS release archive builds successfully in Xcode
- [ ] iOS signing/provisioning profile valid
- [ ] Crash reporting environment tags validated (dev vs prod)

Evidence:
- [ ] Android release build log
- [ ] iOS archive/export log

---

## 2. Authentication and Account Requirements

### 2.1 Core Auth

- [ ] Email/password login works end-to-end
- [ ] Signup works end-to-end
- [ ] Logout works cleanly
- [ ] Expired session handling tested

### 2.2 Google Sign-In (if enabled)

- [ ] Google provider enabled in Supabase
- [ ] Correct Google OAuth redirect URI configured: `https://<project-ref>.supabase.co/auth/v1/callback`
- [ ] Supabase Additional Redirect URLs include mobile callback URI
- [ ] App calls `signInWithOAuth(OAuthProvider.google, redirectTo: ...)`
- [ ] Android deep link callback configured and tested
- [ ] iOS URL scheme callback configured and tested

### 2.3 Apple Sign-In (required for iOS if third-party login is offered)

- [ ] Apple provider configured in Supabase or native Apple sign-in flow integrated
- [ ] Apple login button present on iOS when Google/social login exists
- [ ] Apple callback + nonce/id-token flow validated

### 2.4 Account Deletion (store policy critical)

- [ ] In-app path exists to request/perform account deletion
- [ ] Backend deletion path and data handling verified
- [ ] Public deletion support URL exists (for Play policy compliance)
- [ ] Deletion flow reflected accurately in privacy declarations

Evidence:
- [ ] Auth success video (Android + iOS)
- [ ] Account deletion walkthrough screenshot/video

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

- [ ] Privacy Policy URL is live and public
- [ ] Terms of Service URL is live and public
- [ ] Support/Contact URL or email is live
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
- [ ] Policy URLs
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

### 6.3 Release

- [ ] Release notes written
- [ ] `AAB` uploaded to target track
- [ ] Pre-launch report reviewed (if run)
- [ ] Staged rollout plan defined

Evidence:
- [ ] Play release dashboard screenshot

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

- [ ] Build artifacts link:
- [ ] QA report link:
- [ ] Policy URL list:
- [ ] Play Console submission link:
- [ ] App Store submission link:
- [ ] Final sign-off note link:

