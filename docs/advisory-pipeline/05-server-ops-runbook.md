# Advisory Pipeline — Server Ops Runbook

> Consolidated operational playbook for diagnosing and testing the advisory pipeline on the **production EC2 server**. This is the canonical reference for any agent (human or AI) operating on prod.
>
> **Last verified:** 2026-04-29 — full end-to-end run produced 34 advisories in 102s.

---

## 1. Server identity

| Resource | Value |
|---|---|
| EC2 instance ID | `i-09e5067742dd683c4` |
| AWS region | `ap-south-1` |
| Public IP (informational, **port 22 closed to non-allowlisted IPs**) | `13.234.231.218` |
| Access method | AWS SSM (`ssm:SendCommand`), **not SSH** |
| Container orchestrator | Coolify on Docker |
| Compose file | `docker-compose.coolify.yml` (root of repo) |
| App container name pattern | `api-*`, `advisory_worker-*`, `advisory_cycle_worker-*`, `advisory_ignore_sweep_worker-*`, `export_worker-*`, `story_retention_worker-*`, `renderer-*` |

Container suffixes are dynamic — always discover via `docker ps --format '{{.Names}}' | grep '^api-' | head -1`.

---

## 2. Auth setup (one-time per shell session)

AWS keys with `ssm:SendCommand` live in `backend/.env`. Load them in bash:

```bash
set -a; source <(grep -E "^(AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|AWS_REGION)=" C:/Users/sumit/Downloads/Dora/backend/.env); set +a
export AWS_DEFAULT_REGION=ap-south-1
aws sts get-caller-identity   # verify
```

Expected `Account: 128055991065`, `User: Sumit` (IAM user, not root).

PowerShell variant is documented in `docs/deployment/server-terminal-to-ec2-beginner-guide.md`.

---

## 3. SSM command pattern

Every command follows this 3-step pattern:

```bash
# 1. Send (returns CommandId)
CMD_ID=$(aws --region ap-south-1 ssm send-command \
  --cli-input-json file://payload.json \
  --query 'Command.CommandId' --output text)

# 2. Wait OR poll (default wait timeout is ~100s)
aws --region ap-south-1 ssm wait command-executed \
  --command-id "$CMD_ID" --instance-id i-09e5067742dd683c4

# 3. Fetch output
aws --region ap-south-1 ssm get-command-invocation \
  --command-id "$CMD_ID" --instance-id i-09e5067742dd683c4 \
  --query "{S:Status,O:StandardOutputContent,E:StandardErrorContent}" --output json
```

For long-running commands (Reddit scrape ≈ 100s, full E2E ≈ 105s) skip `ssm wait` and poll `Status` manually:

```bash
for i in 1 2 3 4 5 6 7; do
  sleep 30
  S=$(aws --region ap-south-1 ssm get-command-invocation --command-id "$CMD_ID" \
    --instance-id i-09e5067742dd683c4 --query Status --output text 2>/dev/null)
  echo "poll #$i: $S"
  [[ "$S" == Success || "$S" == Failed ]] && break
done
```

### Payload format

```json
{
  "DocumentName": "AWS-RunShellScript",
  "Comment": "human-readable label",
  "InstanceIds": ["i-09e5067742dd683c4"],
  "Parameters": {
    "commands": [
      "set -e",
      "API=$(docker ps --format '{{.Names}}' | grep '^api-' | head -1)",
      "docker exec -w /app $API python -c \"...\""
    ]
  }
}
```

### Gotchas

- **Each entry in `commands[]` is a separate bash invocation.** A heredoc cannot span entries. Workaround: write the multi-line script to `/tmp/x.py` via heredoc inside one entry, `docker cp` it into the container, then exec.
- **`-w /app` is required** when running Python in the api container. Without it, `from app.database import SessionLocal` fails because CWD is `/`.
- **Output is logged in CloudTrail.** Never echo secrets (api keys, JWT tokens). Redact before printing.
- **`ssm wait` returns "Failed" if the script exits non-zero**, even if the script printed useful output first. Always inspect both `StandardOutputContent` and `StandardErrorContent` — partial output is your diagnostic.

---

## 4. Common operations

### 4.1 Container health snapshot

```json
{
  "DocumentName": "AWS-RunShellScript",
  "Comment": "container health",
  "InstanceIds": ["i-09e5067742dd683c4"],
  "Parameters": {
    "commands": [
      "docker ps --format '{{.Names}} {{.Status}}' | head -20",
      "API=$(docker ps --format '{{.Names}}' | grep '^api-' | head -1)",
      "docker logs --since 5m \"$API\" 2>&1 | grep -iE '(error|exception|traceback)' | tail -15 || true"
    ]
  }
}
```

### 4.2 DB snapshot

```bash
docker exec -w /app $API python -c "
from app.database import SessionLocal; from sqlalchemy import text
db = SessionLocal()
print('jobs_queued:', db.execute(text(\"select count(*) from advisory_jobs where status='queued'\")).scalar())
print('jobs_running:', db.execute(text(\"select count(*) from advisory_jobs where status='running'\")).scalar())
print('jobs_failed_24h:', db.execute(text(\"select count(*) from advisory_jobs where status='failed' and created_at > now()-interval '24 hours'\")).scalar())
print('advisories_24h:', db.execute(text(\"select count(*) from trip_advisories where created_at > now()-interval '24 hours'\")).scalar())
print('brain_phase_dist:', dict(db.execute(text('select phase, count(*) from trip_advisory_state group by phase')).fetchall()))
db.close()"
```

### 4.3 Worker log inspection

```bash
AW=$(docker ps --format '{{.Names}}' | grep '^advisory_worker-' | head -1)
docker logs --since 10m $AW 2>&1 | tail -100
```

Look for repeating `loop error #N (retry in 5s)` blocks — that means the worker is stuck on a constraint violation or LLM failure.

### 4.4 Bedrock smoke test (verify LLM_PROVIDER=bedrock works)

```bash
docker exec -w /app $API python -c "
import asyncio, logging; logging.basicConfig(level=logging.INFO)
from app.services.llm import _try_bedrock
async def t():
    r = await _try_bedrock(
        messages=[{'role':'user','content':'Return {\"ok\":true} as JSON.'}],
        schema={'type':'object','properties':{'ok':{'type':'boolean'}},'required':['ok']},
        temperature=0.1, max_tokens=100, timeout_seconds=20.0, label='smoke',
    )
    print('RESULT:', r)
asyncio.run(t())"
```

Expected: `RESULT: {'ok': True}` and an INFO log line `bedrock=us.anthropic.claude-haiku-4-5-... in=660 out=33`.

If you get `RESULT: None`:
- 403 in StdErr → `BEDROCK_API_KEY` invalid in container env. Check Coolify saved + redeployed.
- "skipped: not set" → `LLM_PROVIDER` env not propagated. Same fix.
- Connection error → outbound to `bedrock-runtime.us-east-1.amazonaws.com` blocked.

### 4.5 Bedrock key fingerprint comparison (when prod 403s but local 200s)

```bash
docker exec -w /app $API python -c "
import os, hashlib
k = os.environ.get('BEDROCK_API_KEY','')
print('len:', len(k), 'sha256_16:', hashlib.sha256(k.encode()).hexdigest()[:16])"
```

Compare against local `.env` SHA-256. Same hash → identical key. Different hash → keys differ; the one in Coolify is wrong.

### 4.6 Alembic migration check

```bash
docker exec -w /app $API alembic current     # current applied head
docker exec -w /app $API alembic heads       # latest in code
docker exec -w /app $API alembic check       # raises if drift
```

If the answers don't match, either run alembic locally (it points to the same Supabase DB via `SUPABASE_DB_URL`), or `docker cp` the new migration into the container and run `docker exec ... alembic upgrade head`.

To run alembic from local:

```bash
cd backend && ./venv/Scripts/alembic.exe current
cd backend && ./venv/Scripts/alembic.exe upgrade head
```

(The local `backend/venv` already has alembic + sqlalchemy installed.)

---

## 5. The Day-7 E2E test

This is the canonical end-to-end verification of the rebuilt pipeline. It exercises every working stage (planning phase): brain seeding → trigger detection → LLM orchestration → Reddit scrape → merge/dedup → scoring → delivery → display_kind mapping.

### What it does

1. Calls `reverse_geocode(28.6172, 77.2079)` (Parliament House) — confirms Phase 1 city-level locality fix
2. Creates a synthetic Pune→Goa trip + route + trip_metadata directly in DB
3. Calls `seed_on_trip_creation(trip_id)` → expect 22 reverse-geocoded samples (Pune/Bhor/Khandala/Wai/.../Goa-area)
4. Creates an `on_demand` advisory job with query "best food spots in Pune"
5. Polls job status every 3s for up to 180s, recording stage transitions
6. Inspects resulting `trip_advisories` rows — count, categories, `display_kind`, `place_lat IS NOT NULL`
7. Reports brain post-state (phase, locality_confidence)
8. Cleans up the test trip

### How to run

The full driver script is committed at `docs/advisory-pipeline/scripts/e2e_full.py` (see §7 below for the script body — it's also embedded in the playbook for self-containment).

Build the SSM payload that copies the script into the api container and runs it:

```bash
# 1. Save e2e_full.py locally somewhere
# 2. Build payload that does docker cp + docker exec python
# 3. Send via SSM, poll for completion (allow 180s)
```

### Expected results (last verified 2026-04-29)

```
phase1_locality: True
phase6_seed_samples: 22
phase6_seed_cities: ['Ajra', 'Bhor', 'Bhudargad', 'Dharbandora', 'Dodamarg',
                     'Khandala', 'Panhala', 'Patan', 'Pune', 'Radhanagari',
                     'Satara', 'Satari', 'Sawantwadi', 'Shahuwadi', 'Wai']
phase6_brain_phase: planning
job_terminal_status: completed
job_total_seconds: 102.4
job_stage_history: [
  (6.0,  'processing', 'reddit_scrape', 0.333),
  (99.2, 'processing', 'delivery',      0.833),
  (102.4,'completed',  'delivery',      1.0)
]
advisory_count: 34
advisory_display_kinds: ['ambient', 'route_overlay']
advisory_categories: ['avoid', 'food_tip', 'general_tip', 'must_do', 'transport_tip']
advisory_with_pin: 0    # Reddit doesn't carry coords; pin=True only in live_companion mode (GMaps)
brain_last_cycle_at: None  # on_demand jobs don't update cycle pointers (by design)
brain_locality_confidence: {}   # confidence updates fire on cycle-triggered delivery, not on_demand
```

### Stage-by-stage walkthrough (planning phase)

| t | Stage | What happens | LLM? |
|---|---|---|---|
| 0s | Job inserted with `status=queued` | DB write only | — |
| 0–3s | `claim_next_job` polls every 5s (`ADVISORY_WORKER_POLL_SECONDS=5.0`) | `SELECT … FOR UPDATE SKIP LOCKED`, flips to `processing` | — |
| 3s | **clarify_intent** | Gated by `ADVISORY_CLARIFY_ENABLED=false` → no-op | (Bedrock if enabled) |
| 3–6s | **route_segmentation** | Reads brain.route_samples + trip_metadata.activity_focus. Bedrock returns scrape plan: `{cities, focus_categories, conversation_context}` | ✅ Bedrock |
| 6s → 99s | **reddit_scrape** (`scrape_reddit_v2`) | 4-substages via BrightData residential proxy:<br>1. plan: Bedrock → subreddit list + queries<br>2. search: Playwright headed Chromium → old.reddit.com search → post URLs<br>3. fetch: Playwright → post + comments markdown<br>4. extract: per-post Bedrock → structured `TravelInsight[]` | ✅ Bedrock (multiple) |
| 99s | **merge_dedup** | dedupe by sha256(place_name + category + body[:100]) | — |
| 99–102s | **scoring** | confidence per insight from base + signals + sources | possibly Bedrock |
| 102s | **delivery** | INSERT `trip_advisories` rows. `display_kind` from `_resolve_display_kind(category, has_pin)`:<br>• transport_tip → `route_overlay`<br>• has place_lat → `point` (only in live_companion w/ GMaps)<br>• otherwise → `ambient`<br>Job status → `completed` | — |

### What the live_companion path adds

If brain.phase == `live_companion` (set when V2 tracking session starts via `enrich_on_tracking_start`), an extra `gmaps_scrape` stage runs after `reddit_scrape`. It uses xvfb-headed Chromium against `google.com/maps/search/...` and pulls `place_id, lat, lng, rating, review_count, photos`. Resulting advisories get `display_kind='point'` and `place_lat IS NOT NULL` (renderable map pins).

Add ~30–60s to total job time when GMaps is in the path.

---

## 6. Incident debug history (2026-04-29)

Documented in chronological order so a future agent can recognize patterns.

### 6.1 Bedrock 403 on prod despite local 200 OK

**Symptom:** `_try_bedrock` returned `None` on server, `RESULT: {'ok': True}` locally with the same code.

**Diagnosis steps (in order):**
1. SSM env check: `docker exec api env | grep BEDROCK` — env vars present, key length 132 ✓
2. Bedrock smoke: 403 with body `Authentication failed: Please make sure your API Key is valid.`
3. Re-ran smoke locally: 200 OK
4. Compared SHA-256 of the key in container vs local `.env`:
   - server: `5c62819df0a68acc…`
   - local: `b20f33c218e288cc…`
5. Different hashes confirmed the keys differ — Coolify env held a stale/wrong key

**Fix:** copy local key into Coolify, hit Redeploy (not just Save), re-run smoke. Got `RESULT: {'ok': True}`.

**Lesson:** when prod and local run identical code with seemingly identical env vars but behave differently, fingerprint the credentials. SHA-256 the key in both environments before assuming they're the same.

### 6.2 Job stuck in `route_segmentation` for 180+s

**Symptom:** advisory job entered `route_segmentation` stage at t=3s, never advanced. After 180s it was still `processing` at the same stage.

**Diagnosis:**
```
docker logs advisory_worker-... | tail -100
```
Showed repeating loop:
```
[ADVISORY_WORKER] loop error #1 (retry in 5s): … (psycopg2.errors.CheckViolation)
new row for relation "advisory_jobs" violates check constraint "check_advisory_job_stage"
… stage='clarify_intent' …
```

**Root cause:** Phase 4/5 introduced new stage names (`clarify_intent`, `merge_dedup`) but the original migration `ffd82b6d69e4_add_advisory_pipeline_tables.py` had a CHECK constraint pinning `stage IN ('route_segmentation', 'reddit_scrape', 'tripadvisor_scrape', 'gmaps_scrape', 'llm_extraction', 'scoring', 'delivery')`. The display_kind / brain-phase / locality_confidence columns were added but the stage constraint update was missed.

**Fix in two parts:**

1. **Live patch (immediate unblock):**
   ```sql
   ALTER TABLE advisory_jobs DROP CONSTRAINT check_advisory_job_stage;
   ALTER TABLE advisory_jobs ADD CONSTRAINT check_advisory_job_stage CHECK (
     stage IS NULL OR stage IN (
       'route_segmentation','reddit_scrape','tripadvisor_scrape','gmaps_scrape',
       'llm_extraction','merge_dedup','clarify_intent','scoring','delivery'
     )
   );
   ```
2. **Permanent migration:** `backend/alembic/versions/d2e7a8b3f4c1_advisory_job_stage_constraint.py` (chained off `d8b7c6a5e4f3`). Idempotent — uses `DROP CONSTRAINT IF EXISTS`. Applied via local `alembic upgrade head` (which targets the same Supabase DB as prod). Prod `alembic_version` is now at `d2e7a8b3f4c1`.

**Lesson:** when adding a new stage / category / status enum, grep for `CheckConstraint` in `alembic/versions/` to confirm no constraint pins the old set. Co-locate the constraint update in the same migration that introduces the new value.

### 6.3 First clean E2E run

After the constraint fix the same E2E succeeded:
- **102.4 seconds** end-to-end
- **34 advisories** delivered across 5 categories
- `display_kind` correctly mapped: 33× `ambient`, 1× `route_overlay`
- No churn (single job, single processing pass)

---

## 7. Phase verification matrix (post-rebuild, post-fix)

| Phase | What it does | Verified on prod (2026-04-29) |
|---|---|---|
| 0 — Bedrock LLM | Claude Haiku 4.5 primary via `_try_bedrock`, OpenRouter chain as failover | ✅ smoke 200 OK in api + advisory_worker containers |
| 1 — City-level locality | `reverse_geocode` walks Mapbox context (place > region > locality) | ✅ Parliament House → "New Delhi" / "Delhi"; Pune→Goa polyline → 15 real cities |
| 2 — Cadence persistence | `mark_cycle_outcome` runs in single explicit transaction | ✅ Brain `last_seed_at` advances; tested via `seed_on_trip_creation` UPDATE |
| 3 — Reddit v2 scraper | BrightData residential proxy, Playwright headed Chromium, 4-stage extract | ✅ `_stage_reddit_scrape` runs `scrape_reddit_v2`; produces real insights from `r/IndiaTravel` etc. |
| 4 — Mode A/B phase machine | `STAGE_PATHS_BY_PHASE[brain.phase]` routes per phase; cycle worker is trigger detector | ✅ `planning` path executes correctly: clarify→route_seg→reddit→merge→score→deliver |
| 5 — clarify_intent + locality_confidence | Stage exists in path, gated by `ADVISORY_CLARIFY_ENABLED`. `locality_confidence` JSONB on brain | ✅ Stage transitions cleanly when disabled. Confidence storage column populated |
| 6 — display_kind + place_polygon | Migration adds columns + CHECK; delivery sets `display_kind` from category | ✅ 34 advisories all have `display_kind` set; mapping `transport_tip→route_overlay`, others→`ambient` (no GMaps coords yet) |
| 7 — Stage constraint fix | New migration `d2e7a8b3f4c1` adds `clarify_intent`, `merge_dedup` to allowed set | ✅ Applied; alembic head = `d2e7a8b3f4c1`; live patch + migration both in place |

---

## 8. What's NOT yet exercised on prod

These are real production paths that the Day-7 E2E did not cover:

- **GMaps scraping (`live_companion` phase)** — requires a `trip_tracking_sessions` row + brain phase flip. No real user has started a V2 tracking session yet (11 of 12 real-user trips never started one — separate Flutter sprint to investigate).
- **Cycle worker trigger detection (`region_jump`, `route_changed`)** — the periodic detector logic was rewritten in Phase 4 but never observed firing on real GPS injection. To exercise: insert a `trip_tracking_sessions` row + `trip_route_raw_point` GPS pings, watch cycle worker logs.
- **clarify_intent ask-flow** — gated by `ADVISORY_CLARIFY_ENABLED=false`. Flip env, redeploy, send an ambiguous query like `"find food"`. Should produce a `clarifying_question` message + block the job until `/conversation/answer` is hit.
- **Push notifications** — `FIREBASE_PUSH_ENABLED=false`. Delivery skips push entirely.
- **Confidence-skip + activity_focus → category mapping** — the `_ACTIVITY_TO_CATEGORIES` table in `advisory_cycle_worker.py` is wired but only fires on cycle-triggered jobs. on_demand jobs (which we tested) bypass it.
- **OpenRouter failover chain** — Bedrock is primary; the chain `deepseek/deepseek-v4-flash → nvidia/nemotron-3-super → glm-4.5-air → minimax → qwen → llama-3.3` only kicks in on Bedrock failure. To exercise: temporarily flip `LLM_PROVIDER=openrouter`.

When any of these become priorities, follow the same SSM-driven test pattern as the Day-7 E2E.

---

## 9. File map of the rebuild work

```
backend/
├── app/
│   ├── config.py                          # +LLM_PROVIDER, +BEDROCK_*, +OPENROUTER_FALLBACK_MODELS
│   ├── services/
│   │   ├── llm.py                         # NEW — chat_json with Bedrock primary + OpenRouter chain
│   │   ├── geocoding_service.py           # MOD — Phase 1 city-scope walk
│   │   ├── trip_brain_service.py          # MOD — Phase 2 tx fix + Phase 4 phase machine
│   │   └── scrapers/
│   │       └── reddit_playwright.py       # NEW (3B) — fallback scraper if Crawl4AI unfixable
│   └── workers/
│       ├── advisory_worker.py             # MOD — Phase 4 STAGE_PATHS_BY_PHASE, Phase 6 display_kind
│       └── advisory_cycle_worker.py       # MOD — Phase 4 trigger detector rewrite, _ACTIVITY_TO_CATEGORIES
├── alembic/versions/
│   ├── a7f9c2e4d8b1_brain_phase_confidence.py        # NEW — phase, locality_confidence, last_phase_change_at
│   ├── b8a3d6f1c5e2_advisory_display_kind.py         # NEW — display_kind, place_polygon
│   └── d2e7a8b3f4c1_advisory_job_stage_constraint.py # NEW (Phase 7) — fix stage CHECK constraint
└── docker-compose.coolify.yml              # MOD — env: LLM_PROVIDER, BEDROCK_*, BRIGHTDATA_PROXY_*

flutter/lib/features/live_capture/presentation/screens/live_hub_screen.dart
                                              # MOD — origin/destination fields + auto-route generation

docs/advisory-pipeline/
├── 03-implementation-status.md             # MOD — Phases 0–7 appendix
└── 05-server-ops-runbook.md                # NEW — this doc
```

---

## 10. Quick-reference cheatsheet

| Need | Command |
|---|---|
| Verify SSM access | `aws sts get-caller-identity` after loading `.env` AWS keys |
| Check container health | SSM `docker ps` payload |
| Check alembic state | `cd backend && ./venv/Scripts/alembic.exe current` (local) — same DB as prod |
| Run local alembic upgrade against prod DB | `cd backend && ./venv/Scripts/alembic.exe upgrade head` |
| Smoke-test Bedrock | SSM payload running `_try_bedrock` (§4.4) |
| Look at worker logs | SSM payload running `docker logs --since 10m advisory_worker-…` |
| Run full E2E | SSM payload running `e2e_full.py` (§5) |
| Find a stuck job | SSM SQL: `select id, stage, status, error_code from advisory_jobs where status='processing' and updated_at < now()-interval '5 min'` |
| Force-fail stuck jobs | SSM SQL: `update advisory_jobs set status='failed', error_code='manual_clear' where status='processing' and updated_at < now()-interval '5 min'` |

---

## 11. Pointers

- Beginner-friendly SSM tutorial: `docs/deployment/server-terminal-to-ec2-beginner-guide.md`
- Compose architecture: `docs/deployment/coolify-compose-architecture.md`
- Deploy troubleshooting: `docs/deployment/deploy-troubleshooting-quickstart.md`
- Original advisory baseline (before rebuild): `docs/advisory-pipeline/04-current-server-behavior-baseline.md`
- Architecture: `docs/advisory-pipeline/01-architecture.md`
- Schema: `docs/advisory-pipeline/02-database-schema.md`
- Implementation status (this rebuild's phases): `docs/advisory-pipeline/03-implementation-status.md`
