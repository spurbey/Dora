# Advisory Pipeline — Architecture

> Dora's travel advisory system proactively recommends places, warns about scams, and suggests activities to users during their trips by scraping Reddit, TripAdvisor, and Google Maps, processing results through LLMs, and delivering structured advisories.

## System Overview

```
Flutter App
    │
    ├── POST /advisory/start        (pre-trip or location trigger)
    ├── POST /advisory/query        (natural-language: "find me a quiet cafe")
    ├── GET  /advisory/insights     (inbox: pending + delivered advisories)
    └── POST /advisory/{id}/action  (liked / dismissed / saved / acted_on)
          │
          ▼
    FastAPI Backend (Railway)
          │
          ├── Advisory Service (creates job, records actions)
          └── advisory_jobs table (status=queued)
                │
                ▼
    Advisory Worker (Railway Worker Service, polls PostgreSQL)
          │
          ├── 1. route_segmentation   → segment trip into cities, derive keywords
          ├── 2. reddit_scrape        → Crawl4AI deep crawl + LLM extraction
          ├── 3. tripadvisor_scrape   → Crawl4AI (stub, future)
          ├── 4. gmaps_scrape         → Bright Data CDP (stub, future)
          ├── 5. llm_extraction       → merge + dedupe across sources
          ├── 6. scoring              → confidence scoring
          └── 7. delivery             → write TripAdvisory rows, push notification
                │
                ▼
          trip_advisories table → Flutter inbox
          advisory_user_actions table → preference learning
```

## Data Flow

### Pre-Trip (background, at trip creation)
1. User creates trip with metadata (traveler_type, travel_style, activity_focus)
2. Flutter calls `POST /trips/{id}/advisory/start` with `job_type=pre_trip`
3. API creates `advisory_jobs` row with `status=queued`
4. Worker picks up job, reads trip places, builds search keywords
5. Crawl4AI deep-crawls Reddit (BestFirst strategy + keyword scoring)
6. LLM extracts structured insights from each discovered post
7. Insights are deduped, scored, and written as `trip_advisories` rows
8. Low-confidence advisories go to inbox; high-confidence also get push notification

### On-Demand (user asks during trip)
1. User responds to notification or types "find me breakfast spots"
2. Flutter calls `POST /trips/{id}/advisory/query` with raw text
3. API stores `query_text` and creates `on_demand` job (no LLM in request path)
4. Worker parses intent in `route_segmentation` stage, then scrapes accordingly
5. Same pipeline: scrape → extract → dedupe → score → deliver

### Location Trigger (approaching a city)
1. Live tracking worker detects user approaching a new city/segment
2. Backend calls advisory service to create `location_trigger` job
3. If an active location_trigger job already exists for this trip, the new trigger payload is coalesced into the existing job's `scrape_plan` (row-locked transaction)
4. Worker processes the coalesced triggers

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| NL intent parsing in worker, not API | API returns 202 instantly; no LLM latency or failure risk in request path |
| Advisory status = delivery-only (pending/delivered/expired) | User engagement is append-only in `advisory_user_actions` — preserves full action history |
| Job idempotency via `(trip_id, job_type, request_hash)` partial unique index | Prevents duplicate active jobs while allowing multiple distinct on_demand queries |
| `request_hash` is NOT NULL with canonical normalization | Avoids PostgreSQL NULL-skips-unique-index gotcha |
| Stale threshold = 900s (15 min) + heartbeat every 60s | Reddit/LLM stages can take 5-10 min; prevents false stale recovery |
| Push throttle: max 3/hour per trip | Prevents notification fatigue; checked via DB count query in delivery stage |
| Confidence gating: >= 0.7 for push, all >= 0.3 for inbox | Low-confidence still visible in inbox, just no push interruption |
| Upstash Redis for ephemeral session state, Supabase DB for persistent data | Per-trip cache expires; user actions and advisories persist for learning |

## External Dependencies

| Service | Purpose | Required? |
|---------|---------|-----------|
| OpenRouter (LLM) | Reddit extraction, intent parsing | Yes — worker skips reddit_scrape if missing |
| Bright Data (Scraping Browser) | Google Maps scraping via CDP | No — gmaps_scrape skips gracefully |
| Upstash Redis | Ephemeral per-trip session state | No — pipeline works without cache, just slower |
| Crawl4AI | Reddit/TripAdvisor deep crawling | Yes — core scraping engine |
| Playwright + Chromium | Browser for Crawl4AI | Yes — installed via `playwright install chromium` |

## Deployment

The advisory worker runs as a third process in the existing Railway Worker service:

```
Railway Worker Service:
  ├── python -m app.workers.export_worker          (video exports)
  ├── python -m app.workers.live_tracking_worker    (location inference)
  └── python -m app.workers.advisory_worker         (advisory pipeline)
```

All three workers share the same Docker image and codebase. They poll PostgreSQL independently using `FOR UPDATE SKIP LOCKED` for atomic job claiming.

## Related Docs

- [02-database-schema.md](./02-database-schema.md) — table definitions, indexes, constraints
- [03-implementation-status.md](./03-implementation-status.md) — what's built, what's pending, how to test
