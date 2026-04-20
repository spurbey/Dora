# Advisory Pipeline — Implementation Status

> Last updated: 2026-04-20

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
- [../scraping/hosted-chromium-cdp-setup.md](../scraping/hosted-chromium-cdp-setup.md) — EC2 Chrome CDP runbook
