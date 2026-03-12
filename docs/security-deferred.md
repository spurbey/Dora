# Security Issues — Deferred (Post-Beta)

These issues were identified during pre-beta security review. They are lower priority for closed testing but should be resolved before public release.

## HIGH — Fix Before Public Launch

### 1. Unauthenticated Renderer Endpoints
- **Files:** `video-renderer/src/server.js`, `docker-compose.dev.yml`
- **Issue:** All `/api/v1/render` endpoints have no authentication. Anyone who can reach port 3100 can submit/cancel renders.
- **Fix:** Add API key middleware (`X-Renderer-Api-Key` header checked against env var). In production, do not expose port 3100 publicly.

### 2. Unbounded Render Parameters
- **Files:** `video-renderer/src/server.js` (~line 125)
- **Issue:** `duration_sec` and `fps` only validate > 0, no upper cap. Attackers can request extreme renders causing resource exhaustion.
- **Fix:** Add caps: `duration_sec <= 300`, `fps <= 60`.

### 3. Media Upload Memory DoS
- **Files:** `backend/app/services/media_service.py`, `backend/app/services/storage_service.py`
- **Issue:** Uploaded files are fully read into memory before size validation. Large uploads can OOM the backend.
- **Fix:** Check `Content-Length` header first, then read in 64KB chunks with a running byte counter, aborting if limit exceeded.

## MEDIUM — Fix Before Public Launch

### 4. JS Dependency Vulnerabilities
- **Files:** `video-renderer/package-lock.json`
- **Issue:** `npm audit` reports known vulnerabilities in transitive dependencies (`serialize-javascript`, `fast-xml-parser`, etc.).
- **Fix:** Run `npm audit fix`. For remaining issues, evaluate if they affect production deps or are dev-only.

## LOW — Verify Configuration

### 5. Firebase Key in Repository
- **File:** `flutter/android/app/google-services.json`
- **Issue:** Firebase API key is committed (expected for mobile, but must be restricted).
- **Fix:** Ensure Firebase security rules are strict and API key restrictions are configured in Google Cloud Console.

## NOT AN ISSUE

### MCP Allowlist Prefix Bypass (Original #5)
- **Verified as false positive.** The `startswith()` check on resolved `Path` objects is correct — directories use prefix match, files use exact match.
