# Security Release Execution Plan (Actual Vulnerabilities Only)

Last updated: 2026-03-17
Scope: backend + video-renderer release paths

## Confirmed Vulnerabilities and Fix Plan

1. Renderer endpoint could be called without strong caller auth, and expensive jobs lacked abuse limits.
- Risk: unauthorized render submission/cancel/status polling + cost amplification.
- Fix:
  - Require `X-Renderer-Secret` on `/api/v1/render*`.
  - Enforce manifest limits (duration/fps/snapshot size).
  - Enforce queue cap and submit rate limits.
  - Add retention/eviction for renderer in-memory maps to avoid unbounded growth.
  - Require renderer secret in backend renderer client and production startup checks.
- Files:
  - `video-renderer/src/server.js`
  - `video-renderer/src/lambda-renderer.js`
  - `backend/app/services/export_renderer.py`
  - `backend/app/config.py`
  - `.env` examples + `docker-compose.dev.yml`

2. Media upload path read full file bytes twice in-memory.
- Risk: memory amplification under concurrent uploads, easier resource exhaustion.
- Fix:
  - Read upload once with bounded chunked read (tier-aware max size).
  - Reuse preloaded bytes for storage upload and metadata extraction.
- Files:
  - `backend/app/services/media_service.py`
  - `backend/app/services/storage_service.py`

3. Route generation error logs could include raw upstream exception text containing `access_token`.
- Risk: token leakage in application logs.
- Fix:
  - Log sanitized error metadata only (exception type + optional status code).
  - Add regression test to assert token text is not logged.
- Files:
  - `backend/app/api/v1/routes.py`
  - `backend/tests/test_routes.py`

4. MCP allowlist path check used prefix string logic (sibling-prefix bypass class).
- Risk: allowlist boundary bypass in context server path checks.
- Fix:
  - Replace prefix comparison with canonical `relative_to` boundary checks.
- Files:
  - `MCP Server/server.py` (local patch applied; file currently gitignored)

## Verification Plan

1. Run focused backend tests for touched areas:
- `test_export_renderer.py`
- `test_media.py`
- `test_media_endpoints.py`
- `test_routes.py`

2. Run dependency audits in CI (network-enabled):
- Node: `npm audit` for `video-renderer`
- Python: audit from backend lock environment

3. Release gate:
- No open critical/high vulnerabilities in release paths.
- Any deferred medium risk documented with owner + follow-up date.
