# Auth and User Provisioning Reliability Runbook

Last Updated: 2026-03-17
Owner: Platform + Mobile
Scope: FastAPI auth dependency path, user bootstrap flow, Flutter session handling

## 1. Incident Summary

Observed symptoms:
- App sometimes redirects to login with unauthorized state during slow operations.
- Local uvicorn logs intermittently show unauthorized responses in the middle of active sessions.
- Production log window showed a backend 500 during authenticated trip fetch.

## 2. Evidence Collected

From deploy logs (`deploy_logs.txt`):
- `2026-03-16T18:50:22Z` request `GET /api/v1/trips?page=1&page_size=50&visibility=` returned `500`.
- Traceback ended in SQLAlchemy `IntegrityError` / Postgres `UniqueViolation`:
  - `duplicate key value violates unique constraint "users_pkey"`
  - key `id=24fa8c3f-b57b-4fa7-9d71-a99cd546d9e9` already exists.
- Insert attempt came from auth dependency user bootstrap path.

Relevant backend code path:
- `backend/app/dependencies.py`
  - `get_current_user()`
  - user lookup + create
  - `db.commit()` on new user insert

## 3. Root Cause Analysis

### 3.1 Confirmed: User bootstrap race condition

Current behavior:
1. Multiple concurrent authenticated requests arrive for a user not yet in local `users` table.
2. Both requests execute `SELECT` and see user missing.
3. Both attempt `INSERT` for same `users.id`.
4. One succeeds, one fails with `users_pkey` duplicate -> request returns `500`.

Impact:
- Intermittent backend 500 on normal authenticated endpoints.
- Most visible around app startup or fan-out fetches where several authenticated calls start together.

### 3.2 Likely contributor to "random unauthorized": auth dependency fragility under latency

Current behavior:
- JWKS is fetched from Supabase for token verification in request path.
- Unexpected exceptions in auth path are broadly converted to credentials failure.

Risk under slow/network conditions:
- transient network/JWKS issues may be surfaced as unauthorized instead of temporary service failure.
- client may interpret as session expiry and redirect to login.

## 4. Fix Strategy (to implement after this doc)

## 4.1 Backend (mandatory)

1. Make user provisioning idempotent and race-safe.
- Use one of:
  - SQL upsert (`INSERT ... ON CONFLICT (id) DO UPDATE/NOTHING`) and re-select row.
  - Or catch `IntegrityError`, rollback, then re-query existing user by `id`.
- Guarantee: duplicate insert races never escape as 500.

2. Add JWKS caching with short TTL.
- Cache JWKS keys in-process for 5-10 minutes.
- Refresh on cache miss/expiry and on unknown `kid`.
- Keep request timeout strict.

3. Correct auth error classification.
- `JWTError` / expired token -> `401`.
- JWKS fetch/network/unavailable -> `503` (temporary auth infra issue).
- Do not map every exception to unauthorized.

## 4.2 Flutter (recommended)

1. Harden token retrieval.
- Ensure access token getter can refresh/recover session before returning null.

2. Add one-time 401 recovery in network layer.
- On first 401, attempt refresh, replay request once, then fail if still 401.

3. Reduce aggressive login redirects during transient auth recovery.
- Router should not immediately force login during in-progress refresh windows.
- Redirect only after confirmed auth loss.

## 5. Validation Plan

Backend:
1. Concurrency test: simultaneous first authenticated requests for same user.
- Expected: one user row, no 500.
2. Auth resilience test with simulated JWKS latency/unavailability.
- Expected: infra failures produce 503; invalid/expired tokens produce 401.
3. Verify deploy logs no longer show `users_pkey` duplicate traces from auth dependency.

Flutter:
1. Integration test for 401 refresh-and-replay behavior.
2. Manual test: keep app open during slow operations and network jitter.
- Expected: no unexpected jump to login while session is recoverable.

## 6. Rollout Order

1. Deploy backend race-safe user bootstrap and auth error classification first.
2. Monitor production for 24-48h (`500` rate on authenticated endpoints, auth 401/503 ratios).
3. Deploy Flutter 401 recovery improvements.
4. Re-verify no forced-login regressions.

## 7. Success Criteria

- No `users_pkey` duplicate insert errors from auth dependency in production logs.
- No intermittent unauthorized redirects for valid sessions during slow operations.
- 401 indicates true token/session invalidity; transient auth infra issues surface as 503.
