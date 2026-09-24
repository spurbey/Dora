# Dora Web (Flutter) — AWS Hosting Runbook

Hosts `flutter/build/web` on **S3 + CloudFront** in the same AWS account as
the rest of Dora. No Vercel/Cloudflare needed.

## Why this stays in sync with backend/services (hosting-location FAQ)

Hosting the frontend on Vercel/Cloudflare vs AWS changes **nothing** about
correctness — sync is config, not colocation:

- **API sync:** every web action calls the same `API_BASE_URL`. Same backend,
  same request IDs, same backend logs. Host location is irrelevant.
- **Auth sync:** same Supabase project. Web just needs its domain whitelisted
  in Supabase Auth → Redirect URLs (plus the `redirectTo` fix already in
  `lib/core/auth/auth_service.dart`).
- **Error tracing:** same Sentry project. Web reports with
  `environment=production` + release `web-<build-id>`; backend already tags
  its environment. Correlate in one Sentry dashboard. (No code change —
  `ENVIRONMENT` dart-define at cutover build.)
- **Media sync:** backend-issued presigned S3 URLs; the web app only renders
  them. Bucket policy untouched.
- **CORS:** backend `ALLOWED_ORIGINS` must include the web origin
  (`backend/app/main.py` reads it from env).

Reasons to still prefer AWS here: one account/bill, same-region latency to
the API, WAF/CloudTrail in one place, and the team already operates it.
Trade-off accepted: no Vercel-style preview URLs (use `flutter run` /
localhost for previews).

## Architecture

```text
Browser ──https──▶ CloudFront ──OAC──▶ S3 (private bucket, dora-web-<env>)
   │                         (WAF optional, same account as backend)
   └──https──▶ API (existing backend — must be https before launch)
   └──https──▶ Supabase Auth + Storage (existing project)
```

Notes:

- Bucket stays **private** (OAC only). No S3 website hosting.
- Hash routing (`/#/login`) means **no SPA rewrite rules** are needed —
  every route serves `index.html`.
- `sql-wasm.js/.wasm` are same-origin assets in `build/web` — no extra config.

## Prerequisites

- AWS CLI v2 with a profile that can manage S3 + CloudFront
  (`aws sts get-caller-identity` works).
- One ACM certificate in **us-east-1** for the web domain (CloudFront
  requirement), when a custom domain is used.
- Production web build (see Cutover).

## First-time setup (one-off, ~15 min)

1. Create the private bucket:
   `aws s3api create-bucket --bucket dora-web-prod --region <region>`
   (add `--create-bucket-configuration LocationConstraint=<region>` outside
   us-east-1). Keep Block Public Access ON.
2. Create the CloudFront distribution with Origin Access Control pointing at
   the bucket; default root object `index.html`; attach the ACM cert +
   alternate domain name; WAF optional.
3. Record the distribution ID as `DISTRIBUTION_ID` for deploys.

## Deploy (every release)

From repo root, after building:

```powershell
cd flutter
flutter build web --dart-define=ENVIRONMENT=production `
  --dart-define=API_BASE_URL=https://api.<your-domain> `
  --dart-define=SUPABASE_URL=<supabase-url> `
  --dart-define=SUPABASE_ANON_KEY=<anon-key> `
  --dart-define=MAPBOX_TOKEN=<token> `
  --dart-define=SENTRY_DSN=<dsn> `
  --dart-define=ORS_API_KEY=<key>
cd ..
.\infra\web\deploy-web.ps1 -BucketName dora-web-prod -DistributionId <id>
```

Or unattended equivalent: `flutter build web --dart-define-from-file=.env.web`
where `.env.web` holds the production values (never commit it).

## Cutover checklist (pre-launch, all required)

- [ ] API serves **https** (browsers block `http` API calls from an `https`
      page — mixed content). Coolify/ALB must terminate TLS for the API too.
- [ ] Backend `ALLOWED_ORIGINS` includes `https://<web-domain>`.
- [ ] Supabase Auth → Redirect URLs + Site URL include `https://<web-domain>`.
- [ ] Mapbox token has the web domain in its URL restrictions (if set).
- [ ] Cutover build uses `ENVIRONMENT=production` + production `SENTRY_DSN`.
- [ ] Post-deploy smoke: `/` → onboarding, `/#/signup`, `/#/login`,
      bad-password sign-in shows an inline error (no red screen).

## Rollback

Sync the previous `build/web` (keep last two local builds) and
`aws cloudfront create-invalidation --distribution-id <id> --paths "/*"`.

## Local preview (current state, http API)

```powershell
cd flutter/build/web
python -m http.server 8901
# open http://127.0.0.1:8901/  (hash routes: /#/login, /#/signup, /#/feed)
```
