# Server Testing From Terminal (Beginner Guide)

Last updated: 2026-04-27

This guide explains, in plain language, how to run commands from your local terminal on the Dora server, how to debug failures, and how to run safe scrape checks with minimal bandwidth.

It is written for "zero server knowledge" users.

---

## 1) What You Are Actually Doing

When you run a server test from your laptop, the flow is:

1. You type a command in local PowerShell.
2. AWS CLI sends that request to AWS Systems Manager (SSM).
3. SSM sends your script to the EC2 instance.
4. The SSM Agent running on EC2 executes that script.
5. The script output is stored by SSM.
6. You fetch output back to your terminal.

You are not SSH-ing directly. You are using AWS-managed remote command execution.

---

## 2) Core Concepts (Simple Definitions)

`EC2 instance`:
The server machine in AWS.

`SSM`:
AWS service that can run commands remotely on EC2.

`SSM payload`:
A JSON file describing what to run on the server.

`AWS-RunShellScript`:
The SSM document that runs shell commands on Linux EC2.

`CommandId`:
A unique ID returned by AWS for one remote run.

`docker exec`:
Runs a command inside a running container (for example, the `api-*` container).

---

## 3) One-Time Prerequisites

You need all of these before any server test works:

1. AWS CLI installed locally.
2. Valid AWS credentials in your local shell.
3. Correct AWS region (`ap-south-1` in this project).
4. EC2 instance online in SSM.
5. Server containers running (for app-level checks).

Current known server target:

- Instance ID: `i-09e5067742dd683c4`

---

## 4) Step 1: Load AWS Credentials Locally

Run this in local PowerShell:

```powershell
Get-Content 'backend/.env' | ForEach-Object {
  if ($_ -match '^AWS_ACCESS_KEY_ID=(.+)$') { $env:AWS_ACCESS_KEY_ID=$Matches[1] }
  elseif ($_ -match '^AWS_SECRET_ACCESS_KEY=(.+)$') { $env:AWS_SECRET_ACCESS_KEY=$Matches[1] }
  elseif ($_ -match '^AWS_DEFAULT_REGION=(.+)$') { $env:AWS_DEFAULT_REGION=$Matches[1] }
  elseif ($_ -match '^AWS_REGION=(.+)$') { $env:AWS_REGION=$Matches[1] }
}
if (-not $env:AWS_DEFAULT_REGION) { $env:AWS_DEFAULT_REGION='ap-south-1' }
aws sts get-caller-identity --output json
```

Why each line exists:

1. Reads `backend/.env`.
2. Extracts AWS key id and secret into shell env vars.
3. Sets region if not already set.
4. Calls STS identity API to confirm auth works.

If this fails, stop and fix credentials first.

---

## 5) Step 2: Verify SSM Connectivity

```powershell
aws --region ap-south-1 ssm describe-instance-information `
  --filters "Key=InstanceIds,Values=i-09e5067742dd683c4" `
  --query "InstanceInformationList[0].{InstanceId:InstanceId,PingStatus:PingStatus}" `
  --output json
```

You want `PingStatus: Online`.

If not online, any payload run will fail.

---

## 6) What Is A Payload JSON (Line By Line)

Example payload:

```json
{
  "DocumentName": "AWS-RunShellScript",
  "Comment": "quick health check",
  "InstanceIds": ["i-09e5067742dd683c4"],
  "Parameters": {
    "commands": [
      "set -e",
      "date -Is",
      "docker ps --format '{{.Names}} {{.Status}}' | head -n 20"
    ]
  }
}
```

Meaning of each field:

`DocumentName`:
Which AWS runner to use. Here: Linux shell script.

`Comment`:
Human label only. Useful in logs.

`InstanceIds`:
Which server to run on.

`Parameters.commands`:
Array of shell lines executed in order.

Meaning of each command line:

`set -e`:
Stop script on first error. Prevents silent partial runs.

`date -Is`:
Print server timestamp for traceability.

`docker ps ...`:
Shows running containers.

---

## 7) Run A Payload End-To-End

1. Save payload locally, for example `temp-ssm-test.json`.
2. Send command.
3. Wait.
4. Read output.

```powershell
$cmdId = aws --region ap-south-1 ssm send-command `
  --cli-input-json file://temp-ssm-test.json `
  --query 'Command.CommandId' --output text

aws --region ap-south-1 ssm wait command-executed `
  --command-id $cmdId `
  --instance-id i-09e5067742dd683c4

aws --region ap-south-1 ssm get-command-invocation `
  --command-id $cmdId `
  --instance-id i-09e5067742dd683c4 `
  --output json
```

Why this 3-step pattern is needed:

1. `send-command` starts async execution.
2. `wait` blocks until finished.
3. `get-command-invocation` fetches stdout/stderr.

---

## 8) Contacting Server Containers (Why `docker exec`)

Server has multiple containers with dynamic names. You first discover container name, then run inside it.

Example:

```bash
API=$(docker ps --format '{{.Names}}' | grep '^api-' | head -n 1)
echo "API=$API"
docker exec "$API" python -c "print('hello from api container')"
```

Why:

1. App code, env vars, dependencies are inside container, not host.
2. Running DB queries typically requires app Python env inside `api-*`.

---

## 9) Debugging Pattern You Should Always Follow

Always debug in this order:

1. Auth check (`aws sts get-caller-identity`).
2. SSM online check (`PingStatus`).
3. Container presence check (`docker ps`).
4. Relevant logs (`docker logs --since`).
5. DB state snapshot (through `docker exec "$API" python -c ...`).
6. Only then conclude app bug vs infra issue.

This avoids wrong conclusions from local-only errors.

---

## 10) Minimal Scrape Test Pattern (Low Bandwidth)

Goal:
Verify proxy/access without running deep crawl.

Use 1-2 tiny requests:

1. Geo endpoint check (proxy health).
2. One target URL check (status + first bytes).

Example Linux shell lines inside payload:

```bash
UA="Mozilla/5.0 (X11; Linux x86_64)"
URL="https://old.reddit.com/r/IndiaTravel/search?q=goa&restrict_sr=on&sort=relevance&t=year"
STATUS=$(curl -sS --max-time 25 -A "$UA" --proxy "$PROXY_HOST" --proxy-user "$PROXY_USER" --cacert /tmp/brightdata_new_ca.crt -o /tmp/out.html -w "%{http_code}" "$URL" || true)
echo "HTTP_CODE:$STATUS"
head -c 800 /tmp/out.html || true
```

Why this is low bandwidth:

1. Single URL call.
2. No pagination.
3. No browser automation.
4. Print only first bytes.

---

## 11) Why Some Runs Show Different Status Codes

Different code paths can produce different results:

1. `403` from target site means request reached site but was blocked by target rules.
2. `402 bad_endpoint` from proxy provider means proxy layer rejected that endpoint/mode.
3. `200` means request succeeded.

Intermittent differences can happen due:

1. Different URL path (HTML page vs JSON endpoint).
2. Different proxy config flags.
3. Different SSL cert usage.
4. Rate limits or provider policy changes.

Always log:

1. Exact URL.
2. Exact proxy host/port mode.
3. Exact command used.
4. First 200-500 bytes of response.

---

## 12) Common Errors And What They Mean

`Failed to connect to proxy URL: http://127.0.0.1:9`:
Sandbox/proxy boundary issue. Run with proper non-sandbox permissions in agent context.

`NoRegion`:
AWS region missing. Set `ap-south-1`.

`NoCredentials`:
AWS creds not loaded in current shell.

`Invalid JSON received`:
Payload formatting/encoding issue. Save with ASCII and re-check quotes.

`python: not found` on host:
Your script assumed Python on host. Use shell-only formatting or run Python inside app container.

---

## 13) Safe Handling Rules (Very Important)

1. Never commit payload files that contain credentials.
2. Never paste full secrets in shared chats/docs.
3. Delete temp payloads after run.
4. Prefer SSM over SSH for repeatable ops.
5. Avoid hardcoded container suffixes.

Cleanup example:

```powershell
Remove-Item -LiteralPath temp-ssm-test.json -ErrorAction SilentlyContinue
```

---

## 14) Reusable Starter Templates

Template A: container health payload

```json
{
  "DocumentName": "AWS-RunShellScript",
  "Comment": "health-check",
  "InstanceIds": ["i-09e5067742dd683c4"],
  "Parameters": {
    "commands": [
      "set -e",
      "date -Is",
      "docker ps --format '{{.Names}} {{.Status}}' | head -n 50"
    ]
  }
}
```

Template B: app DB snapshot payload

```json
{
  "DocumentName": "AWS-RunShellScript",
  "Comment": "trip brain snapshot",
  "InstanceIds": ["i-09e5067742dd683c4"],
  "Parameters": {
    "commands": [
      "set -e",
      "API=$(docker ps --format '{{.Names}}' | grep '^api-' | head -n 1)",
      "docker exec \"$API\" python -c \"from app.database import SessionLocal; from sqlalchemy import text; db=SessionLocal(); print(db.execute(text('select now()')).scalar()); db.close()\""
    ]
  }
}
```

---

## 15) Quick Checklist Before Every Run

1. Did I load AWS credentials in this shell?
2. Did I verify SSM is online?
3. Is my payload ASCII-safe and valid JSON?
4. Do commands avoid exposing secrets?
5. Am I testing minimal scope first (small probe)?
6. Did I save command output with timestamp and command id?
7. Did I clean temporary payload files afterward?

---

## 16) Where This Guide Fits

Use this guide first.

Then use:

1. `docs/deployment/advisory-server-debug-runbook.md` for advisory-specific diagnostics.
2. `docs/aws/ec2-terminal-agent-skill.md` for deeper AWS infrastructure operations.

