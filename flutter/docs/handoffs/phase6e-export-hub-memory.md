# Phase 6E Export Hub Working Memory

## Objective
Add a My Trips-level Export Hub so users can see all export jobs (in progress, completed, failed, canceled), not only per-trip export studio.

## Why This Is Needed
- Current UX supports export creation per trip, but there is no single place to monitor export history/status.
- Users need operational visibility: what is running, what failed, what is done, and quick actions (cancel/retry/download/share).

## Current State (Done Before This Track)

### Implemented
- Per-trip export flow exists:
  - route: `Routes.exportStudio` (`/trips/:id/export`)
  - screen: `flutter/lib/features/export/presentation/screens/export_studio_screen.dart`
- Export APIs already integrated for:
  - create job
  - get job status
  - cancel job
  - get download URL
  - get share URL
- My Trips has per-trip menu action for export.

### Missing
- No global export list screen from My Trips.
- No backend list endpoint (`GET /api/v1/exports`) for user job history.
- No Flutter repository/provider abstraction for export-job collections.

## Plan (What We Are Doing)

### Step 1 - Contract + IA
- Add a My Trips header entry point to open Export Hub.
- Hub sections:
  - In Progress
  - Completed
  - Failed/Blocked
  - Canceled
- Card actions:
  - In Progress: Cancel
  - Completed: Download, Share
  - Failed/Blocked/Canceled: Retry (open Export Studio for same trip)

### Step 2 - Backend/API
- Add `GET /api/v1/exports` (user-scoped, paginated, optional status filter).
- Response fields:
  - `job_id`, `trip_id`, `trip_name`, `template`
  - `status`, `stage`, `progress`
  - `output_url`, `thumbnail_url`
  - `error_code`, `error_message`
  - `created_at`, `completed_at`

### Step 3 - Flutter Data Layer
- Extend export repository with `listJobs(...)`.
- Add typed view model grouping jobs by section.

### Step 4 - UI Layer
- Add `MyTripsExportScreen`.
- Add route and navigation entry from My Trips.
- Reuse existing export actions where possible to avoid duplicate logic.

### Step 5 - Hardening
- Empty states and error-retry states.
- Pull-to-refresh.
- Ensure no regressions in existing Export Studio flow.

## Progress Log

### 2026-03-13 - Initialized
- Created this memory document before implementation.
- Captured current capabilities and gaps.
- Locked execution sequence (contract -> backend -> data -> UI -> hardening).

## Risks / Watchpoints
- Without backend list endpoint, history can’t be reliably reconstructed client-side.
- Overlapping polling from multiple screens can increase API chatter; hub should poll only active jobs.
- Retry action must route to existing studio flow without bypassing precheck guardrails.
