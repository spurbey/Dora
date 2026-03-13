# Phase 6E Nav/UX Working Memory

## Objective
Implement a custom bottom tab navigation experience aligned with the provided design reference while preserving current routing and app stability.

## Operating Rules
- Keep edits limited to nav/tab related files unless dependency requires otherwise.
- After each completed item:
  1. update this memory file,
  2. append a matching entry in `phase6e-nav-ux-changelog.md`,
  3. then proceed to next item.
- Avoid short-term hacks; prefer reusable, maintainable components.

## Current Baseline (2026-03-13)
- Current implementation uses stock `BottomNavigationBar` in:
  - `flutter/lib/core/navigation/navigation_shell.dart`
- Theme-level styling is defined in:
  - `flutter/lib/core/theme/app_theme.dart`
- Gap: visual design and interaction do not match the reference-style custom tab bar.

## Execution Plan

### Step 1 - Design Contract
- Extract concrete style/interaction specs from reference:
  - container shape, spacing, icon style, selected state treatment, background/blur/elevation.
- Define non-negotiable behavior constraints:
  - same 4 destinations,
  - same route mapping,
  - same back-stack behavior.

#### Step 1 Output (Locked)
- Tab container:
  - horizontal margin: 16
  - vertical margin: 8
  - height: 64
  - background: `AppColors.card`
  - top border: `AppColors.divider`
- Item layout:
  - 4 equal-width segments
  - minimum tap target >= 44 px
  - icon above label
- Selected state:
  - icon + label color: `AppColors.accent`
  - selected pill background: `AppColors.accentSoft`
  - pill radius: `AppRadius.lg`
- Unselected state:
  - icon + label color: `AppColors.textSecondary`
- Behavior parity:
  - `Feed`, `Create`, `My Trips`, `Profile` map unchanged
  - route selection still determined by path prefix
  - navigation action remains `context.go(...)`

### Step 2 - Custom Nav Component
- Build a reusable custom tab bar widget.
- Integrate into `navigation_shell.dart` replacing stock `BottomNavigationBar`.
- Keep route dispatch logic unchanged.

### Step 3 - Theming + Responsiveness
- Ensure it scales across small/large phones and handles safe-area insets.
- Validate color/contrast and tap-target accessibility.

### Step 4 - Verification
- Manual checks:
  - tab switching,
  - deep-link route index mapping,
  - keyboard/sheet interactions,
  - no overflow on low-height devices.

## Progress Log

### 2026-03-13 - Initialized
- Created tracking docs.
- No code changes beyond documentation.

### 2026-03-13 - Step 1 Completed
- Locked a deterministic tab redesign contract before code changes.
- No routing behavior changes introduced in this step.

### 2026-03-13 - Step 2 Completed
- Replaced stock Material `BottomNavigationBar` with custom tab component in:
  - `flutter/lib/core/navigation/navigation_shell.dart`
- Kept route logic unchanged:
  - same `location -> index` mapping
  - same `context.go(...)` destinations
- Added selected pill state and token-based colors:
  - selected: `AppColors.accent` + `AppColors.accentSoft`
  - unselected: `AppColors.textSecondary`
- Kept nav-only scope; no edits in feature/business logic layers.

### 2026-03-13 - Step 3 Completed (Code Side)
- Added accessibility semantics on tab buttons:
  - `button: true`
  - `selected: ...`
  - label per destination
- Confirmed min touch target constraint remains `>= 44`.
- Safe-area wrapper remains active for bottom inset handling.

### 2026-03-13 - Analyzer Blocker Resolution
- Addressed 4 hard analyzer errors caused by `AuthService` interface drift in test fakes.
- Added `signInWithGoogle()` override in:
  - `flutter/test/core/sync/entity_sync_worker_test.dart`
  - `flutter/test/features/create/media_upload_integration_test.dart`
  - `flutter/test/features/create/route_repository_dependency_test.dart`
  - `flutter/test/features/create/trip_repository_viewport_test.dart`
- Scope intentionally limited to compile-blocking test stubs only.

## Risks / Watchpoints
- Route-index mapping drift when replacing stock widget.
- Visual parity pressure causing hardcoded layout values that fail on smaller devices.
- Unintended side effects on screens using full-height content near bottom safe area.
