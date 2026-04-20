# Advisory Pipeline — Database Schema

> Five tables power the advisory pipeline. Migrations (in order):
> 1. `ffd82b6d69e4_add_advisory_pipeline_tables.py` — the original three (jobs, advisories, actions)
> 2. `a1b2c3d4e5f6_add_user_metadata_and_trip_brain.py` — brain state + user metadata
> 3. `d2f4e8a91b56_add_advisory_conversation.py` — conversation thread + `advisory_jobs.parent_message_id` FK

## Tables

### `advisory_jobs`

Job queue for the advisory worker. Follows the same state machine as `export_jobs`.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PK | Job ID |
| user_id | UUID | FK users CASCADE, NOT NULL | Owner |
| trip_id | UUID | FK trips CASCADE, NOT NULL | Target trip |
| status | String(32) | NOT NULL, CHECK | `queued\|processing\|cancel_requested\|completed\|failed\|canceled\|blocked` |
| stage | String(32) | nullable, CHECK | Current pipeline stage |
| progress | Float | NOT NULL, CHECK 0-1 | Pipeline progress |
| job_type | String(32) | NOT NULL, CHECK | `pre_trip\|on_demand\|location_trigger` |
| request_hash | String(64) | NOT NULL | SHA-256 of `(job_type, normalized_query)` for idempotency |
| query_text | Text | nullable | Raw NL query for on_demand jobs |
| parent_message_id | UUID | FK advisory_conversation_messages SET NULL, nullable | Conversation message that triggered this job (on_demand only) |
| parsed_filters | JSONB | nullable | LLM-parsed intent (populated by worker) |
| scrape_plan | JSONB | nullable | Orchestrator output; also carries `conversation_context` (last 10 msgs) for on_demand jobs, and `clarified_filters` / `clarified` flag after a clarify answer |
| result_summary | JSONB | nullable | Accumulated results across stages |
| error_code | String(64) | nullable | Structured error code |
| error_message | Text | nullable | Human-readable error |
| blocked_reason | String(64) | nullable | e.g. `waiting_user_response` (set when clarify stage pauses the job) |
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

**Pipeline stages:** `route_segmentation` → (`clarify_intent` — feature-flagged) → `reddit_scrape` → `tripadvisor_scrape` → `gmaps_scrape` → `llm_extraction` → `scoring` → `delivery`

**Status state machine:**
```
queued → processing → completed
                   → failed (retryable, back to queued with backoff)
                   → blocked (pending user clarify answer; resumed via /conversation/answer)
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
| poi_place_id | Text | nullable | Google Maps `place_id` when gmaps-sourced |
| weather_snapshot | JSONB | nullable | 3h forecast captured at delivery time |
| created_at | DateTime(tz) | NOT NULL, server_default now() | |
| updated_at | DateTime(tz) | NOT NULL, server_default now(), onupdate | |

**Indexes:**
- `idx_advisory_trip_status` — `(trip_id, status)` — inbox query
- `idx_advisory_user_category` — `(user_id, category)` — preference analysis
- `idx_advisory_job` — `(advisory_job_id)` — job's advisories
- `uq_advisory_trip_dedupe` — `UNIQUE (trip_id, dedupe_key)` — prevents duplicate advisories

**Categories:** `safety_warning`, `scam_alert`, `food_tip`, `photo_spot`, `transport_tip`, `accommodation`, `cultural_etiquette`, `must_do`, `avoid`, `general_tip`

**Important:** User engagement (`liked`, `dismissed`, `saved`) is NOT stored here. It's in `advisory_user_actions` (append-only). This table's `status` only tracks delivery: was it shown to the user?

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

### `trip_advisory_state`

Per-trip durable brain. One row per trip, auto-created on trip creation. Owns the state machine that drives the cycle worker.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| trip_id | UUID | PK, FK trips CASCADE | Trip this brain belongs to |
| user_id | UUID | FK users CASCADE, NOT NULL | Owner |
| lifecycle_state | String(16) | NOT NULL | `seeded\|active\|paused\|completed\|errored` |
| paused_reason | String(32) | nullable | `user\|inactivity\|completed` |
| paused_at | DateTime(tz) | nullable | |
| trip_class | String(32) | NOT NULL | Classification (see trip rule table) |
| cadence_seconds | Integer | NOT NULL | Cycle interval for this trip class |
| mode | String(16) | NOT NULL | `route\|radius` |
| next_eligible_at | DateTime(tz) | nullable | Cycle worker picks trips whose time has come |
| last_cycle_at | DateTime(tz) | nullable | Last time cycle fired |
| last_seed_at | DateTime(tz) | nullable | Last seed/reseed timestamp |
| last_seed_reason | String(64) | nullable | e.g. `initial\|route_changed\|metadata_changed` |
| pending_reseed_reasons | ARRAY(Text) | nullable | Reseed reasons accumulated during 120s debounce |
| route_samples | JSONB | nullable | 22 sampled polyline points with reverse-geocoded locality |
| advised_locality_keys | ARRAY(Text) | nullable, default `{}` | Locality IDs already covered |
| advised_poi_place_ids | ARRAY(Text) | nullable, default `{}` | GMaps place IDs already surfaced |
| no_pick_attempts | JSONB | nullable | Per-locality retry counter (budget=2) |
| recent_categories | JSONB | nullable | Rolling counter for diversity scoring |
| ignore_streak | Integer | NOT NULL, default 0 | Consecutive ignored advisories |
| trip_metadata_snapshot | JSONB | nullable | Frozen TripMetadata at seed time |
| user_metadata_snapshot | JSONB | nullable | Frozen UserMetadata at seed time |
| baseline_findings | JSONB | nullable | Pre-trip Reddit scrape results for reuse |
| brightdata_call_count | Integer | NOT NULL, default 0 | Per-trip cost counter (cap enforced atomically) |
| created_at | DateTime(tz) | NOT NULL, server_default now() | |
| updated_at | DateTime(tz) | NOT NULL, server_default now(), onupdate | |

**Key methods on `TripBrainService`:**
- `ensure_brain(trip_id, user_id)` — idempotent INSERT ON CONFLICT DO NOTHING (self-heal)
- `seed_on_trip_creation(trip_id)` — classify + sample route + geocode + snapshot metadata; called fire-and-forget from `POST /trips`
- `enrich_on_tracking_start(trip_id)` — flip to `active`, set `next_eligible_at`; called fire-and-forget from V2 `POST /sessions:start`
- `pick_next_target(trip_id)` — route/radius mode selection; returns `found|no_target|off_route`
- `mark_cycle_outcome(trip_id, outcome)` — advance state machine (5 outcomes)
- `apply_feedback(advisory_id, action_type)` — reset/increment ignore_streak, auto-resume on accept
- `reseed(trip_id, reasons)` — debounced; preserves `advised_*` + `ignore_streak`
- `try_increment_brightdata(trip_id, n)` — atomic cost cap check

---

### `advisory_conversation_messages`

Per-trip chat thread between Dora and the user. Append-only. Powers the advisory side panel.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PK | Message ID |
| trip_id | UUID | FK trips CASCADE, NOT NULL, indexed | |
| user_id | UUID | FK users CASCADE, NOT NULL, indexed | |
| role | String(16) | NOT NULL, CHECK | `dora\|user\|system` |
| message_type | String(32) | NOT NULL | See types below |
| content | Text | nullable | User-visible text |
| message_metadata | JSONB | nullable | Type-specific payload (options, advisory_id, category, etc.) |
| advisory_job_id | UUID | FK advisory_jobs SET NULL, nullable | Job producing this message (delivery) |
| advisory_id | UUID | FK trip_advisories SET NULL, nullable | Advisory referenced by this message |
| created_at | DateTime(tz) | NOT NULL, server_default now(), indexed | |

**Indexes:**
- `ix_advisory_conversation_messages_trip_id` — trip scoping
- `ix_advisory_conversation_messages_user_id` — user scoping
- `ix_advisory_conversation_messages_created_at` — time range
- `ix_conv_trip_created` — composite `(trip_id, created_at)` — serves both "load tail" and "time range" hot paths

**Message types:**
- `advisory_suggestion` — Dora's delivered advisory (auto-inserted by delivery stage with `advisory_id` + category + title in metadata)
- `clarifying_question` — Dora asks for info before scraping; metadata has `options: [...]` + `blocked_job_id`
- `user_query` — free-form user message, creates an `on_demand` AdvisoryJob
- `user_response` — user's answer to a clarifying question; metadata has `answered_question_id`
- `system_note` — e.g. "You saved Malaka Spice" — inserted on advisory action
- `greeting` — reserved for future onboarding tweaks

**Cache:** `conversation:{trip_id}:messages` — JSON list of last 30, 24h TTL. Read-through on GET, write-through via `append_conversation_message` on insert.
**Pending clarify cache:** `conversation:{trip_id}:pending_question` — 10min TTL, links the blocked job to the unanswered question.

---

## Preference Learning Data Sources

The recommendation engine queries not just `advisory_user_actions` but ALL user-generated signals:

| Table | Signal | Weight |
|-------|--------|--------|
| `advisory_user_actions` | liked/saved/acted_on advisories | High |
| `advisory_conversation_messages` (user_query / user_response) | explicit preferences the user typed | High |
| `trip_places` | Places user added to their trip | High |
| `trip_tracking_events` | Notes, warnings, tags captured during trip | Medium |
| `place_saves` | Places user saved/favorited | High |
| `search_events` | What the user searched for | Low |

## Related Docs

- [01-architecture.md](./01-architecture.md) — system overview, data flow, design decisions
- [03-implementation-status.md](./03-implementation-status.md) — what's built, what's pending
- [../scraping/hosted-chromium-cdp-setup.md](../scraping/hosted-chromium-cdp-setup.md) — EC2 CDP runbook
