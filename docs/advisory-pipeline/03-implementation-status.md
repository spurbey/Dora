# Advisory Pipeline — Implementation Status

> Last updated: 2026-04-29 (after rebuild sprint Phases 0–7)
>
> **For the rebuild that started 2026-04-26 jump straight to [§ Rebuild Sprint](#rebuild-sprint-2026-04-26--2026-04-29-phases-07).** The earlier sections describe the original 2026-04-20 build; the rebuild kept that work but fixed the structural failures it surfaced in production.
>
> **For server operations**, the canonical runbook is [05-server-ops-runbook.md](./05-server-ops-runbook.md). This file describes *what was built*; that file describes *how to run / debug / test on prod*.

## Major Commits (reverse chronological)

| Commit | Description |
|--------|-------------|
| `43f8af3` | Push notification → focused advisory in side panel (deep-link routing) |
| `5001d26` | Advisory POI markers on map + bottom detail sheet |
| `bcd92a5` | Advisory active card + Dora side panel + top-bar bell & resolver badge |
| `8301366` | Stateful conversation thread (backend + Flutter data layer) |
| `ed92aeb` | Trip metadata editor on live capture screen |
| `8f5b85c` | Advisory pipeline data-flow fixes + 4-tab nav restructure + live-tab trip creation |
| `013b1f5` | Hosted Chromium CDP setup docs + AWS EC2 terminal playbook |
| `7e267d1` | scraper_lean acquisition hardening + BrightData matrix diagnostics |
| `77bf9ac` | GMaps CDP pipeline hardening for hosted browser runtime |
| `c3d8842` | Schema + models + migration + Pydantic schemas (original) |
| `97ab144` | API endpoints + service layer + worker skeleton (original) |
| `5a65030` | Reddit scraper wired into worker stages |

---

## What's Built

### Backend — Config (`backend/app/config.py`)
- Worker polling: `ADVISORY_WORKER_POLL_SECONDS` (5.0), `ADVISORY_WORKER_STALE_SECONDS` (900)
- Cycle: `ADVISORY_CYCLE_POLL_SECONDS` (30), `ADVISORY_CYCLE_BATCH_SIZE` (50)
- Delivery: `ADVISORY_MIN_CONFIDENCE_PUSH` (0.7), `ADVISORY_MAX_PER_HOUR` (3)
- Brain geometry: `ADVISORY_SAMPLE_COUNT` (22), `ADVISORY_CENTROID_WINDOW_SECONDS` (7200), `ADVISORY_OFF_ROUTE_THRESHOLD_METERS` (5000)
- Feedback: `ADVISORY_IGNORE_PAUSE_THRESHOLD` (3), `ADVISORY_NO_PICK_RETRY_BUDGET` (2), `ADVISORY_RESEED_MIN_INTERVAL_SECONDS` (120)
- GMaps cost: `BRIGHTDATA_MAX_CALLS_PER_TRIP` (50), `BRIGHTDATA_REVIEWS_PER_POI` (4), `BRIGHTDATA_MAX_REVIEWS_PER_CYCLE` (15)
- External: `OPENROUTER_API_KEY`, `OPENROUTER_MODEL`, `BRIGHTDATA_WS_ENDPOINT` (points to EC2 Chrome CDP)
- Cache: `UPSTASH_REDIS_URL`, `UPSTASH_REDIS_TOKEN`
- Push: `FIREBASE_PUSH_ENABLED`, `FIREBASE_PROJECT_ID`, `FIREBASE_CREDENTIALS_JSON`
- Debug: `EXPOSE_ADVISORY_STATE_ENDPOINT`

### Backend — Models
- `advisory_job.py` — AdvisoryJob with state machine, partial unique index, `parent_message_id` FK
- `trip_advisory.py` — TripAdvisory with delivery-only status, dedupe constraint, `poi_place_id`, `weather_snapshot`
- `advisory_user_action.py` — append-only user actions with metadata snapshot
- `trip_advisory_state.py` — per-trip durable brain (see schema doc)
- `user_metadata.py` — per-user preferences (dietary, budget, style, dislikes, notifications, quiet hours)
- `advisory_conversation_message.py` — per-trip chat thread (dora/user/system messages)

### Backend — Migrations
Applied to production Supabase:
1. `ffd82b6d69e4_add_advisory_pipeline_tables.py` — jobs + advisories + user_actions
2. `a1b2c3d4e5f6_add_user_metadata_and_trip_brain.py` — user_metadata + trip_advisory_state
3. `d2f4e8a91b56_add_advisory_conversation.py` — conversation_messages + advisory_jobs.parent_message_id

### Backend — Schemas
- `app/schemas/advisory.py` — jobs, insights, actions, brain state
- `app/schemas/user_metadata.py` — GET/PUT `/users/me/metadata`
- `app/schemas/advisory_conversation.py` — ConversationMessageResponse, SendMessageRequest, AnswerQuestionRequest, etc.

### Backend — API (`backend/app/api/v1/advisory.py`)

**Advisory endpoints:**
| Endpoint | Method | Status | Description |
|----------|--------|--------|-------------|
| `/trips/{trip_id}/advisory/start` | POST | 202 | Create pre_trip or location_trigger job |
| `/trips/{trip_id}/advisory/query` | POST | 202 | NL query → on_demand job (legacy; `/conversation/send` is preferred) |
| `/trips/{trip_id}/advisory/jobs` | GET | 200 | List jobs (paginated, status filter) |
| `/trips/{trip_id}/advisory/insights` | GET | 200 | Inbox: `status IN (pending, delivered)` |
| `/trips/{trip_id}/advisory/pause` | POST | 204 | Manual pause (sticky) |
| `/trips/{trip_id}/advisory/resume` | POST | 204 | Explicit resume |
| `/trips/{trip_id}/advisory/state` | GET | 200 | Debug brain state (gated) |
| `/advisory/{advisory_id}/action` | POST | 200 | Record user action (append-only) |

**Conversation endpoints:**
| Endpoint | Method | Status | Description |
|----------|--------|--------|-------------|
| `/trips/{trip_id}/conversation/messages` | GET | 200 | Paginated chat thread (read-through cache) |
| `/trips/{trip_id}/conversation/send` | POST | 201 | User message → creates on_demand job linked via `parent_message_id` |
| `/trips/{trip_id}/conversation/answer` | POST | 200 | Answer Dora clarify → resumes blocked job |

**User metadata endpoints** (in `app/api/v1/users.py`):
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/users/me/metadata` | GET | Current user's advisory preferences (lazy-creates empty row) |
| `/users/me/metadata` | PUT | Upsert; triggers reseed on all active trips for this user |

### Backend — Services

- `app/services/advisory_service.py`
  - `create_advisory_job()` — ownership check, request_hash, duplicate detection, location_trigger coalescing, accepts `parent_message_id`
  - `get_advisory_jobs()`, `get_trip_advisories()`, `record_user_action()`
- `app/services/trip_brain_service.py`
  - Full brain lifecycle (see schema doc for method list)
- `app/services/advisory_cache.py`
  - Upstash REST wrapper, graceful degradation
  - Keys: `brain:*`, `geocode:*`, `weather:*`, `reddit:seed:*`, `user:*:push_throttle`, `conversation:*:messages`, `conversation:*:pending_question`
- `app/services/conversation_service.py`
  - `list_messages()` — read-through cache/DB
  - `persist_message()` — write-through DB + cache append
- `app/utils/async_tasks.py`
  - `spawn_best_effort()` — shared fire-and-forget helper used by brain seed, enrich, metadata reseed

### Backend — Worker (`backend/app/workers/advisory_worker.py`)

- Full poll loop following export_worker pattern
- `claim_next_job()` — `FOR UPDATE SKIP LOCKED`
- `recover_orphaned_jobs()` — 900s stale threshold
- Retry backoff: [30s, 120s, 480s]
- Heartbeat via `flag_modified(job, "updated_at")` during long stages
- `flag_modified` on all JSONB column updates

**Stage implementations:**

| Stage | Status | What It Does |
|-------|--------|--------------|
| route_segmentation | **Implemented** | Reads trip places, derives keywords, builds scrape plan. For on_demand jobs, loads last 10 conversation messages from cache/DB into `scrape_plan.conversation_context` |
| clarify_intent | **Planned** (feature-flagged) | LLM reads query + conversation; emits `clarifying_question` and blocks job if ambiguous. Currently a no-op behind `ADVISORY_CLARIFY_ENABLED=false` |
| reddit_scrape | **Implemented** | Crawl4AI deep crawl + OpenRouter LLM extraction |
| tripadvisor_scrape | **Stub** | Logs and skips (deferred) |
| gmaps_scrape | **Implemented** | Self-hosted Chrome CDP (EC2) search-click flow; `fix(scraping): harden gmaps CDP pipeline for hosted browser runtime` |
| llm_extraction | **Implemented** | Merges insights across sources, dedupes via SHA-256 key |
| scoring | **Implemented** | Heuristic: confidence = 0.4 base + 0.15/extra source + 0.1/signal + 0.1/named place |
| delivery | **Implemented** | Creates TripAdvisory rows, push throttle check (3/hr), **auto-appends `advisory_suggestion` message to the conversation thread** |

### Backend — Scrapers
- `app/services/scrapers/reddit_scraper.py` — Crawl4AI `BestFirstCrawlingStrategy` + `KeywordRelevanceScorer`, `URLPatternFilter` restricts to `*/comments/*`, OpenRouter LLM extraction
- `app/services/scrapers/gmaps_scraper.py` — Playwright `connect_over_cdp` → EC2 Chrome; search-click flow (not direct URL nav), global semaphore caps concurrent sessions, cost counter enforced via `TripBrainService.try_increment_brightdata()`

### Backend — Workers (separate processes)
- `advisory_worker` — job processor
- `advisory_cycle_worker` — polls `trip_advisory_state` every 30s, enqueues `location_trigger` jobs
- `advisory_ignore_sweep_worker` — polls every 10min, expires unacted advisories, pauses brain after 3 ignores

### Flutter — Data layer
- `flutter/lib/features/advisory/data/advisory_repository.dart`
  - All 8 advisory methods + 3 conversation methods (`listConversation`, `sendConversationMessage`, `answerConversationQuestion`)
- `flutter/lib/features/advisory/providers/advisory_providers.dart`
  - `advisoryBrainStateProvider`, `advisoryInsightsProvider`, `advisoryJobsProvider`
  - `advisoryActionNotifierProvider` (family)
  - `conversationMessagesProvider`, `activeAdvisoryProvider`, `pendingClarifyingQuestionProvider`
  - `conversationSendNotifierProvider` (family)
- `flutter/lib/features/advisory/advisory_guard.dart` — feature flag gate
- `flutter/lib/features/advisory/presentation/widgets/dora_avatar.dart` — reusable brand element

### Flutter — Live screen (5 layers)
- `lib/features/live_capture/presentation/screens/live_capture_screen.dart` — restructured Stack with 5 layers; accepts `advisoryFocusId` + `openSidePanel` router params
- `lib/features/live_capture/map/live_capture_map_controller.dart` — third PointAnnotationManager for advisory POIs, diff-based reconcile, image cache keyed by `emoji|tint|accepted`, tap listener
- `lib/features/live_capture/map/live_capture_map_widget.dart` — exposes `advisoryMarkers` + `onAdvisoryMarkerTap` props, signature-hash diffing
- `lib/core/map/utils/marker_image_painter.dart` — `drawAdvisoryMarker(emoji, tint, accepted)` renders 88px PNG with halo shadow
- `lib/features/live_capture/presentation/widgets/live_capture_top_bar.dart` — adds resolver badge pill + Dora bell with unread count
- `lib/features/live_capture/presentation/widgets/advisory_active_card.dart` — floating card, Save/Navigate/Dismiss, Dismissible swipe, tap → bottom sheet
- `lib/features/live_capture/presentation/widgets/advisory_side_panel.dart` — chat thread with rich bubbles (advisory, clarify w/ option chips, user, system note), optimistic send, 15s polling while open, full-screen on compact devices
- `lib/features/live_capture/presentation/widgets/live_capture_bottom_detail_sheet.dart` — `DraggableScrollableSheet`, sealed content types (AdvisoryPoiDetail, CapturedMediaDetail, PlaceDetail)

### Flutter — Notifications
- `lib/core/notifications/live_tracking_deep_link_bootstrap.dart` — routes `type=advisory|advisory_clarifying` payloads to `/trips/{id}/live?advisoryFocus={id}&openSidePanel=1`
- `lib/core/navigation/app_router.dart` — `/trip/:id/advisory` legacy fallback redirects and preserves query params

### Flutter — Navigation
- 4-tab nav: Feed / Live / Trips / Profile (Create tab removed)
- Live tab hosts trip creation form with inline advisory metadata (activity_focus, travel_style, budget_category)
- First-trip user prefs collection bottom sheet (dietary, dislikes, preferred style)

### Flutter — OpenAPI client
- Generated into `flutter/packages/dora_api/`
- All advisory + conversation endpoints + user_metadata endpoints available

---

## Test Results

**Backend smoke test (2026-04-20):**
- Full pipeline run for trip "sumit"
- Reddit scrape extracted 11 insights across r/IndiaTravel, r/solotravel, r/travel
- Scored: all at 0.5-0.6 confidence
- **10 TripAdvisory rows delivered** across categories: accommodation, avoid, must_do, transport_tip, scam_alert, general_tip
- Conversation service: user_query persist → list roundtrip works; cache read-through warms from DB on miss

**Flutter analyze:**
- Zero errors across entire codebase after all phases (B, C, D, F)
- Clean compile of live_capture screen with 5-layer stack + side panel + bottom sheet

**EC2 hosted CDP verification** (from `77bf9ac`):
- Backend scraper module integration test: 3 POIs + 3 reviews extracted successfully
- Chrome CDP endpoint at `http://13.234.231.218:9222` responsive

---

## What's NOT Built Yet

### Short-term
- [ ] **Phase E: clarify_intent stage** — LLM prompt template designed (see 01-architecture.md), feature flag `ADVISORY_CLARIFY_ENABLED` reserved, but stage implementation + `/conversation/answer` resume path in worker not yet coded. UI (option chips, quick-answer above input) is already ready and will activate automatically once backend emits `clarifying_question` messages.
- [ ] **TripAdvisor scraper** — Crawl4AI with TripAdvisor URL patterns (deferred)
- [ ] **Runtime verification on device** — backend + workers + Flutter all green in isolation; end-to-end on physical device / emulator not yet exercised
- [ ] **Captured media bottom sheet detail** — placeholder widget; photo review UX to be built in future slice
- [ ] **Place detail bottom sheet** — placeholder widget; for when user taps saved places

### Future (Post-MVP)
- [ ] Preference learning algorithm — query `advisory_user_actions` + conversation user_queries + `trip_places` + `place_saves`
- [ ] Advanced scoring — LLM-based relevance instead of heuristic
- [ ] Long-conversation summary — when thread exceeds 30 msgs, generate `conversation_summary` stored on brain
- [ ] Multi-model fallback — if free OpenRouter model rate-limits, fall back to cheap paid
- [ ] Advisory marker clustering (Mapbox clusters) for dense POI areas
- [ ] Advisory quiet-hours enforcement in delivery stage
- [ ] Mid-conversation attachments (photos, location pins user sends to Dora)

---

## How to Test Locally

### Prerequisites
```bash
cd backend
pip install -r requirements.txt  # includes crawl4ai, playwright
playwright install chromium
```

Required env in `backend/.env`:
```
OPENROUTER_API_KEY=sk-or-v1-...
BRIGHTDATA_WS_ENDPOINT=http://13.234.231.218:9222   # EC2 CDP
UPSTASH_REDIS_URL=...                                # optional, pipeline works without
UPSTASH_REDIS_TOKEN=...
```

Apply migrations:
```bash
cd backend && alembic upgrade head
```

### Run all three advisory workers (separate terminals)
```bash
cd backend
python -m app.workers.advisory_worker
python -m app.workers.advisory_cycle_worker
python -m app.workers.advisory_ignore_sweep_worker
```

### Test conversation end-to-end via API

```bash
# Send a user message → triggers on_demand pipeline
curl -X POST http://localhost:8000/api/v1/trips/{trip_id}/conversation/send \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"content": "any good food around here?"}'

# Check the thread (includes auto-appended advisory_suggestion after worker delivers)
curl http://localhost:8000/api/v1/trips/{trip_id}/conversation/messages \
  -H "Authorization: Bearer <token>"
```

### Test pre_trip advisory (legacy path)

```bash
curl -X POST http://localhost:8000/api/v1/trips/{trip_id}/advisory/start \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"job_type": "pre_trip"}'

curl http://localhost:8000/api/v1/trips/{trip_id}/advisory/insights \
  -H "Authorization: Bearer <token>"
```

### Test Flutter live screen
1. Create a trip from the Live tab with `activity_focus` filled
2. Start the live session → advisory brain flips `seeded → active`
3. Tap the Dora bell in top bar → side panel slides in, thread loads
4. Type a message → optimistic bubble appears, Dora response arrives after worker completes
5. Advisories appear on map as suggested markers; Save → marker restyles to accepted
6. Tap any advisory → bottom sheet slides up with full detail + actions

---

## File Map

```
backend/
├── app/
│   ├── config.py                                  # Advisory + cycle + feedback settings
│   ├── main.py                                    # Advisory router + users router registered
│   ├── models/
│   │   ├── advisory_job.py                        # AdvisoryJob (+ parent_message_id)
│   │   ├── trip_advisory.py                       # TripAdvisory
│   │   ├── advisory_user_action.py                # AdvisoryUserAction
│   │   ├── trip_advisory_state.py                 # per-trip brain
│   │   ├── user_metadata.py                       # per-user advisory preferences
│   │   └── advisory_conversation_message.py       # chat thread
│   ├── schemas/
│   │   ├── advisory.py
│   │   ├── user_metadata.py
│   │   └── advisory_conversation.py
│   ├── api/v1/
│   │   ├── advisory.py                            # advisory + conversation endpoints
│   │   └── users.py                               # user_metadata endpoints
│   ├── services/
│   │   ├── advisory_service.py                    # job creation, actions
│   │   ├── trip_brain_service.py                  # brain lifecycle
│   │   ├── advisory_cache.py                      # Upstash wrapper + conversation cache
│   │   ├── conversation_service.py                # read-through/write-through thread
│   │   ├── push_service.py                        # Firebase push (advisory variant)
│   │   └── scrapers/
│   │       ├── reddit_scraper.py                  # Crawl4AI + OpenRouter
│   │       └── gmaps_scraper.py                   # Playwright CDP to EC2 Chrome
│   ├── utils/
│   │   └── async_tasks.py                         # spawn_best_effort helper
│   └── workers/
│       ├── advisory_worker.py                     # 7-stage pipeline
│       ├── advisory_cycle_worker.py               # per-trip cycle scheduler
│       └── advisory_ignore_sweep_worker.py        # TTL sweep + pause
├── alembic/versions/
│   ├── ffd82b6d69e4_add_advisory_pipeline_tables.py
│   ├── a1b2c3d4e5f6_add_user_metadata_and_trip_brain.py
│   └── d2f4e8a91b56_add_advisory_conversation.py

flutter/lib/features/
├── advisory/
│   ├── data/advisory_repository.dart              # + 3 conversation methods
│   ├── data/models/advisory_brain_state.dart
│   ├── providers/advisory_providers.dart          # + conversation providers
│   ├── presentation/
│   │   ├── widgets/dora_avatar.dart
│   │   └── screens/advisory_debug_screen.dart
│   └── advisory_guard.dart
├── live_capture/
│   ├── map/
│   │   ├── live_capture_map_widget.dart           # + advisoryMarkers prop
│   │   └── live_capture_map_controller.dart      # + advisory annotation manager
│   └── presentation/
│       ├── screens/live_capture_screen.dart       # 5-layer Stack
│       └── widgets/
│           ├── live_capture_top_bar.dart          # + resolver badge + Dora bell
│           ├── advisory_active_card.dart          # floating card
│           ├── advisory_side_panel.dart           # chat thread + input
│           └── live_capture_bottom_detail_sheet.dart

scraper_reddit/                                    # standalone prototype
scraper_lean/                                      # standalone prototype
docs/
├── advisory-pipeline/
│   ├── 01-architecture.md
│   ├── 02-database-schema.md
│   └── 03-implementation-status.md                # this file
└── scraping/
    ├── README.md
    └── hosted-chromium-cdp-setup.md               # EC2 setup runbook
```

## Related Docs

- [01-architecture.md](./01-architecture.md) — system design, data flow, design decisions
- [02-database-schema.md](./02-database-schema.md) — table definitions, indexes, constraints
- [04-current-server-behavior-baseline.md](./04-current-server-behavior-baseline.md) — pre-rebuild observed behavior (the failures that motivated the rebuild)
- [05-server-ops-runbook.md](./05-server-ops-runbook.md) — **canonical AWS/SSM/E2E playbook for prod operations**
- [../scraping/hosted-chromium-cdp-setup.md](../scraping/hosted-chromium-cdp-setup.md) — EC2 Chrome CDP runbook
- [../deployment/server-terminal-to-ec2-beginner-guide.md](../deployment/server-terminal-to-ec2-beginner-guide.md) — beginner-friendly SSM tutorial

---

## Rebuild Sprint (2026-04-26 → 2026-04-29) — Phases 0–7

**Why:** by 2026-04-25 the original build was shipping garbage advisories in production ("Popular place in Parliament Of India — 66 reviews, 4.3 rated" — a canteen). Server diagnosis surfaced **six stacked failures**:

1. Primary OpenRouter model `gpt-oss-120b:free` chronic 503s (13× in 34h)
2. Reverse-geocode picking building names ("Parliament Of India") instead of city ("Delhi")
3. Reddit scraper (Crawl4AI) returning 0 insights even on sane queries
4. Cadence persistence failing intermittently — 12 jobs every 2 min for one trip
5. `_fallback_copy` producing templated junk when LLM 503s
6. 11 of 12 real-user trips never starting V2 sessions (separate Flutter sprint, deferred)

The rebuild restructured orchestration around **Mode A (planning, Reddit-primary) / Mode B (live_companion, Reddit + GMaps)**, with the LLM as orchestrator instead of passive ranker. Plan source: `~/.claude/plans/glistening-sniffing-reef.md`.

### Phase 0 — LLM foundation
**Goal:** reliable structured-JSON LLM calls; replace the ad-hoc `httpx` + `gpt-oss-120b:free` with something stable.

**Built:**
- `backend/app/services/llm.py` — single `chat_json(messages, schema, …)` entry point. Returns parsed dict on success, `None` on any failure. Internal retries + automatic fallback.
- **Bedrock primary path:** when `LLM_PROVIDER=bedrock`, calls Claude Haiku 4.5 via `bedrock-runtime.{region}.amazonaws.com/model/{id}/converse` with bearer-token auth. Forced tool-use schema for guaranteed parseable JSON. Single `BEDROCK_API_KEY` (no IAM key+secret) — separate AWS account from the Lambda/S3 one.
- **OpenRouter chain as failover:** ordered list `OPENROUTER_FALLBACK_MODELS` (DeepSeek V4 Flash → nvidia/nemotron-3-super → glm-4.5-air → minimax → qwen → llama-3.3). On Bedrock failure or 5xx from a model, the chain rotates.
- All previous LLM call sites (advisory_ranker, Crawl4AI extraction) migrated to `chat_json`.

**Verified on prod (2026-04-29):** Bedrock smoke `RESULT: {'ok': True}` in api + advisory_worker containers. Token usage 660 in / 33 out per call.

### Phase 1 — City-level locality
**Goal:** stop reverse-geocode from returning building/POI names.

**Built:** `geocoding_service.reverse_geocode` now walks the Mapbox feature-context array, preferring `place` (city) > `region` > `locality` (neighborhood). Returns first non-empty layer ≥ city scope.

**Verified on prod:** `reverse_geocode(28.6172, 77.2079)` (Parliament House GPS) returns `"New Delhi"` / region `"Delhi"` / locality_key `in:Delhi:New Delhi`. Pune→Goa polyline reverse-geocodes to 15 real cities (`Pune, Bhor, Khandala, Wai, Satara, Panhala, Patan, Sawantwadi, Dharbandora, Dodamarg, Radhanagari, Bhudargad, Shahuwadi, Ajra, Satari`).

### Phase 2 — Cadence persistence
**Goal:** eliminate the "12 jobs every 2 min for one trip" symptom by guaranteeing brain writes survive.

**Built:** `trip_brain_service.mark_cycle_outcome` now runs in a single explicit transaction (`with _safe_tx(self.db):`). Removed the `db.begin_nested()` conditional path. Callers updated to ensure no open transaction on entry.

**Verified on prod:** `seed_on_trip_creation` UPDATE round-trips cleanly; `last_seed_at` advances. (Full cycle persistence — `last_cycle_at` advancing on cycle-triggered jobs — only fires for cycle worker, not on_demand. To be confirmed when V2 sessions land.)

### Phase 3 — Reddit scraper rebuild
**Goal:** Crawl4AI's `BestFirstCrawlingStrategy` returns 0 deep links from Reddit search pages. Rebuild without it.

**Built:** `scrape_reddit_v2` (in `app/services/scrapers/reddit_v2.py`) — 4-stage pipeline:
1. **plan**: Bedrock generates subreddit list + queries from cities + intent
2. **search**: Playwright headed Chromium (xvfb in container) hits `old.reddit.com` search across `r/IndiaTravel`, `r/india`, `r/indiafood`, etc.; extracts post URLs
3. **fetch**: opens each post URL, scrapes top-comments markdown
4. **extract**: per-post Bedrock call extracts structured `TravelInsight[]`

Uses **BrightData residential proxy** (`brd.superproxy.io:33335`) — Reddit blocks datacenter IPs server-side; residential IPs are the only path that works.

`advisory_worker._stage_reddit_scrape` rewired to call `scrape_reddit_v2` (the old Crawl4AI path is dead code).

**Verified on prod (2026-04-29):** the `reddit_scrape` stage ran for ~93s and produced enough insights for the merge_dedup → scoring → delivery chain to emit 34 advisories.

### Phase 4 — Mode A/B phase machine
**Goal:** stop firing the full 7-stage pipeline on every cycle. Route different sources at different cadences based on trip phase.

**Built:**
- **Brain schema:** `trip_advisory_state.phase` VARCHAR(20) NOT NULL DEFAULT `'planning'` CHECK in (`'planning'`, `'live_companion'`, `'paused'`); `locality_confidence` JSONB NOT NULL DEFAULT `'{}'`; `last_phase_change_at` timestamptz. Migration `a7f9c2e4d8b1_brain_phase_confidence.py`.
- **Phase transitions:**

  | From | To | Trigger |
  |---|---|---|
  | (new) | planning | trip creation (`seed_on_trip_creation`) |
  | planning | live_companion | first V2 session start (`enrich_on_tracking_start`) |
  | live_companion | planning | session ended >24h |
  | any | paused | inactivity / manual pause |

- **Stage paths per phase** (`STAGE_PATHS_BY_PHASE` in `advisory_worker.py:39`):
  - **planning:** `clarify_intent → route_segmentation → reddit_scrape → merge_dedup → scoring → delivery`
  - **live_companion:** `clarify_intent → route_segmentation → reddit_scrape → gmaps_scrape → merge_dedup → scoring → delivery`
  - **paused:** minimal — `route_segmentation → merge_dedup → delivery` (no-harm)

- **Cycle worker is now a trigger detector** (`advisory_cycle_worker.py`): replaced the time-driven `claim_due_trips` enqueue with a per-trip `detect_triggers` → `consider_trigger` → `create_advisory_job` flow. Trigger types: `region_jump`, `context_shift`, `user_query`, `route_changed`, `metadata_changed`. Time-based `next_eligible_at` is now a soft floor, not the firing mechanism.
- **`_ACTIVITY_TO_CATEGORIES` mapping** (in `advisory_cycle_worker.py`): `food → food_tip`, `hiking → must_do + photo_spot`, etc. Used by the confidence-skip gate so a trip with high confidence in `(locality, food_tip)` doesn't re-fire when activity_focus contains `food`.

**Verified on prod:** the planning stage path executes in declared order. The live_companion path is wired but unverified pending Flutter V2 sessions.

### Phase 5 — clarify_intent + locality_confidence
**Goal:** mandatory ask-first fallback when cached findings are weak. Stop the "guess and produce garbage" pattern.

**Built:**
- **`locality_confidence` storage** (added in Phase 4 migration): JSONB shape `{locality_key: {category: float, _signals: {reddit, gmaps, ugc}}}`. Updated by delivery stage.
- **`_stage_clarify_intent`** in `advisory_worker.py:1077`. Reads `(locality, intent)` confidence from brain. If conf ≥ 0.7 → skip. If conf 0.5–0.7 → optional. If conf < 0.5 → mandatory: Bedrock returns `{status: clarify|ready|impossible, question, options}`. On `clarify`, persists `clarifying_question` message + blocks job (`status='blocked', reason='waiting_user_response'`).
- **Resume path** (`/api/v1/advisory/conversation/answer`): when user picks an option chip, persists user response, looks up the blocked job from the cache, patches `scrape_plan.clarified_filters = answer` + `scrape_plan.user_asked_clarify = True`, sets `status='queued'`. Worker's next claim picks it up; clarify_intent now returns `ready` and proceeds.
- **Feature flag:** `ADVISORY_CLARIFY_ENABLED=false` by default in compose. Stage exists in path but no-ops when disabled.

**Verified on prod:** the stage transitions cleanly when disabled (no constraint violation, no LLM call). Ask-flow itself unverified pending flag flip + ambiguous query test.

### Phase 6 — display_kind + place_polygon
**Goal:** every advisory needs an explicit spatial-rendering hint for the map-first UI work.

**Built:**
- Migration `b8a3d6f1c5e2_advisory_display_kind.py`:
  - `display_kind` VARCHAR(20) NOT NULL DEFAULT `'ambient'` CHECK in (`point`, `polygon`, `route_overlay`, `ambient`)
  - `place_polygon` JSONB nullable (forward-looking — no polygon advisories generated this sprint)
  - Index `idx_advisory_trip_display` on `(trip_id, display_kind)`
- Model field on `TripAdvisory` + Pydantic `AdvisoryInsightResponse.display_kind`.
- `_resolve_display_kind(category, has_pin)` mapping in `advisory_worker.py`:
  - `transport_tip` → `route_overlay`
  - has `place_lat` → `point` (fires on GMaps results in live_companion)
  - everything else → `ambient`

**Verified on prod (2026-04-29):** 34 advisories all have `display_kind` set. Distribution: 33× `ambient` (Reddit insights without coords), 1× `route_overlay` (a `transport_tip` from extraction). `point` distribution awaits GMaps E2E.

### Phase 7 — stage CHECK constraint fix (regression caught in E2E)
**Goal:** unblock advisory_worker which got stuck in a retry loop after the rebuild.

**Discovered:** during the Day-7 E2E on 2026-04-29, the test job hung in `route_segmentation` for 180+s. Worker logs showed `(psycopg2.errors.CheckViolation) … check_advisory_job_stage` repeating every 5s. The original migration `ffd82b6d69e4` declared `stage IN ('route_segmentation','reddit_scrape','tripadvisor_scrape','gmaps_scrape','llm_extraction','scoring','delivery')`. Phase 4/5 added `clarify_intent` and `merge_dedup` (the latter renamed from `llm_extraction`) but never updated the constraint.

**Fix:**
1. **Live patch** via SSM: `ALTER TABLE advisory_jobs DROP CONSTRAINT check_advisory_job_stage; ALTER TABLE advisory_jobs ADD CONSTRAINT … CHECK (stage IS NULL OR stage IN (…full set…))`. Unblocked the worker immediately.
2. **Permanent migration:** `backend/alembic/versions/d2e7a8b3f4c1_advisory_job_stage_constraint.py` chained off the actual prod head `d8b7c6a5e4f3`. Idempotent (uses `DROP CONSTRAINT IF EXISTS`). Applied via local `alembic upgrade head` (which targets the same Supabase DB as prod via `SUPABASE_DB_URL`). Prod alembic head is now `d2e7a8b3f4c1`.

**Verified:** re-ran E2E after the fix → job completed in 102.4s, 34 advisories produced.

---

## Day-7 E2E Verification (2026-04-29)

End-to-end test driven entirely server-side via SSM. Created a synthetic Pune→Goa trip with route geometry, drove it through `seed_on_trip_creation` → on_demand job → full pipeline → cleanup. Test driver script lives in [05-server-ops-runbook.md § 5](./05-server-ops-runbook.md#5-the-day-7-e2e-test).

| Phase | Verified | Notes |
|---|---|---|
| 0 — Bedrock LLM | ✅ | smoke 200 OK in api + advisory_worker |
| 1 — Locality fix | ✅ | Parliament House → "New Delhi"; Pune→Goa → 15 real cities |
| 2 — Cadence persistence | ✅ | seed UPDATE survives; brain `last_seed_at` advances |
| 3 — Reddit v2 scrape | ✅ | reddit_scrape stage produced enough insights for delivery |
| 4 — Mode A/B phase machine | ✅ | planning path executed in declared order |
| 5 — clarify_intent | ⚠️  partial | stage transitions cleanly when disabled; ask-flow itself unverified |
| 6 — display_kind | ✅ | all 34 advisories have `display_kind` set with correct mapping |
| 7 — stage constraint | ✅ | live patch + migration both applied; alembic head = `d2e7a8b3f4c1` |

**Net result:** 34 advisories delivered in 102.4s for "best food spots in Pune". Categories: `food_tip`, `must_do`, `general_tip`, `avoid`, `transport_tip`. No churn, no stuck jobs.

### Not yet exercised on prod (deferred)

- **GMaps scraping (live_companion phase)** — needs a `trip_tracking_sessions` row + brain phase flip. Blocked on Flutter V2 sessions actually firing for real users.
- **Cycle worker trigger detection** (`region_jump`, `route_changed`) — periodic detector logic rewritten in Phase 4 but never observed firing on real GPS injection.
- **clarify_intent ask-flow** — gated by `ADVISORY_CLARIFY_ENABLED=false`. To test: flip env, redeploy, send ambiguous query like `"find food"`.
- **Push notifications** — `FIREBASE_PUSH_ENABLED=false`.
- **OpenRouter failover chain** — only kicks in on Bedrock failure. To exercise: temporarily flip `LLM_PROVIDER=openrouter`.

---
