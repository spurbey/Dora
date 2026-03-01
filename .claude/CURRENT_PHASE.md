# Current Phase: Phase 6C - AWS Lambda Scale (6C-1 In Progress)

Phase: Flutter-Phase-6C | Status: 6C-1 complete in local diff, 6C-2 started

## Active Branch
- `phase-6-video-export`

## Completed Before 6C
- 6A control plane and Flutter wiring delivered.
- 6B local Remotion renderer and Flutter export UX delivered.
- 6B evidence report completed.
- Phase docs synced for 6C kickoff:
  - `flutter/docs/phases/Phase-6-PRD.md`
  - `flutter/docs/phases/Phase-6-Execution-Checklist.md`
  - `flutter/docs/handoffs/phase6-contract-freeze.md` (6C addendum)
  - `flutter/docs/handoffs/phase6-rolling-handoff.md`
  - `flutter/docs/handoffs/phase6c-kickoff-procedure.md`

## Frozen 6C Constraints
1. Backend worker uses HTTP renderer adapters only.
2. Node renderer owns `@remotion/lambda` calls.
3. Exact Remotion version pinning is mandatory.
4. Lambda output uses `outName: {bucketName, key}`.
5. `getRenderProgress` uses bucket from `renderMediaOnLambda` response.
6. Cancel semantics follow current worker race model.
7. IAM responsibility is split between renderer runtime and backend runtime.
8. Share-token revocation and `pinned_at` retention wiring are 6D scope.

## Immediate 6C Procedure
1. 6C-1 (local diff complete): Renderer Lambda backend + deploy scripts + exact version pinning.
2. 6C-2 (in progress): Backend integration (`LambdaRemotionRenderer`, caps, S3 output path, presigned download URLs).
3. 6C-3: IAM/lifecycle docs + concurrency/cost evidence report.

## Local Environment Notes
- `npm install` for `video-renderer` is blocked in this sandbox (`ENOTCACHED`), so lockfile refresh must be run in a network-enabled environment.
