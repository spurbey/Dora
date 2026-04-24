# Advisory Server Debug Runbook (SSM-First, Server-Only)

Last validated: 2026-04-24

## Purpose

This runbook is the canonical way to debug Dora advisory behavior on the real server stack.

It exists to prevent repeated dead ends where agents:
- run local commands and assume infra is broken,
- try SSH first and fail,
- run ad-hoc commands without reproducible capture of worker + DB state.

Use this for:
- advisory worker/cycle worker behavior,
- live trip advisory triggering,
- scrape stage failures,
- cadence/requeue bugs,
- push/cache runtime checks.

## Scope And Rules

- Scope is production-like server runtime only.
- Do not use local Docker logs to diagnose server incidents.
- Do not print secrets in terminal output or docs.
- Prefer SSM over SSH.
- Treat container names as dynamic (Coolify suffix changes per deploy).

## Known Server Targets

From `docs/scraping/hosted-chromium-cdp-setup.md`:
- EC2 instance: `i-09e5067742dd683c4`
- Public IP: `13.234.231.218`
- Coolify UI: `http://13.234.231.218:8000`

## Prerequisites

- AWS CLI installed locally.
- IAM user/role allowed for `ssm:SendCommand`, `ssm:GetCommandInvocation`, `ec2:DescribeInstances`.
- Valid AWS credentials (typically loaded from `backend/.env` on this machine).

## 0) Server-Only Guardrail (Mandatory)

Before any diagnosis, explicitly confirm:
- target instance is `Online` in SSM,
- advisory containers are running there.

If you cannot confirm those two, stop and fix access first.

## 1) Load AWS Credentials And Identity Check

PowerShell (local machine):

```powershell
Get-Content 'backend/.env' | ForEach-Object {
  if ($_ -match '^AWS_ACCESS_KEY_ID=(.+)$') { $env:AWS_ACCESS_KEY_ID=$Matches[1] }
  elseif ($_ -match '^AWS_SECRET_ACCESS_KEY=(.+)$') { $env:AWS_SECRET_ACCESS_KEY=$Matches[1] }
  elseif ($_ -match '^AWS_DEFAULT_REGION=(.+)$') { $env:AWS_DEFAULT_REGION=$Matches[1] }
  elseif ($_ -match '^AWS_REGION=(.+)$') { $env:AWS_REGION=$Matches[1] }
}
aws sts get-caller-identity --output json
```

Expected: valid account/arn JSON.

## 2) Verify SSM Connectivity

```powershell
aws ssm describe-instance-information `
  --filters "Key=InstanceIds,Values=i-09e5067742dd683c4" `
  --query "InstanceInformationList[0].{InstanceId:InstanceId,PingStatus:PingStatus,AgentVersion:AgentVersion}" `
  --output json
```

Expected: `PingStatus: Online`.

## 3) Prefer SSM Over SSH

SSH to this host may timeout on port 22 from current networks. Use SSM command execution instead.

Optional reachability checks:

```powershell
curl.exe -I http://13.234.231.218:8000
```

Expected: HTTP response (often `302 /login`).

## 4) Build A Reusable SSM Command Pattern

Create payload file:

```powershell
@'
{
  "DocumentName": "AWS-RunShellScript",
  "Comment": "advisory diagnostics",
  "InstanceIds": ["i-09e5067742dd683c4"],
  "Parameters": {
    "commands": [
      "set -e",
      "date -Is",
      "docker ps --format '{{.Names}} {{.Status}}' | egrep 'api-|advisory_worker|advisory_cycle_worker|advisory_ignore_sweep_worker' || true"
    ]
  }
}
'@ | Set-Content -Encoding ascii temp-ssm-advisory-diag.json
```

Send command:

```powershell
$cmdId = aws ssm send-command `
  --cli-input-json file://temp-ssm-advisory-diag.json `
  --query 'Command.CommandId' --output text
$cmdId
```

Get result:

```powershell
aws ssm get-command-invocation `
  --command-id $cmdId `
  --instance-id i-09e5067742dd683c4 `
  --output json
```

## 5) Discover Containers Reliably

On host (inside SSM command list):

```bash
API=$(docker ps --format '{{.Names}}' | grep '^api-' | head -n 1 || true)
ADV=$(docker ps --format '{{.Names}}' | grep 'advisory_worker' | head -n 1 || true)
CYCLE=$(docker ps --format '{{.Names}}' | grep 'advisory_cycle_worker' | head -n 1 || true)
SWEEP=$(docker ps --format '{{.Names}}' | grep 'advisory_ignore_sweep_worker' | head -n 1 || true)
echo "API=$API ADV=$ADV CYCLE=$CYCLE SWEEP=$SWEEP"
```

Do not hardcode full Coolify container names.

## 6) Pull Worker Logs (Recent Window)

```bash
docker logs --since 20m "$CYCLE" 2>&1 | tail -n 120
docker logs --since 20m "$ADV" 2>&1 | tail -n 200
```

Look for:
- `mark_cycle_outcome(...)` errors,
- scraper skip statuses,
- OpenRouter non-200 spikes,
- repeated loop/tick errors.

## 7) Query DB State From API Container

Use `docker exec "$API" python -c ...` for compact, reliable output:

```bash
docker exec "$API" python -c "from app.database import SessionLocal; from sqlalchemy import text; import json; t='YOUR_TRIP_UUID'; db=SessionLocal(); b=db.execute(text('select trip_id::text,lifecycle_state,mode,cadence_seconds,last_cycle_at,next_eligible_at from trip_advisory_state where trip_id=:t'), {'t': t}).mappings().first(); j=db.execute(text(\"select id::text,status,job_type,stage,created_at,completed_at,coalesce((scrape_plan->'_delivery'->>'count')::int,0) as delivered_count from advisory_jobs where trip_id=:t order by created_at desc limit 12\"), {'t': t}).mappings().all(); print('BRAIN', json.dumps(dict(b) if b else None, default=str)); print('JOBS', json.dumps([dict(r) for r in j], default=str)); db.close()"
```

## 8) Controlled Reproduction Workflow

When behavior is unclear:
- create a fresh server trip using backend service path,
- start live session (`sessions:start` path),
- seed route points in `trip_route_raw_point`,
- force `next_eligible_at <= now()`,
- run cycle once and inspect job evolution.

This is the fastest deterministic path to isolate cycle/worker/state bugs.

## 9) Known Access/Infra Problems We Hit And Fixes

| Problem | Symptom | Root Cause | Fix |
|---|---|---|---|
| AWS in sandbox fails | `Failed to connect to proxy URL: http://127.0.0.1:9` | sandbox/proxy boundary | run command with escalated permissions |
| STS/Auth fails | missing identity output | creds not loaded in shell | load AWS vars from `backend/.env` before CLI call |
| SSH fails | timeout to `13.234.231.218:22` | network path/security group limitations | switch to SSM-only flow |
| SSM payload rejected | `Invalid JSON received` | UTF encoding/quoting issues | write payload with `-Encoding ascii`; simplify quoting |
| SSM command runs but expected block missing | no DB output from heredoc | complex nested quoting in command list | use `python -c` one-liner or smaller scripts |

## 10) What To Avoid

- Do not conclude "infra is broken" from local-only runs.
- Do not rely on stale temp log files as live truth.
- Do not paste AWS secrets or tokens into shared logs/docs.
- Do not depend on SSH as primary access path.
- Do not hardcode Coolify container names.
- Do not run diagnosis without DB state snapshot (`trip_advisory_state` + `advisory_jobs`).

## 11) Quick Incident Checklist

1. Verify AWS identity + SSM online.
2. Confirm advisory containers are up.
3. Pull 20m cycle/advisory logs.
4. Snapshot `trip_advisory_state` + latest `advisory_jobs`.
5. Check cadence progression (`last_cycle_at`, `next_eligible_at`) against expected class cadence.
6. Check stage outcomes (`gmaps status`, delivery count, push throttle behavior).
7. Record exact UTC timestamps and trip IDs in notes.
8. Only then classify as app bug vs infra issue.

