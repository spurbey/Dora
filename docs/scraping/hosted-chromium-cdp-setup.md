# Hosted Chromium CDP Setup (EC2 + Coolify) for Advisory GMaps Scraping

## Purpose
This document captures the production-style setup used to run Google Maps scraping for the advisory pipeline using a self-hosted Chromium CDP endpoint on AWS EC2.

It replaces dependency on BrightData Scraping Browser for the GMaps stage while keeping backend scraper code unchanged.

---

## Current deployed environment (as of 2026-04-19)

- EC2 instance (active): `i-09e5067742dd683c4`
- Public IP: `13.234.231.218`
- Security Group: `sg-06320d74ee9699ce1`
- Region: `ap-south-1`
- Instance type: `t3.medium`
- Root volume: `60 GB gp3`
- Coolify UI: `http://13.234.231.218:8000`
- Chrome CDP endpoint: `http://13.234.231.218:9222`
- Old/broken node terminated: `i-0f3ba5a87dbb310ce`

Note: treat these IDs as operational state, not hardcoded constants.

---

## Architecture

### End-to-end scraping path (backend advisory flow)

1. `advisory_worker` runs `gmaps_scrape` stage.
2. `gmaps_scraper.py` opens Playwright and calls `chromium.connect_over_cdp(BRIGHTDATA_WS_ENDPOINT)`.
3. Backend now points `BRIGHTDATA_WS_ENDPOINT` to our EC2 CDP endpoint (`http://13.234.231.218:9222`).
4. On EC2:
   - `chrome-cdp.service` runs headed Chrome via `xvfb`.
   - `chrome-cdp-proxy.service` exposes local CDP externally on `:9222`.
5. Scraper returns POIs and review snippets to advisory worker.
6. Ranker + delivery continue unchanged.

### Sequence (logical)

`advisory_worker` -> `gmaps_scraper` -> `EC2:9222 (socat)` -> `localhost:9223 (Chrome DevTools)` -> `google.com/maps`

---

## Why this works with existing backend code

`backend/app/services/scrapers/gmaps_scraper.py` already uses CDP. The config key is named `BRIGHTDATA_WS_ENDPOINT`, but the implementation accepts any CDP endpoint reachable by Playwright `connect_over_cdp`.

No code rewrite is required to switch from BrightData to self-hosted CDP. Only endpoint/config and infrastructure changed.

---

## Infrastructure setup performed

## 1) AWS prerequisites

- AWS CLI configured with valid keys.
- Key pair available for manual SSH (`connection2` in this setup).
- Existing VPC/subnet reused.

## 2) IAM for SSM (so server can be managed even if SSH is unstable)

Created:
- Role: `DoraEc2SsmRole` with trust policy for EC2.
- Attached policy: `AmazonSSMManagedInstanceCore`.
- Instance profile: `DoraEc2SsmProfile`.

Attached instance profile to the EC2 instance.

## 3) Security Group rules

Inbound configured:
- `22/tcp` from admin IP (`223.233.84.2/32`)
- `8000/tcp` from admin IP (`223.233.84.2/32`) for Coolify setup
- `9222/tcp` from admin IP (`223.233.84.2/32`) for backend CDP access
- `80/tcp`, `443/tcp` from `0.0.0.0/0` (optional for public apps behind Coolify)

## 4) Coolify install

Installed on EC2 and verified containers healthy:
- `coolify`
- `coolify-db`
- `coolify-redis`
- `coolify-realtime`

## 5) Headed Chrome CDP services

Installed packages:
- `google-chrome-stable`
- `xvfb`
- `socat`

Systemd units:

- `/etc/systemd/system/chrome-cdp.service`
  - Runs Chrome headed in Xvfb.
  - Uses local devtools port `9223`.
- `/etc/systemd/system/chrome-cdp-proxy.service`
  - Proxies `0.0.0.0:9222` -> `127.0.0.1:9223`.

This split avoids Chrome’s local-only binding limitation for devtools in recent versions.

---

## Backend configuration

Updated `backend/.env`:

```env
BRIGHTDATA_WS_ENDPOINT=http://13.234.231.218:9222
```

Important:
- Keep `ADVISORY_GMAPS_LOCAL_DEBUG=false` in backend for server mode.
- Restart backend/advisory worker after `.env` change.

---

## Verification evidence from this setup

Backend venv test (direct invocation of production scraper module) returned:

- `POIS 3`
- `REVIEWS 3`
- Review text content extracted successfully.

This validated:
- backend scraper code path
- remote CDP connectivity
- actual Google Maps review extraction

---

## Operations runbook

## Check health (on EC2 via SSM)

```bash
systemctl is-active chrome-cdp.service
systemctl is-active chrome-cdp-proxy.service
ss -ltnp | egrep '9222|9223'
curl -s http://127.0.0.1:9223/json/version
docker ps
```

## Restart scraping browser services

```bash
sudo systemctl restart chrome-cdp.service
sudo systemctl restart chrome-cdp-proxy.service
```

## Backend-side quick probe

```powershell
Invoke-WebRequest -UseBasicParsing http://13.234.231.218:9222/json/version
```

Expected: HTTP 200 with JSON including Chrome version and devtools metadata.

---

## Failure modes and fixes

- Symptom: `connect_over_cdp` failures / timeout.
  - Check SG rule for `9222` includes backend machine IP.
  - Check `chrome-cdp-proxy.service` active.

- Symptom: EC2 reachable on TCP but no protocol response.
  - Use SSM session/commands.
  - Check disk pressure (`df -h`), service states, and restart services.

- Symptom: scraper returns zero POIs.
  - Inspect `advisory_worker` logs for query context.
  - Validate target locality and request quality.
  - Retry with another locality to rule out transient Google UI response.

---

## Security notes

- Never keep broad `22/tcp` open globally.
- Keep `9222/tcp` restricted to trusted backend runner IP(s) only.
- Rotate exposed AWS keys/secrets if ever shared in plain text.
- Keep `connection2.pem` out of git and with strict file permissions.

---

## Cost notes

- This self-hosted model removes per-request BrightData browser cost for GMaps CDP.
- New costs are EC2 + bandwidth + maintenance.
- Keep instance sizing/cadence aligned with advisory cycle load.

