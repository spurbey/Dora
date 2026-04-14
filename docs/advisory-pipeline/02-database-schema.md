# Advisory Pipeline — Database Schema

> Three tables power the advisory pipeline. Migration: `ffd82b6d69e4_add_advisory_pipeline_tables.py`

## Tables

### `advisory_jobs`

Job queue for the advisory worker. Follows the same state machine as `export_jobs`.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PK | Job ID |
| user_id | UUID | FK users CASCADE, NOT NULL | Owner |
| trip_id | UUID | FK trips CASCADE, NOT NULL | Target trip |
| status | String(32) | NOT NULL, CHECK | `queued\|processing\|cancel_requested\|completed\|failed\|canceled\|blocked` |
| stage | String(32) | nullable, CHECK | Current pipeline stage (7 stages) |
| progress | Float | NOT NULL, CHECK 0-1 | Pipeline progress |
| job_type | String(32) | NOT NULL, CHECK | `pre_trip\|on_demand\|location_trigger` |
| request_hash | String(64) | NOT NULL | SHA-256 of `(job_type, normalized_query)` for idempotency |
| query_text | Text | nullable | Raw NL query for on_demand jobs |
| parsed_filters | JSONB | nullable | LLM-parsed intent (populated by worker) |
| scrape_plan | JSONB | nullable | Orchestrator output: seeds, keywords, instructions |
| result_summary | JSONB | nullable | Accumulated results across stages |
| error_code | String(64) | nullable | Structured error code |
| error_message | Text | nullable | Human-readable error |
| retry_count | Integer | NOT NULL, default 0 | Current attempt count |
| max_retries | Integer | NOT NULL, default 3 | Max retry attempts |
| next_attempt_at | DateTime(tz) | nullable | Retry eligibility time |
| worker_session_id | String(64) | nullable | Current worker session |
| created_at | DateTime(tz) | NOT NULL, server_default now() | |
| updated_at | DateTime(tz) | NOT NULL, server_default now(), onupdate | |
| started_at | DateTime(tz) | nullable | First worker claim time |
| completed_at | DateTime(tz) | nullable | Terminal completion time |

**Indexes:**
- `idx_advisory_jobs_status_next_attempt` — `(status, next_attempt_at)` — worker poll query
- `idx_advisory_jobs_user_status` — `(user_id, status)` — user's job list
- `idx_advisory_jobs_trip` — `(trip_id)` — trip's job list
- `uq_advisory_jobs_active_per_trip` — `UNIQUE (trip_id, job_type, request_hash) WHERE status IN ('queued', 'processing')` — prevents duplicate active jobs

**Pipeline stages:** `route_segmentation` → `reddit_scrape` → `tripadvisor_scrape` → `gmaps_scrape` → `llm_extraction` → `scoring` → `delivery`

**Status state machine:**
```
queued → processing → completed
                   → failed (retryable, back to queued with backoff)
                   → blocked (terminal, non-retryable)
processing → cancel_requested → canceled
```

---

### `trip_advisories`

Delivered advisory insights. Status tracks delivery lifecycle only.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PK | Advisory ID |
| trip_id | UUID | FK trips CASCADE, NOT NULL | |
| user_id | UUID | FK users CASCADE, NOT NULL | |
| advisory_job_id | UUID | FK advisory_jobs SET NULL | Job that produced this |
| category | String(32) | NOT NULL, CHECK | One of 10 categories (see below) |
| source | String(32) | NOT NULL, CHECK | `reddit\|tripadvisor\|google_maps\|combined` |
| place_name | Text | nullable | Specific place/area |
| place_lat | Float | nullable | |
| place_lng | Float | nullable | |
| title | Text | NOT NULL | Advisory title |
| body | Text | NOT NULL | Full advisory text |
| context_signal | Text | nullable | e.g. "3 Reddit users agreed" |
| best_for | Text | nullable | e.g. "solo female travelers" |
| confidence_score | Float | NOT NULL, CHECK 0-1 | Scoring result |
| source_urls | ARRAY(Text) | nullable | Source page URLs |
| source_count | Integer | NOT NULL, default 1 | Corroborating sources |
| dedupe_key | String(64) | NOT NULL | SHA-256 of `(place_name, category, body[:100])` |
| status | String(32) | NOT NULL, CHECK | **Delivery-only:** `pending\|delivered\|expired` |
| observed_at | DateTime(tz) | nullable | When source data was scraped |
| delivered_at | DateTime(tz) | nullable | When push was sent |
| expires_at | DateTime(tz) | nullable | Advisory expiry time |
| created_at | DateTime(tz) | NOT NULL, server_default now() | |
| updated_at | DateTime(tz) | NOT NULL, server_default now(), onupdate | |

**Indexes:**
- `idx_advisory_trip_status` — `(trip_id, status)` — inbox query
- `idx_advisory_user_category` — `(user_id, category)` — preference analysis
- `idx_advisory_job` — `(advisory_job_id)` — job's advisories
- `uq_advisory_trip_dedupe` — `UNIQUE (trip_id, dedupe_key)` — prevents duplicate advisories

**Categories:** `safety_warning`, `scam_alert`, `food_tip`, `photo_spot`, `transport_tip`, `accommodation`, `cultural_etiquette`, `must_do`, `avoid`, `general_tip`

**Important:** User engagement (liked, dismissed, saved) is NOT stored here. It's in `advisory_user_actions` (append-only). This table's `status` only tracks delivery: was it shown to the user?

---

### `advisory_user_actions`

Append-only log of user engagement with advisories. Powers preference learning.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PK | Action ID |
| user_id | UUID | FK users CASCADE, NOT NULL | |
| trip_id | UUID | FK trips CASCADE, NOT NULL | |
| advisory_id | UUID | FK trip_advisories CASCADE, NOT NULL | |
| action | String(32) | NOT NULL, CHECK | `dismissed\|liked\|saved\|acted_on\|converted_to_place` |
| action_metadata | JSONB | nullable | Extra context (e.g. place_id saved to) |
| trip_metadata_snapshot | JSONB | NOT NULL | Snapshot of TripMetadata at action time |
| created_at | DateTime(tz) | NOT NULL, server_default now() | |

**Indexes:**
- `idx_advisory_action_user` — `(user_id, action)` — user preference queries
- `idx_advisory_action_advisory` — `(advisory_id)` — advisory's actions
- `idx_advisory_action_trip` — `(trip_id)` — trip's action history

**Why `trip_metadata_snapshot`?** When recommending to future users with similar trip profiles, we need to know what the trip looked like when the user acted — not what it looks like now (metadata may change).

---

## Preference Learning Data Sources

The recommendation engine queries not just `advisory_user_actions` but ALL user-generated signals:

| Table | Signal | Weight |
|-------|--------|--------|
| `advisory_user_actions` | liked/saved/acted_on advisories | High |
| `trip_places` | Places user added to their trip | High |
| `trip_tracking_events` | Notes, warnings, tags captured during trip | Medium |
| `place_saves` | Places user saved/favorited | High |
| `search_events` | What the user searched for | Low |

## Related Docs

- [01-architecture.md](./01-architecture.md) — system overview, data flow, design decisions
- [03-implementation-status.md](./03-implementation-status.md) — what's built, what's pending
