# Export Runbook (Phase 6D)

Last Updated: 2026-03-08
Owner: Export Platform Team
Scope: backend export API + export worker + video-renderer service + storage/share controls

## 1. Purpose

This runbook defines how to operate, diagnose, and recover the export pipeline in development and production-like environments.

## 2. Runtime Topology

- API: FastAPI (`backend/app/main.py`)
- Worker: durable export loop (`backend/app/workers/export_worker.py`)
- Renderer: Node service (`video-renderer/src/server.js`)
- Storage: private export artifacts (S3/Supabase depending on backend mode)

Control flow:
1. app submits export job (`POST /api/v1/trips/{trip_id}/export`)
2. worker claims queued jobs and runs stages
3. worker calls renderer HTTP API (`/api/v1/render`)
4. worker persists status and artifact metadata
5. client polls export status and requests download/share URL

## 3. Required Environment

Minimum critical vars:
- `RENDER_BACKEND` (`local` or `lambda`)
- `RENDERER_URL`
- `EXPORT_WORKER_POLL_SECONDS`
- `EXPORT_WORKER_STALE_SECONDS`
- `EXPORT_RENDER_POLL_SECONDS`

Lambda mode:
- `AWS_REGION`
- `LAMBDA_FUNCTION_NAME`
- `LAMBDA_SERVE_URL`
- `LAMBDA_OUTPUT_BUCKET`

Storage and delivery:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Queue controls:
- `EXPORT_MAX_CONCURRENT_PER_USER`
- `EXPORT_GLOBAL_QUEUE_CAP`

## 4. Start and Restart Procedures

## 4.1 Local Process Mode

Terminal 1:
```bash
cd backend
.\venv\Scripts\python.exe -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Terminal 2:
```bash
cd backend
.\venv\Scripts\python.exe -m app.workers.export_worker
```

Terminal 3:
```bash
cd video-renderer
npm run dev
```

## 4.2 Docker Compose Mode

```bash
docker compose -f docker-compose.dev.yml up --build
```

## 4.3 Safe Restart Order

1. Restart renderer
2. Restart worker
3. Restart API

Reason: worker depends on renderer availability; API can accept jobs after worker is healthy.

## 5. Health Checks

## 5.1 API

```bash
curl -i http://localhost:8000/health
```

## 5.2 Renderer

```bash
curl -i http://localhost:3100/health
```

## 5.3 Worker

Worker has no HTTP health endpoint. Use log heartbeat and DB movement:
- verify new queued jobs transition to processing
- watch tagged logs: `[EXPORT_JOB]`, `[EXPORT_RENDER]`, `[EXPORT_UPLOAD]`, `[EXPORT_FAIL]`, `[EXPORT_COST]`

## 6. Operational Playbooks

## 6.1 Job Stuck in `queued`

Checks:
1. worker process is running
2. global cap/per-user cap not blocking admission
3. `next_attempt_at` has elapsed

Actions:
1. restart worker
2. inspect worker logs for claim errors
3. verify DB row eligibility (`status='queued'` and `next_attempt_at <= now`)

## 6.2 Job Stuck in `processing` or `cancel_requested`

Checks:
1. renderer service health
2. network path from worker to renderer
3. stale timeout settings

Actions:
1. restart renderer then worker
2. allow `recover_orphaned_jobs` to settle stale rows on worker boot
3. verify row transitions (`processing/cancel_requested -> queued/failed/canceled`)

## 6.3 Repeated `render_crash` or `lambda_throttle`

Checks:
1. AWS Lambda concurrency metrics
2. `framesPerLambda` setting in renderer backend
3. retry behavior in worker logs

Actions:
1. reduce fan-out (`framesPerLambda` up, or account concurrency increase)
2. keep retry backoff defaults (30/120/480)
3. rerun smoke export and capture evidence in handoff report

## 6.4 AccessDenied / ACL / S3 output errors

Checks:
1. renderer role policy includes object write to output bucket path
2. bucket ownership mode and ACL behavior are compatible
3. output key path is under configured private prefix

Actions:
1. fix IAM policy
2. apply non-ACL write mode
3. rerun single export smoke test

## 6.5 Share URL revoke incident

Checks:
1. share token record exists
2. token is not revoked
3. trip privacy still allows sharing

Actions:
1. set token `revoked_at` for immediate revoke
2. verify subsequent share access returns forbidden
3. confirm no long-lived raw presigned URL exposure in API response

## 7. Manual Recovery SQL (Use Carefully)

These are emergency operations. Run only with explicit incident tracking.

Mark a single job as failed:
```sql
update export_jobs
set status='failed',
    stage=null,
    completed_at=now(),
    error_code='manual_recovery',
    error_message='Manually failed by on-call'
where id = :job_id;
```

Requeue a stuck processing job:
```sql
update export_jobs
set status='queued',
    stage=null,
    progress=0.0,
    worker_session_id=null,
    renderer_job_id=null,
    next_attempt_at=now()
where id = :job_id
  and status in ('processing', 'cancel_requested');
```

## 8. Monitoring and Alerts

Track:
- queue wait time
- stage duration
- success/failure/cancel rate
- lambda throttle/error count
- artifact size distribution

Suggested alerts:
- high failure rate over rolling 15m
- repeated `worker_timeout`
- sustained queue backlog
- surge in `lambda_throttle`

## 9. Escalation

Escalate immediately when:
- duplicate artifacts are generated for one job
- private exports become publicly accessible
- jobs remain stuck without reaper/retry path
- major regressions appear in media queue or entity sync flows

## 10. Post-Incident Template

Record in handoff report:
1. user impact
2. timeline (UTC)
3. root cause
4. fix and rollback option
5. prevention action and owner

