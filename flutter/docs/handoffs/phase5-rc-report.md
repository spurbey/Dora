# Phase 5 RC Report (Media + Entity Sync)

Date: 2026-02-25  
Branch: `Media-Integration`  
Owner: Codex  
Status: Automated Validation Complete, Manual Hardening Pending

---

## 1. Scope Covered

1. Entity sync reliability (trip/place/route create/update/delete).
2. Media dependency-aware upload behavior (defer/block/retry).
3. Editor/media UI integration and queue state surfacing.
4. Phase 4 regression-sensitive flows.

---

## 2. Automated Validation Evidence

Use this section to record the exact commands and outputs used for RC sign-off.

| Command | Result | Notes |
|---|---|---|
| `flutter analyze` | PASS | User-confirmed green run |
| `flutter test test/core/storage/sync_task_dao_test.dart -r expanded` | PASS | User-confirmed green run |
| `flutter test test/core/sync/entity_sync_worker_test.dart -r expanded` | PASS | User-confirmed green run |
| `flutter test test/features/create/trip_repository_viewport_test.dart -r expanded` | PASS | User-confirmed green run |
| `flutter test test/features/create/route_repository_dependency_test.dart -r expanded` | PASS | User-confirmed green run |
| `flutter test test/features/create/media_upload_integration_test.dart -r expanded` | PASS | User-confirmed green run (`5/5`) |
| `flutter test test/features/create/phase4b_business_logic_test.dart -r expanded` | PASS | User-confirmed green run |

---

## 3. Manual Hardening Matrix

Record device/environment, expected behavior, and observed results.

| Scenario | Expected | Result | Evidence |
|---|---|---|---|
| Backend-backed trip: media upload success | Upload reaches `uploaded`, URL bridge updates place photos | Pending | |
| Local-only trip: dependency blocked/deferred state | No upload flood, explicit blocked/deferred reason shown | Pending | |
| Dependency chain release (`trip -> place -> media`) | Media uploads only after upstream entity sync readiness | Pending | |
| Blocked dependency recovery + retry | After dependency fixed, manual retry succeeds | Pending | |
| Route sync with unresolved place dependency | Route sync defers/blocks with clear reason | Pending | |
| Route sync with existing `serverPlaceId` | Route sync proceeds without false deferral | Pending | |
| App restart with pending sync/media tasks | Queue resumes without duplicate in-flight execution | Pending | |
| Cancel/remove during in-flight media upload | Row remains canceled/removed, no stale URL bridge | Pending | |

---

## 4. Data Retention / Offline Expectations

1. Local unsynced entities are stored in Drift and survive app restarts.
2. Uninstall clears local Drift data unless already synced remotely.
3. Remote persistence requires successful entity sync + upload contract completion.

Validation notes:
- Pending explicit uninstall/reinstall check capture.

---

## 5. Residual Risks

1. Full app-wide global offline replay queue remains future work (`core/network/offline_queue.dart` still stubbed).
2. Dependency-aware prioritization policy (trip-first scheduling optimization) is not yet implemented.
3. Read-path parity is incomplete until Trips/Feed are fully backend-driven and validated end-to-end.
4. Manual matrix evidence is still required to convert this report to final RC sign-off.

---

## 6. Current Integration Gaps (Discovered During RC)

1. Trips tab was wired to `MockTripsApi`, so list/delete did not consistently represent backend state.
2. Trip delete in Trips module removed local row first and swallowed remote delete failures (fire-and-forget), which could leave backend trip undeleted.
3. Feed repository was mock-first (`MockFeedData`) and could not surface previously created backend trips for the signed-in user.

---

## 7. Remediation Batch In Progress

1. Trips provider switched from mock API to `OpenApiTripsApi` (auth-backed).
2. Trips repository delete flow hardened:
   - local delete kept,
   - backend delete required for synced rows,
   - local rollback on remote delete failure.
3. Feed repository switched to backend trip list API as primary source with Drift cache retention.

Validation to run after this batch:
1. New account: create trip + places -> confirm backend rows.
2. Trips screen: delete trip -> confirm `DELETE /api/v1/trips/{id}` and backend row removal.
3. Relaunch/login: confirm backend trips hydrate into Trips/Feed views.
4. Re-run Phase 5 targeted test suite and manual matrix rows impacted by this change.

---

## 8. RC Decision

Current decision: `PENDING`  

Go criteria:
1. All automated validations in Section 2 are green.
2. Manual matrix scenarios in Section 3 are validated.
3. No critical data-loss or duplicate-processing defects are open.

No-go criteria:
1. Any stop-the-line issue from Phase 5 checklist is reproducible.
2. Queue/idempotency regression or unresolved dependency-gating defect remains.
