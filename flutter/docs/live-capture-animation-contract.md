# Live Capture Animation Term Dictionary + Slice G Contract

Last updated: 2026-04-01  
Status: Draft, execution-ready  
Owner: Flutter live capture  

Parent references:
1. `docs/live-tracking-unified-system-architecture-plan.md` (Section 10, Phase P6).
2. `flutter/docs/live-capture-screen-implementation-spec.md` (Section 9, Slice G, Section 16.6).
3. `flutter/docs/design_system.md` (motion baseline).
4. Medium article: "Take Your Flutter Animations to The Next Level" by Roaa Khaddam.

## 1. Purpose

Define animation terms as explicit Dora implementation rules so Slice G can be executed consistently across agents without style drift.

This document is normative for live capture runtime surfaces.

## 2. Scope

In scope:
1. Live capture runtime motion only (`features/live_capture` + map runtime overlay plumbing).
2. Animation types A/B/C and event mapping for live capture.
3. Reduced-motion and low-end fallback behavior.
4. Testing and acceptance criteria for Slice G.

Out of scope:
1. Export template motion (Phase 6D).
2. Editor route studio motion polish outside live capture runtime.

## 3. Decision Record: Token Authority and Conflict Resolution

There is a timing mismatch across docs:
1. Live capture architecture/spec require `120/180/260ms`.
2. Global design system currently lists `150/250/400ms`.

Contract decision for live capture:
1. `120/180/260ms` is authoritative for live capture runtime until docs are unified.
2. "No bounce. No elastic." remains valid; springs must settle quickly and feel controlled.
3. No hardcoded durations in live capture code after Slice G.
4. Use one token source: `flutter/lib/core/theme/animation_tokens.dart`.

## 4. Animation Type Ownership

### 4.1 Type A: Map-native geospatial animation
Use for:
1. Current marker interpolation.
2. Route segment extension.
3. Place pin settle and pulse.

Rules:
1. Execute in map adapter/runtime layer, not widget tree choreography.
2. Do not fake GPS/path motion with Flutter `Animated*` widgets.
3. High-frequency updates must avoid broad widget rebuilds.

Primary owner files:
1. `flutter/lib/core/map/adapters/mapbox_adapter.dart`
2. `flutter/lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
3. Live capture map surface widget when moved from placeholder to real map.

### 4.2 Type B: Flutter overlay motion
Use for:
1. Action dock feedback.
2. Advisory cards and transient callouts.
3. Session control transitions.
4. Sync-status subtle confirmations.

Rules:
1. Prefer implicit animation primitives first.
2. Keep critical action acknowledgement under `220ms` end-to-end.
3. Animate only changed surfaces, not the full screen stack.

Primary owner files:
1. `flutter/lib/features/live_capture/presentation/widgets/*`
2. `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`

### 4.3 Type C: Lottie/event burst
Use for:
1. Photo confirmation burst.
2. Warning pulse burst.
3. Critical advisory pulse (optional, severity-gated).

Rules:
1. One-shot only, no continuous loops.
2. Must never block capture actions or command feedback.
3. Must degrade to Type B-only feedback on reduced-motion or low-end mode.

Proposed owner file:
1. `flutter/lib/features/live_capture/presentation/widgets/live_capture_transient_effects.dart`

## 5. Term Dictionary With Dora Usage Rules

| Term | Meaning | Dora usage rule |
| --- | --- | --- |
| `AnimationController` | Explicit timeline driver. | Allowed only when implicit widgets cannot express behavior. Must be disposed and isolated to a focused widget, not screen root. |
| `TickerProvider` / `SingleTickerProviderStateMixin` | Supplies vsync ticks. | Required for explicit controllers. Do not attach many controllers to `LiveCaptureScreen` state. |
| `AnimatedBuilder` | Rebuilds animated region from a `Listenable`. | Use `child` parameter to keep static subtree out of rebuild loop. |
| `Tween` | Maps controller `0..1` to target value range. | Keep tweens local to one motion concern (scale, opacity, offset). |
| `CurvedAnimation` | Applies easing to linear controller time. | Use tokenized curves only. |
| `Interval` | Sub-range of a single controller timeline. | Use for staggered reveals within one container, not across unrelated surfaces. |
| `Staggered animation` | Sequenced or overlapped intervals on one timeline. | Max two overlay levels in live capture to avoid animation noise. |
| `Hero` | Shared element route transition by tag match. | Optional for live->editor handoff only if source/target subtree parity is maintained. |
| `PageRouteBuilder` | Custom route transition. | If hero is used, avoid default transition conflict; keep route motion minimal. |
| `Transform` + `Matrix4` perspective | Visual depth transform, not true 3D scene graph. | Use only for small emphasis effects in overlays; never for GPS/path simulation. |
| `NotificationListener<UserScrollNotification>` | Scroll direction stream from bubbling notifications. | Use only in scroll-driven overlay strips if needed; do not attach to map gesture stream. |
| `ValueNotifier` / `ValueListenableBuilder` | Lightweight reactive primitive for small state. | Preferred for local animation state to avoid full `setState` churn. |
| `AutomaticKeepAliveClientMixin` | Keeps list item state alive offscreen. | Use only when replaying entry animations should be prevented. |
| `cacheExtent` / `scrollCacheExtent` | Off-screen prebuild distance for scrollables. | Treat as perf tuning only; do not rely on it as primary animation trigger contract. |
| `StreamProvider` (Riverpod) | Shared stream subscription with lifecycle management. | Preferred for sensor-like or high-frequency sources; avoid duplicate stream subscriptions. |
| `TweenAnimationBuilder` | Implicit interpolation to changing target values. | Preferred for pointer/sensor offset smoothing in reusable effects. |
| `MouseRegion` | Pointer enter/hover/exit events. | Desktop/web gyroscope alternative for parallax-like effects. |
| `GyroscopeEvent` | Device rotational velocity stream (`x/y/z`). | Mobile-only enhancement. Must be bounded and optional. |
| `setCamera` vs `flyTo/easeTo` (Mapbox) | Abrupt camera set vs animated transition. | Use `flyTo/easeTo` for user-visible recenter transitions; avoid abrupt jumps except hard reset cases. |
| `Style Layers` vs annotations (Mapbox) | Lower-level but higher-perf rendering path. | Prefer style layers for dense/high-frequency map animation data. |
| Reduced motion | Accessibility preference to reduce/disable motion. | Respect system setting by shortening/removing travel and disabling Type C bursts. |
| Low-end fallback | Runtime simplification under performance pressure. | Drop Type C first, reduce simultaneous Type B animations, keep Type A essential updates only. |

## 6. Event-to-Animation Runtime Contract

### 6.1 Tokenized duration classes
1. `fast = 120ms`
2. `normal = 180ms`
3. `slow = 260ms`

### 6.2 Proposed map constants
1. `marker_lerp_ms = 160`
2. `path_segment_ms = 140`
3. `camera_recenter_ms = 420` (for explicit recenter actions only)

### 6.3 Event matrix

| Event | Type(s) | Normal behavior | Reduced-motion behavior | Cancel rule |
| --- | --- | --- | --- | --- |
| GPS point accepted | A | Marker interpolation + route extension only. | Keep updates but remove decorative pulse. | New GPS point supersedes prior interpolation. |
| Route segment extended | A | Extend active route smoothly. | Same, no additional flourish. | Coalesce if updates arrive faster than animation duration. |
| Photo saved | B + C | Action pill feedback (`fast`) + optional one-shot burst (`<=600ms`) not gating UX. | B only. No burst. | If new capture occurs, finish B; drop older burst. |
| Note saved | B | Subtle chip/state feedback (`fast` or `normal`). | Same duration or immediate settle. | Latest note feedback wins. |
| Warning saved | A + C | Map warning pin settle/pulse + one-shot warning burst. | Keep map pin settle only. | New warning event can preempt prior burst. |
| Advisory received | B (+ optional C critical) | Card enter transition; critical may pulse once. | Card appears with minimal fade only. | Higher-priority advisory can replace current card animation. |
| Sync success | B | Small non-celebratory confirmation (`fast`). | Instant state update allowed. | Success feedback canceled by immediate error state. |
| Sync blocked/error | B static emphasis | High-contrast static callout, no celebratory motion. | Same. | Error state has highest priority and cancels non-error motion. |

## 7. Reduced-Motion and Accessibility Contract

Detection inputs:
1. `MediaQuery.disableAnimationsOf(context)`.
2. Engine-level disable flag where available.

Rules:
1. Disable Type C entirely when reduced motion is active.
2. Replace long travel with opacity/color emphasis.
3. Keep state meaning visible without movement.
4. Keep touch targets and focus order stable during animated updates.

## 8. Performance Contract

Rules:
1. Prefer transform/opacity/color changes over expensive layout churn.
2. Do not animate many overlay surfaces at once.
3. Keep rebuild scope narrow using `child` optimization patterns.
4. Treat map updates and overlay animations as separate pipelines.
5. Preserve map frame budget target: `>45 FPS p95`.

Low-end fallback order:
1. Disable Type C.
2. Reduce stagger depth and overlapping Type B animations.
3. Keep Type A essentials only (marker + route).

## 9. Implementation Rules by Surface

### 9.1 `LiveCaptureScreen`
1. Orchestrates motion triggers only.
2. Must not host many long-lived explicit controllers.

### 9.2 Action dock and panels
1. Prefer `AnimatedContainer`, `AnimatedOpacity`, `AnimatedPositioned`, `AnimatedSwitcher`.
2. All durations/curves from animation tokens only.

### 9.3 Map runtime
1. Marker/path animation handled in map layer/adapter.
2. Avoid coupling map frame updates to overlay rebuild loops.

### 9.4 Transient effects
1. Keep in dedicated widget layer.
2. One-shot, cancellable, non-blocking.

## 10. Slice G Definition of Done

Slice G is complete only when all are true:
1. `animation_tokens.dart` exists with durations, curves, springs, and map constants.
2. Live capture widgets no longer use hardcoded timing values.
3. Event-to-animation matrix in Section 6 is implemented.
4. Reduced-motion fallback is implemented and verified.
5. Low-end fallback behavior for Type C is implemented.
6. Timing smoke tests are present.
7. Goldens exist for `planned/active/paused/ended/blocked`.
8. No legacy strip widgets are used in live capture runtime.

## 11. Test Contract

Required test coverage:
1. Token drift test that fails if canonical durations/curves change unexpectedly.
2. Widget smoke tests proving key overlays transition with tokenized timings.
3. Reduced-motion test that suppresses Type C.
4. Error-priority test proving blocked/error state cancels celebratory feedback.
5. Golden set for runtime states.
6. Manual low-end run to verify fallback behavior and no animation overload.

## 12. Current Branch Notes

At this checkpoint:
1. Slice G is still open in live capture spec and architecture plan.
2. `animation_tokens.dart` is not yet present.
3. Live capture map surface currently uses a placeholder canvas widget; full Type A completion requires live map surface integration.

## 13. Handoff Notes for Agents

When implementing Slice G:
1. Start by introducing token file and replacing hardcoded timings.
2. Keep Type A, B, C responsibilities separate.
3. Avoid broad refactors outside live capture scope.
4. Log evidence updates in:
   - `docs/live-tracking-unified-system-architecture-plan.md`
   - `flutter/docs/live-capture-screen-implementation-spec.md`
   - `flutter/docs/live-tracking-flutter-execution-plan.md`
