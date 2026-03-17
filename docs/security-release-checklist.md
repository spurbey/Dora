# Security Release Checklist

Last updated: 2026-03-17
Tracking only confirmed vulnerabilities and release blockers.

## 1) Renderer Auth + Abuse Controls (Critical)
- [x] Renderer endpoints require `X-Renderer-Secret`.
- [x] Backend renderer client sends secret header.
- [x] Payload guardrails added (duration/fps/snapshot size).
- [x] Submit rate limit + active queue cap added.
- [x] Added bounded in-memory retention/eviction for render state + rate-limit windows.
- [x] Production fail-fast for missing renderer secret.
- Evidence:
  - `video-renderer/src/server.js`
  - `video-renderer/src/lambda-renderer.js`
  - `backend/app/services/export_renderer.py`
  - `backend/app/config.py`
  - `backend/tests/test_export_renderer.py`
  - `backend/.env.example`, `video-renderer/.env.example`, `docker-compose.dev.yml`

## 2) Media Upload Memory Amplification (High)
- [x] Removed duplicate full-file read in upload flow.
- [x] Added bounded chunked read before persistence.
- [x] Reused preloaded bytes for storage upload + metadata.
- Evidence:
  - `backend/app/services/media_service.py`
  - `backend/app/services/storage_service.py`
  - `backend/tests/test_media.py`
  - `backend/tests/test_media_endpoints.py`

## 3) Token Leakage in Error Logs (Medium)
- [x] Removed raw exception logging for Mapbox failures.
- [x] Added test to prevent `access_token` leak in logs.
- Evidence:
  - `backend/app/api/v1/routes.py`
  - `backend/tests/test_routes.py`

## 4) MCP Path Allowlist Boundary (Medium)
- [x] Canonical boundary check patch prepared in `MCP Server/server.py`.
- [ ] Decide whether to track/ship this file (currently ignored by `.gitignore`).

## 5) Verification Status
- [ ] Focused pytest run in this environment.
  - Blocked: `ModuleNotFoundError: No module named 'sqlalchemy'`.
- [x] Python syntax compile for touched files.
- [x] Node syntax check for renderer files.
- [ ] CI re-run with full deps + dependency audits (`npm audit`, Python audit).

## Remaining Before Release Sign-off
- [ ] Run backend tests in dependency-complete environment.
- [ ] Attach fresh audit artifacts to release ticket.
- [ ] Confirm no unresolved critical/high findings.
