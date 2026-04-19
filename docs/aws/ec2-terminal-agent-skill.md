# AWS + EC2 Terminal Agent Skill Playbook

## Purpose
This document gives any new agent/developer a practical, terminal-first skill guide to operate AWS EC2 infrastructure for Dora workloads (especially scraper runtime), using the same patterns proven in this repo.

It focuses on:
- Accessing AWS safely from terminal
- Creating/fixing EC2 hosts
- Security group, IAM profile, and SSM workflows
- Running remote setup commands
- Verifying services
- Recovering from common failures

---

## Scope
- Region used in this project: `ap-south-1` (override if needed)
- Primary runtime pattern: EC2 + SSM + systemd services
- Typical use case: hosted Chromium/CDP runtime for backend scraper

---

## Preconditions

## Local tools required
- `aws` CLI v2
- PowerShell (Windows examples below)
- `rg` (optional but useful for config/file discovery)

## Credentials
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` / `AWS_DEFAULT_REGION`

Do not hardcode secrets in commands or commit keys in git.

---

## Session bootstrap (PowerShell)

Use this pattern at the start of every AWS terminal session:

```powershell
$env:HTTP_PROXY=''; $env:HTTPS_PROXY=''; $env:http_proxy=''; $env:https_proxy=''; $env:NO_PROXY='*'
$env:AWS_ACCESS_KEY_ID=(Get-Content backend/.env | ? { $_ -match '^AWS_ACCESS_KEY_ID=' } | select -First 1).Split('=')[1]
$env:AWS_SECRET_ACCESS_KEY=(Get-Content backend/.env | ? { $_ -match '^AWS_SECRET_ACCESS_KEY=' } | select -First 1).Split('=')[1]
$env:AWS_DEFAULT_REGION=(Get-Content backend/.env | ? { $_ -match '^AWS_REGION=' } | select -First 1).Split('=')[1]
aws sts get-caller-identity
```

Why:
- Clears broken local proxy settings (common source of AWS CLI failure).
- Ensures commands run under expected account/region.

---

## Core terminal skill blocks

## 1) Inspect instance state

```powershell
aws ec2 describe-instances --instance-ids <instance-id> `
  --query "Reservations[0].Instances[0].[State.Name,PublicIpAddress,PublicDnsName,SecurityGroups[0].GroupId,SubnetId]" `
  --output table
```

```powershell
aws ec2 describe-instance-status --instance-ids <instance-id> --include-all-instances `
  --query "InstanceStatuses[0].[InstanceState.Name,SystemStatus.Status,InstanceStatus.Status]" `
  --output table
```

## 2) Check your public IP (for SG pinning)

```powershell
nslookup myip.opendns.com resolver1.opendns.com
```

Use final returned IPv4 for `/32` SG rules.

## 3) Security Group read/update

Read:
```powershell
aws ec2 describe-security-groups --group-ids <sg-id> --query "SecurityGroups[0].IpPermissions" --output json
```

Open a port for one IP:
```powershell
@"
[
  {
    "IpProtocol": "tcp",
    "FromPort": 9222,
    "ToPort": 9222,
    "IpRanges": [{"CidrIp": "223.233.84.2/32", "Description": "CDP access"}]
  }
]
"@ | Set-Content temp-sg-rule.json -Encoding ascii

aws ec2 authorize-security-group-ingress --group-id <sg-id> --ip-permissions file://temp-sg-rule.json
```

Revoke a temporary rule by rule-id:
```powershell
aws ec2 revoke-security-group-ingress --group-id <sg-id> --security-group-rule-ids <sgr-id>
```

## 4) Create new EC2 safely (recommended defaults for scraper host)

- Instance type: `t3.medium`
- Root disk: `60 GB gp3`
- IAM profile: attach at launch
- SG:
  - `22` from admin `/32`
  - `8000` from admin `/32` (Coolify setup)
  - `9222` from backend runner `/32` (CDP)
  - `80/443` as needed

Minimal launch pattern:
```powershell
aws ec2 run-instances `
  --image-id <ami-id> `
  --instance-type t3.medium `
  --key-name <key-name> `
  --subnet-id <subnet-id> `
  --security-group-ids <sg-id> `
  --associate-public-ip-address `
  --iam-instance-profile Name=<profile-name> `
  --block-device-mappings file://temp-block-devices.json `
  --query "Instances[0].[InstanceId,PrivateIpAddress]" --output text
```

Waiters:
```powershell
aws ec2 wait instance-running --instance-ids <instance-id>
aws ec2 wait instance-status-ok --instance-ids <instance-id>
```

---

## IAM + SSM skill (critical)

Use SSM so agents can recover servers even if SSH is broken.

## Create role/profile (one-time account setup)

1. Create EC2 trust role (for SSM)
2. Attach `AmazonSSMManagedInstanceCore`
3. Create instance profile
4. Add role to instance profile

Attach to instance:
```powershell
aws ec2 associate-iam-instance-profile --instance-id <instance-id> --iam-instance-profile Name=<profile-name>
```

Verify association:
```powershell
aws ec2 describe-iam-instance-profile-associations `
  --filters Name=instance-id,Values=<instance-id> `
  --query "IamInstanceProfileAssociations[0].[State,IamInstanceProfile.Arn]" `
  --output table
```

Verify SSM online:
```powershell
aws ssm describe-instance-information `
  --query "InstanceInformationList[?InstanceId=='<instance-id>'].[InstanceId,PingStatus,PlatformName,IPAddress,AgentVersion]" `
  --output table
```

If not online:
- Reboot instance
- Recheck IAM profile attachment
- Check console output for credential/SSM errors

---

## Running remote commands (SSM RunShellScript)

Preferred pattern: write JSON params file and pass with `file://`.

```powershell
@'
{
  "commands": [
    "hostname",
    "whoami",
    "df -h /",
    "docker ps"
  ]
}
'@ | Set-Content temp-ssm-params.json -Encoding ascii

$cmdId = aws ssm send-command `
  --instance-ids <instance-id> `
  --document-name AWS-RunShellScript `
  --comment "health-check" `
  --parameters file://temp-ssm-params.json `
  --query "Command.CommandId" --output text

aws ssm wait command-executed --command-id $cmdId --instance-id <instance-id>
aws ssm get-command-invocation --command-id $cmdId --instance-id <instance-id> `
  --query "[Status,StandardOutputContent,StandardErrorContent]" --output json
```

Notes:
- `AWS-RunShellScript` runs with `/bin/sh` (avoid bash-only syntax like `pipefail` unless invoking bash explicitly).
- Long stdout may break local console encoding; use smaller probes or inspect status first.

---

## Service deployment patterns (EC2)

## Coolify install
```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

Verify:
```bash
docker ps
ss -ltnp | egrep ':8000|:22'
```

## Hosted Chrome CDP (headed via Xvfb)

Use systemd units:
- `chrome-cdp.service`: starts Chrome with local devtools port (e.g., `9223`)
- `chrome-cdp-proxy.service`: exposes public `9222` via `socat` to local `9223`

Why proxy:
- Newer Chrome builds can bind devtools locally despite flags.
- Public endpoint is provided by `socat` while browser remains local.

Service checks:
```bash
systemctl is-active chrome-cdp.service
systemctl is-active chrome-cdp-proxy.service
ss -ltnp | egrep '9222|9223'
curl -s http://127.0.0.1:9223/json/version
```

---

## Backend wiring skill

For scraper backend to use hosted CDP, set:

```env
BRIGHTDATA_WS_ENDPOINT=http://<ec2-public-ip>:9222
```

Then restart backend/advisory worker.

Validation:
```powershell
Invoke-WebRequest -UseBasicParsing http://<ec2-public-ip>:9222/json/version
```

If this works, backend `connect_over_cdp` should connect.

---

## Verification playbook

## Network-level
- `aws ec2 describe-security-groups` confirms ingress rules
- `Invoke-WebRequest http://<ip>:9222/json/version` returns 200

## Backend-level
Run direct scraper call in backend venv and confirm:
- `POIS >= 1`
- `REVIEWS >= 1`
- non-empty review text

## Runtime-level
`advisory_worker` logs show successful `gmaps_scrape` stage and non-empty outputs.

---

## Recovery decision tree

## A) AWS CLI says proxy connection failed
- Clear proxy env vars (`HTTP_PROXY`, `HTTPS_PROXY`, lowercase variants).

## B) TCP connects but SSH hangs/no banner
- Treat as server-side issue, not immediately SG.
- Use SSM path for recovery.
- Check:
  - disk space (`df -h`)
  - sshd status
  - overloaded/broken services

## C) SSM not online
- Ensure IAM instance profile attached.
- Ensure role has `AmazonSSMManagedInstanceCore`.
- Reboot and recheck.

## D) HTTP 9222 times out
- Check `chrome-cdp-proxy.service`
- Check SG rule for caller IP
- Check local Chrome devtools port/service

## E) Instance unhealthy/time-wasting
- Spin up new EC2 with good defaults.
- Reapply known-good setup script.
- Move endpoint and terminate bad node.

---

## Security guardrails

- Keep SSH and CDP restricted to explicit `/32` IPs.
- Revoke temporary broad rules immediately after debugging.
- Do not commit `.pem` keys or AWS credentials.
- Rotate any credential that was pasted/shared in plaintext.
- Prefer SSM over broad SSH exposure.

---

## Cleanup skill

Terminate stale instance:
```powershell
aws ec2 terminate-instances --instance-ids <old-instance-id>
aws ec2 wait instance-terminated --instance-ids <old-instance-id>
```

Delete temp local files used for AWS command JSON payloads.

---

## Agent handoff checklist

Before handoff, document:
- Active instance id/ip/sg
- IAM profile name
- Which ports are open and to whom
- Backend env value currently in use
- Last successful scrape verification result
- What is still pending

