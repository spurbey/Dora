# Flutter Web deploy handoff (Vercel)

Written from the main checkout after the API was migrated to the new host and put
on HTTPS. Everything below is scoped to this worktree (`Dora-flutter-web`).

## Facts you cannot discover from the code

- **The API moved.** It is now `https://a4ulpcdixmirohtmxe7z9fpb.52.66.17.225.sslip.io`
  (HTTPS, real Let's Encrypt cert, verified `GET /health` -> 200).
- **`API_BASE_URL` in `flutter/.env` is already updated** to that URL. Do not change it.
  The previous value pointed at the old account's host, which is dead.
- **`API_BASE_URL` is a compile-time dart-define**, not runtime config. It is baked
  into the JS bundle at build time. If it is wrong, you must rebuild — you cannot
  patch it after deploying.
- **HTTPS is mandatory, not a preference.** The app uses the camera / live capture
  (`getUserMedia`), which browsers only allow in a secure context. Vercel provides
  that for free.

## Prerequisite the human must do first (you cannot)

Vercel CLI needs an authenticated session, and `vercel login` is interactive:

```
! npx vercel login
```

Alternatively the human can export `VERCEL_TOKEN`. Do not attempt to log in yourself.

## Build

Build locally. Do **not** try to build on Vercel: the Flutter SDK is not present in
its builders, and installing it there is slow and fragile.

```bash
cd flutter
flutter build web --release --dart-define-from-file=.env
```

Output lands in `flutter/build/web/`.

Sanity-check before deploying — this should print the new host, and it proves the
dart-define actually took effect:

```bash
grep -c "a4ulpcdixmirohtmxe7z9fpb" build/web/main.dart.js
```

If that returns 0, the build did not pick up `.env` and the app will point at the
wrong API. Fix that before deploying.

## SPA routing

Flutter web uses client-side routing, so a deep link like `/trips/123` 404s on a
static host unless everything falls back to `index.html`. Add `vercel.json` at the
root of what you deploy:

```json
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```

If the app uses hash routing (`/#/trips/123`) this is harmless either way.

## Deploy

```bash
npx vercel deploy --prod --yes flutter/build/web
```

No git integration is needed or wanted — this branch is unmerged, and deploying the
prebuilt directory keeps Vercel out of the Flutter toolchain entirely.

## Report back

The production URL (a `*.vercel.app` host). Someone with Coolify access needs it to
finish the wiring below — that cannot be done from this worktree.

## Do not

- Commit `flutter/.env`. It is gitignored and holds the Supabase anon key and Mapbox token.
- Change `API_BASE_URL`.
- Deploy the API or touch the Coolify host.

## Still needed after the Vercel URL exists (not your job, but it will look broken without it)

1. **CORS.** The API's `ALLOWED_ORIGINS` currently lists only localhost and a LAN IP.
   Until the Vercel origin is added there, the browser will block every API call and
   the app will silently fail to load data.
2. **Supabase Auth redirect URLs.** If sign-in uses magic links or OAuth, the Vercel
   URL must be added under Supabase -> Authentication -> URL Configuration.
3. **Mapbox token restriction.** `MAPBOX_TOKEN` is compiled into the public JS bundle.
   It is readable by anyone, so it should be restricted by URL in the Mapbox account
   rather than left open.
