# Coolify Compose Architecture (EC2 Migration Notes)

## Purpose
This document explains what is in `docker-compose.coolify.yml`, why it was designed this way, and which decisions came from the Railway -> EC2/Coolify migration discussions.

It is intended for:
- engineers onboarding to Dora deployment
- agents modifying deployment files
- incident debugging when services or workers fail in Coolify

Quick incident checklist:
- `docs/deployment/deploy-troubleshooting-quickstart.md`

---

## Background: Why We Moved
Earlier deployment was Railway-based and split across separate Railway services (API, worker, renderer). As advisory + scraping became more complex, we moved to EC2 + Coolify to:

- control runtime dependencies more directly
- run headed browser scraping with persistent profile
- keep all backend workloads in one deployable stack
- keep CI/CD explicit (migration first, then deployment trigger)

Related migration artifacts:
- `.github/workflows/deploy-railway.yml` (legacy/manual path)
- `.github/workflows/deploy-coolify.yml` (active path)
- `docker-compose.coolify.yml` (production stack spec)

---

## High-Level Architecture
`docker-compose.coolify.yml` defines one application stack with multiple containers on the same host:

- `api` (FastAPI app)
- `export_worker`
- `advisory_worker`
- `advisory_cycle_worker`
- `advisory_ignore_sweep_worker`
- `story_retention_worker`
- `renderer` (video-renderer service)

Key design choice:
- all of the above run inside one Coolify application for now (single-host, single-stack operations)
- managed Postgres is external (Supabase), so no local `db` service in the Coolify compose

---

## Service Topology and Internal Networking
Internal service discovery uses Docker service names, not public domains:

- backend services call renderer via `http://renderer:3100`
- only externally exposed API should be assigned a public domain in Coolify

Why:
- less external surface area
- simpler auth and routing
- fewer TLS/domain management points

Important distinction:
- `docker-compose.dev.yml` is local dev and may include local `db`
- `docker-compose.coolify.yml` is production stack on Coolify
- changing only dev compose does not change Coolify behavior

---

## Why Environment Anchors Are Used
Two YAML anchors reduce duplication and drift:

- `x-backend-env` (shared by API + backend workers)
- `x-renderer-env` (shared by renderer)

Benefits:
- one source for common environment keys
- fewer config mismatches between worker containers
- easier to audit production vars

---

## Why We Split Dependency Stacks
We intentionally build backend containers with different requirements files:

- runtime services (`api`, most workers): `requirements.runtime.txt`
- advisory scraping worker: `requirements.advisory.txt`

Reason:
- advisory scraping stack needs heavier and newer crawler/browser dependencies
- runtime stack should stay lean and stable for API + non-scraping workers
- avoids dependency conflict blast radius across all backend services

Implementation:
- `backend/Dockerfile` supports `ARG REQUIREMENTS_FILE`
- compose passes this arg per service build

---

## Why Advisory Worker Runs with Xvfb + Persistent Profile
`advisory_worker` uses:

- `xvfb-run` for headed browser rendering in server environment
- mounted volume `gmaps_profile:/app/.gmaps_profile` for persistent browser state
- explicit envs:
  - `ADVISORY_GMAPS_LOCAL_DEBUG`
  - `ADVISORY_GMAPS_LOCAL_HEADLESS`
  - `ADVISORY_GMAPS_LOCAL_PROFILE_DIR`

Reason:
- Google Maps scraping behavior was more reliable with headed-like execution and persistent profile compared with pure stateless runs
- profile persistence helps continuity across restarts

Operational note:
- `xauth` was required by `xvfb-run` and had to be installed in the image after deployment failures

---

## Volumes and Persistence
The compose file defines:

- `render_artifacts`: shared export artifacts between renderer and export worker
- `gmaps_profile`: persistent browser profile for advisory scraping worker

Why this matters:
- without `render_artifacts`, render outputs are not shared correctly
- without `gmaps_profile`, scraper profile continuity is lost after restart/redeploy

---

## CI/CD Flow (Current)
Primary workflow: `.github/workflows/deploy-coolify.yml`

Sequence:
1. on push to `main` (backend/video-renderer/compose/workflow paths), run migration job
2. migration job runs `alembic upgrade head` against production DB URL
3. deploy job triggers Coolify deployment webhook with bearer token

Why migration-first:
- avoid runtime mismatches between new code and old schema

Legacy workflow:
- `deploy-railway.yml` is retained for legacy/manual reference, not the primary production path

---

## Environment Variable Ownership
Runtime secrets must be set in Coolify environment variables for this stack.

Common confusion:
- Coolify UI shows "Production Environment Variables" and "Preview Deployments Environment Variables"
- production runs use production section
- preview section is only for preview deployments

Practical rule:
- if a variable is required in production, set it in Production Environment Variables
- do not rely on repo `.env` for Coolify runtime

---

## Why Workers Are in This Stack
Workers are included because API endpoint availability is not the same as background processing.

Examples:
- advisory push pipeline requires advisory workers, not only API routes
- cycle worker enqueues periodic advisory jobs
- advisory worker processes and dispatches advisory notifications
- ignore sweep worker maintains advisory state cleanup loops
- story retention worker runs retention housekeeping

So:
- for API route checks, workers are not required
- for full product behavior, workers are required unless intentionally run elsewhere

---

## Cost and Capacity Decision (Single Host First)
Current default decision:
- run all containers on one EC2 host managed by Coolify

Why:
- faster operational setup
- lower coordination overhead
- simpler internal networking

Tradeoff:
- all workloads share host CPU/RAM
- noisy-worker risk exists under high load

Scale path:
- later split heavy workers to separate host(s) if resource contention appears

---

## Common Failure Modes and What They Mean
1. `xvfb-run: error: xauth command not found`
- image missing `xauth`; advisory worker restart loop likely
- fix in Dockerfile package install

2. service runs in dev but not in Coolify
- check whether change was made to `docker-compose.coolify.yml` vs `docker-compose.dev.yml`

3. API up, advisory behavior missing
- usually one or more advisory workers not running or misconfigured env

4. Coolify deploy succeeds but app behavior still old
- check branch/commit deployed
- confirm env var save in Coolify
- check worker logs, not just API logs

---

## Change History for This Architecture
Key commits that shaped the current file:

- `5e2768d`: added Coolify deployment workflow + initial production compose
- `44da4b4`: shifted advisory scraping toward self-hosted persistent browser behavior and compose updates
- `d59191e`: split backend dependency stacks (`requirements.runtime.txt` vs `requirements.advisory.txt`) for reliable Coolify builds
- `beef7af`: Dockerfile fix to install `xauth` for advisory worker `xvfb-run`

---

## Agent/Developer Editing Rules
Before changing `docker-compose.coolify.yml`, verify:

1. Is this change for dev only or production?
2. Does it belong in `docker-compose.coolify.yml`, `docker-compose.dev.yml`, or both?
3. Does the service need runtime or advisory dependency stack?
4. Does it require persistent storage?
5. Does it need public domain exposure, or only internal service access?
6. Does CI migration ordering still remain safe?

After change:

1. run compose syntax validation locally
2. update this document if architecture assumptions changed
3. deploy and check logs for all affected services

---

## Quick Service Matrix
| Service | Role | Build deps | Persistent volume | Public domain needed |
|---|---|---|---|---|
| `api` | FastAPI HTTP API | runtime | no | yes |
| `export_worker` | export queue worker | runtime | `render_artifacts` | no |
| `advisory_worker` | advisory processing + scraping + push dispatch | advisory | `gmaps_profile` | no |
| `advisory_cycle_worker` | periodic advisory scheduler | runtime | no | no |
| `advisory_ignore_sweep_worker` | advisory ignore-state sweeper | runtime | no | no |
| `story_retention_worker` | story retention jobs | runtime | no | no |
| `renderer` | render engine | renderer deps | `render_artifacts` | no (internal) |

---

## Final Note
This architecture is intentionally pragmatic:
- one stack
- one host
- clear migration/deploy order
- separate heavy advisory dependency lane
- persistent advisory browser profile

It is optimized for operational clarity first, then scale-out when workload demands it.
