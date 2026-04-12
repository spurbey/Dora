# Trip Publish Spec (V2)

Status: Draft for implementation lock
Version: v2.2
Last updated: 2026-04-12
Owner: Flutter editor team + backend publish team

## 1. Purpose

This spec defines explicit publish/save for V2 trips.

It covers:

1. publish trigger and uniqueness,
2. local payload assembly,
3. idempotent publish worker behavior,
4. backend publish contract usage,
5. editor UX and retry semantics.

## 2. References

1. [Master Blueprint](./master-blueprint.md)
2. [Local Journal and Resolver Spec](./local-journal-and-resolver-spec.md)
3. [Local Timeline Compiler Spec](./local-timeline-compiler-spec.md)
4. [Session Commit Worker Spec](./session-commit-worker-spec.md)
5. [Backend Ingest and Projection Spec](./backend-ingest-and-projection-spec.md)

## 3. Trigger Rules

Publish job may be created only when:

1. user explicitly taps save/upload,
2. no active publish exists for the trip (`status in {started, failed_retryable}` on backend and no local active publish job).

No automatic publish on background/close.

## 4. Local Publish Job

`trip_publish_job` states:

1. `publish_pending`
2. `publishing`
3. `publish_failed_retryable`
4. `published`

Rules:

1. payload snapshot is frozen at `publish:start` request creation,
2. retries must reuse same snapshot hash and idempotency key,
3. if local content changes after failure, create a new publish job.

## 5. Payload Contract (Client Side)

Top-level payload shape:

1. `schema_version`
2. `client_job_id` (`publish_job_id`)
3. `trip_local_id`
4. `server_trip_id` (if known)
5. `trip_editor_metadata`
6. `sessions[]`
7. `events[]`
8. `media[]`
9. `route_points[]`
10. `snapshot_digest`
11. `media_manifest[]`
12. `media_manifest_digest`

Rules:

1. raw journal content is canonical,
2. manual-lock and decision source must be preserved exactly,
3. deterministic ordering is required before hashing.

## 6. Endpoint Usage

Client calls in order:

1. `publish:start`
2. media upload (using returned targets)
3. `publish:media-complete`
4. `publish:payload-chunk`
5. `publish:commit`

Locked substep payload scope fields:

1. `publish:media-complete` includes `publish_token`, `client_job_id`, `schema_version`.
2. `publish:payload-chunk` includes `publish_token`, `client_job_id`, `schema_version`.
3. `publish:commit` includes `publish_token`, `client_job_id`, `schema_version`.

Locked idempotency key formats:

1. `publish:start:{trip_id}:{publish_job_id}:{snapshot_digest}`
2. `publish:media-complete:{trip_id}:{publish_job_id}:{media_manifest_digest}`
3. `publish:payload-chunk:{trip_id}:{publish_job_id}:{chunk_index}:{chunk_content_hash}`
4. `publish:commit:{trip_id}:{publish_job_id}:{snapshot_digest}:{accepted_chunks_digest}`

## 7. Error/Retry Policy

Retryable:

1. network transient,
2. `429`, transient `5xx`,
3. backend `503` retryable publish failure.

Terminal:

1. `400`, `403`, `404`,
2. `409` idempotency conflict/active publish conflict,
3. `413`, `422` validation/size/hash failures.

Backoff:

1. 15s,
2. 60s,
3. 180s,
4. max 3 auto attempts then manual retry CTA.

## 8. Editor UX Contract

1. publish chip states:
   - `Not published`
   - `Publishing`
   - `Publish failed - retry`
   - `Published`
2. local timeline editing must remain responsive during publish.
3. publish failure never rolls back local timeline/editor state.
4. stop does not imply uploaded; publish success owns upload-success semantics.

## 9. Consistency Guarantees

1. local timeline is runtime source on current device,
2. publish success updates server canonical snapshot,
3. cross-device reads come from server projection after commit.

## 10. Observability

Required metrics/logs:

1. `trip_publish_job_created`
2. `trip_publish_started`
3. `trip_publish_completed`
4. `trip_publish_failed`
5. retry counts and latency

## 11. Acceptance Criteria

1. one publish job can be replayed safely without duplicate corruption,
2. same key + changed fingerprint returns conflict,
3. publish failure preserves local data and actionable retry,
4. second device reads published projection accurately.
