# Advisory Pipeline — Implementation Status

> Last updated: 2026-04-15

## Commits

| Commit | Description |
|--------|-------------|
| `c3d8842` | Schema + models + migration + Pydantic schemas |
| `97ab144` | API endpoints + service layer + worker skeleton |
| `5a65030` | Reddit scraper wired into worker stages |
| `e029002` | JSONB `flag_modified` persistence fix |

## What's Built

### Backend — Config (`backend/app/config.py`)
- `ADVISORY_WORKER_POLL_SECONDS` (5.0), `ADVISORY_WORKER_STALE_SECONDS` (900)
- `ADVISORY_MIN_CONFIDENCE_PUSH` (0.7), `ADVISORY_MAX_PER_HOUR` (3)
- `OPENROUTER_API_KEY`, `OPENROUTER_MODEL`, `BRIGHTDATA_WS_ENDPOINT`
- `UPSTASH_REDIS_URL`, `UPSTASH_REDIS_TOKEN`

### Backend — Models (`backend/app/models/`)
- `advisory_job.py` — AdvisoryJob with state machine, partial unique index
- `trip_advisory.py` — TripAdvisory with delivery-only status, dedupe constraint
- `advisory_user_action.py` — append-only user actions with metadata snapshot

### Backend — Migration (`backend/alembic/versions/ffd82b6d69e4_...`)
- Creates 3 tables with all indexes, CHECK constraints, FK policies
- Down revision: `1c3f9e8a7b2d`
- **Applied to production Supabase: Yes (2026-04-15)**

### Backend — Schemas (`backend/app/schemas/advisory.py`)
- Enums: AdvisoryJobType, AdvisoryCategory, AdvisorySource, UserActionType, etc.
- Requests: AdvisoryStartRequest, AdvisoryQueryRequest, AdvisoryActionRequest
- Responses: AdvisoryJobResponse, AdvisoryInsightResponse, AdvisoryInsightListResponse, AdvisoryActionResponse

### Backend — API (`backend/app/api/v1/advisory.py`)
| Endpoint | Method | Status Code | Description |
|----------|--------|-------------|-------------|
| `/trips/{trip_id}/advisory/start` | POST | 202 | Create pre_trip or location_trigger job |
| `/trips/{trip_id}/advisory/query` | POST | 202 | NL query → on_demand job |
| `/trips/{trip_id}/advisory/jobs` | GET | 200 | List jobs (paginated, status filter) |
| `/trips/{trip_id}/advisory/insights` | GET | 200 | Inbox: `status IN (pending, delivered)` |
| `/advisory/{advisory_id}/action` | POST | 200 | Record user action (append-only) |

### Backend — Service (`backend/app/services/advisory_service.py`)
- `create_advisory_job()` — ownership check, request_hash computation, duplicate detection, location_trigger coalescing with row lock
- `get_advisory_jobs()` — paginated list
- `get_trip_advisories()` — inbox query (pending + delivered), sorted by confidence
- `record_user_action()` — creates action row with trip_metadata_snapshot

### Backend — Worker (`backend/app/workers/advisory_worker.py`)
- Full poll loop following export_worker pattern
- `claim_next_job()` — `FOR UPDATE SKIP LOCKED`
- `recover_orphaned_jobs()` — 900s stale threshold
- Retry backoff: [30s, 120s, 480s]
- Heartbeat via `flag_modified(job, "updated_at")` during long stages
- `flag_modified` on all JSONB column updates (result_summary, scrape_plan)

**Stage implementations:**

| Stage | Status | What It Does |
|-------|--------|--------------|
| route_segmentation | **Implemented** | Reads trip places, derives keywords, builds scrape plan |
| reddit_scrape | **Implemented** | Calls Crawl4AI deep crawl + LLM extraction via OpenRouter |
| tripadvisor_scrape | **Stub** | Logs and skips |
| gmaps_scrape | **Stub** | Skips if `BRIGHTDATA_WS_ENDPOINT` not set |
| llm_extraction | **Implemented** | Merges insights across sources, dedupes via SHA-256 key |
| scoring | **Implemented** | Confidence = 0.4 base + 0.15/extra source + 0.1/signal + 0.1/named place |
| delivery | **Implemented** | Creates TripAdvisory rows, push throttle check (3/hr) |

### Backend — Reddit Scraper (`backend/app/services/scrapers/reddit_scraper.py`)
- Extracted from `scraper_reddit/smart_reddit_scraper.py`
- `scrape_reddit()` — async function, takes question + subs + keywords
- Uses Crawl4AI `BestFirstCrawlingStrategy` with `KeywordRelevanceScorer`
- `URLPatternFilter` restricts to `*/comments/*` (only post pages, no sidebar noise)
- LLM extraction via OpenRouter with `TravelInsight` Pydantic schema
- Returns structured dict with `insights: list[dict]`

## Test Results (2026-04-15)

**Full pipeline test with trip "Last" (Pune, Chandigarh):**
- Route segmentation: extracted 3 unique place names
- Reddit scrape: deep-crawled 7 pages across r/IndiaTravel, r/solotravel, r/travel
- LLM extracted 2 actionable insights (hitchhiking tips for the Pune-Chandigarh corridor)
- Deduped: 2 → 2 unique
- Scored: both at 0.5 confidence (above 0.3 threshold)
- Delivered: 2 TripAdvisory rows created with status=pending (below 0.7 push threshold)

## What's NOT Built Yet

### Immediate Next Steps
- [ ] **Upstash Redis cache** (`backend/app/services/advisory_cache.py`) — per-trip session state, insight caching, invalidation on reroute
- [ ] **TripAdvisor scraper** — Crawl4AI with TripAdvisor URL patterns
- [ ] **Google Maps scraper integration** — wire `scraper_lean/` Bright Data CDP flow into gmaps_scrape stage
- [ ] **Push notification** in delivery stage — call existing `PushNotificationService`
- [ ] **Flutter UI** — advisory inbox screen, notification handling, action recording

### Future (Post-MVP)
- [ ] Preference learning algorithm — query `advisory_user_actions` + `trip_places` + `place_saves` for similar-user recommendations
- [ ] Route corridor geometry — buffer around polyline, ahead-window, detour cap
- [ ] Location trigger integration — live_tracking_worker fires advisory jobs when approaching cities
- [ ] Trip metadata wiring in Flutter — PreCreateScreen tags → backend metadata API
- [ ] Advanced scoring — LLM-based relevance scoring instead of heuristic
- [ ] Multi-model fallback — if free model rate-limits, fall back to cheap paid model

## How to Test Locally

### Prerequisites
```bash
cd backend
pip install crawl4ai
playwright install chromium
```

Ensure `backend/.env` has:
```
OPENROUTER_API_KEY=sk-or-v1-...
```

### Run the worker for one job
```python
import asyncio, logging, hashlib
logging.basicConfig(level=logging.INFO)

from app.database import SessionLocal
from app.models.advisory_job import AdvisoryJob
from app.models.trip import Trip
from app.workers.advisory_worker import claim_next_job, run_job_once
from uuid import uuid4

db = SessionLocal()
trip_id = '<your-trip-id>'
t = db.query(Trip).filter(Trip.id == trip_id).first()

job = AdvisoryJob(
    user_id=str(t.user_id), trip_id=trip_id, status='queued',
    job_type='pre_trip',
    request_hash=hashlib.sha256(b'test').hexdigest(),
    retry_count=0, max_retries=3,
)
db.add(job); db.commit()

job = claim_next_job(db, str(uuid4()))
asyncio.run(run_job_once(db, job))
db.refresh(job)
print(f'Status: {job.status}, Advisories: ...')
```

### Run the worker as a persistent process
```bash
cd backend
python -m app.workers.advisory_worker
```

### Test via API (requires auth token)
```bash
# Start advisory job
curl -X POST http://localhost:8000/api/v1/trips/{trip_id}/advisory/start \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"job_type": "pre_trip"}'

# Check insights
curl http://localhost:8000/api/v1/trips/{trip_id}/advisory/insights \
  -H "Authorization: Bearer <token>"
```

## File Map

```
backend/
├── app/
│   ├── config.py                          # Advisory config settings
│   ├── main.py                            # Advisory router registered
│   ├── models/
│   │   ├── advisory_job.py                # AdvisoryJob model
│   │   ├── trip_advisory.py               # TripAdvisory model
│   │   ├── advisory_user_action.py        # AdvisoryUserAction model
│   │   └── __init__.py                    # Models registered
│   ├── schemas/
│   │   └── advisory.py                    # Pydantic schemas
│   ├── api/v1/
│   │   └── advisory.py                    # API endpoints
│   ├── services/
│   │   ├── advisory_service.py            # Service layer
│   │   └── scrapers/
│   │       ├── __init__.py
│   │       └── reddit_scraper.py          # Crawl4AI + LLM extraction
│   └── workers/
│       └── advisory_worker.py             # Worker with 7-stage pipeline
├── alembic/versions/
│   └── ffd82b6d69e4_add_advisory_...py    # Migration
│
scraper_reddit/                            # Standalone Reddit scraper (prototype)
├── smart_reddit_scraper.py                # CLI version (backend module extracted from this)
├── reddit_llm_extract.py                  # Earlier single-URL test
└── .env                                   # OpenRouter key for standalone testing
│
scraper_lean/                              # Google Maps scraper (prototype)
├── step1_acquire.py                       # Page acquisition (persistent profile)
├── step2_extract.py                       # Review extraction
├── step3_scroll.py                        # Scroll pagination
└── profile/                               # Chromium persistent profile (DO NOT DELETE)
```

## Related Docs

- [01-architecture.md](./01-architecture.md) — system design, data flow, design decisions
- [02-database-schema.md](./02-database-schema.md) — table definitions, indexes, constraints
