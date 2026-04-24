# Advisory Pipeline — Architecture

> Dora's travel advisory system proactively recommends POIs, warns about scams, and suggests activities to travelers during live trips. It scrapes Reddit + Google Maps, ranks results via rules + LLM, delivers push notifications, and exposes a **stateful chat interface** where the user can converse with Dora mid-trip. All driven by a per-trip "brain" that tracks state, adapts to user feedback, and pauses on inactivity.

## System Overview

```
Flutter App (Live Screen — 5 stacked layers)
    │
    ├─ [L1] Map with advisory POI markers (suggested / accepted)
    ├─ [L2] HUD: top bar (resolver badge + Dora bell), action dock,
    │       active advisory card (floats above bottom panel)
    ├─ [L3] Transient effects (Lottie bursts)
    ├─ [L4] Advisory side panel — chat thread with Dora
    │       (slides from right, polls every 15s while open)
    └─ [L5] Bottom detail sheet — POI / photo / place detail (draggable)
          │
          │  HTTPS (Bearer auth)
          ▼
    FastAPI Backend
          │
          ├─ POST /advisory/start                    (pre-trip or manual reseed)
          ├─ POST /advisory/query                    (one-shot NL query)
          ├─ POST /advisory/pause                    (manual pipeline pause)
          ├─ POST /advisory/resume                   (explicit resume)
          ├─ GET  /advisory/insights                 (inbox: pending + delivered)
          ├─ GET  /advisory/state                    (debug: brain state, gated)
          ├─ POST /advisory/{id}/action              (liked / dismissed / saved / acted_on)
          │
          ├─ GET  /trips/{id}/conversation/messages  (paginated thread, read-through cache)
          ├─ POST /trips/{id}/conversation/send      (user message → triggers pipeline)
          └─ POST /trips/{id}/conversation/answer    (user answers Dora clarify → resumes blocked job)
          │
          ▼
    Services
          │
          ├─ AdvisoryService   — creates jobs, records actions
          ├─ ConversationService — read-through (cache→DB) / write-through persist
          ├─ TripBrainService  — per-trip state machine, snapshots, feedback loop
          └─ AdvisoryCache     — Upstash Redis hot cache (graceful degradation)
                │
                ▼
    Postgres
          ├─ advisory_jobs                    (job queue)
          ├─ trip_advisories                  (delivered insights)
          ├─ advisory_user_actions            (append-only engagement log)
          ├─ trip_advisory_state              (per-trip durable brain)
          └─ advisory_conversation_messages   (per-trip chat thread)
```

## Worker Processes

```
┌─── Advisory Cycle Worker (polls trip_advisory_state every 30s) ──┐
│                                                                   │
│  For each active trip whose next_eligible_at <= now():            │
│    pick_next_target(trip_id)                                      │
│      route mode: sample polyline, project GPS, geocode next city  │
│      radius mode: centroid of live GPS, reverse geocode           │
│    → create location_trigger AdvisoryJob                          │
└───────────────────────────────────────────────────────────────────┘
                │
                ▼
    Advisory Worker (polls advisory_jobs)
          │
          ├─ 1. route_segmentation   → derive keywords from target locality + metadata;
          │                             on_demand jobs also load conversation_tail (last 10 msgs)
          │                             from cache/DB and attach to scrape_plan.conversation_context
          ├─ 2. clarify_intent       → (feature-flagged, on_demand only) LLM reads query +
          │                             conversation; if ambiguous, emits clarifying_question and
          │                             blocks the job until user answers
          ├─ 3. reddit_scrape        → Crawl4AI deep crawl + OpenRouter LLM extraction
          ├─ 4. tripadvisor_scrape   → (deferred, stub)
          ├─ 5. gmaps_scrape         → self-hosted Chrome CDP: POI search + 3-4 reviews each
          ├─ 6. llm_extraction       → merge + dedupe Reddit insights
          ├─ 7. scoring              → hard filter + soft score + LLM final 3 picks
          └─ 8. delivery             → TripAdvisory rows + Firebase push + brain update +
                                        append advisory_suggestion to conversation thread
                │
                ▼
    trip_advisories table → Flutter inbox + map markers + side panel thread
    advisory_conversation_messages append (advisory_suggestion, role=dora)
    trip_advisory_state updated via mark_cycle_outcome()
                │
                ▼
    ┌─── Ignore Sweep Worker (polls every 10 min) ──┐
    │  Delivered advisories with no user action       │
    │  after ADVISORY_IGNORE_TTL → expired            │
    │  brain.ignore_streak incremented                │
    │  3 consecutive ignores → pipeline paused        │
    └─────────────────────────────────────────────────┘
```

## Data Flow

### Trip Creation (auto-seed)
1. User creates trip via Live tab form (or normal Trips tab flow) → `trip_advisory_state` row auto-created (`lifecycle_state=seeded`)
2. Trip classified by rule table (long_road / short_road / intra_city / day_trip / multi_day_leisure)
3. If route exists: polyline sampled into 22 equal-distance points, each reverse-geocoded (Mapbox)
4. Metadata snapshot frozen (`trip_metadata` + `user_metadata`)

### Tracking Start (enrich + activate)
1. User starts live session (V2 `POST /sessions:start`) → `enrich_on_tracking_start()` fires fire-and-forget with a fresh DB session
2. `lifecycle_state` → `active`, `next_eligible_at` set to `now() + cadence`
3. Cycle worker begins firing every `cadence_seconds` (determined by trip class)

### Per-Cycle Advisory (location_trigger)
1. Cycle worker picks next uncovered locality (route mode) or geocodes live centroid (radius mode)
2. Creates `location_trigger` AdvisoryJob with target context
3. Worker runs: Reddit scrape for target locality → GMaps POI search → rule-filter (weather/dedupe/warnings) → soft-score (dietary/time/activity) → LLM picks top 3 with copy
4. `TripAdvisory` rows persisted with `poi_place_id` + `weather_snapshot`
5. Firebase push for confidence ≥ 0.7 (Redis per-user throttle: max 3/hr); payload includes `advisory_id`
6. Delivery stage **auto-appends** `advisory_suggestion` message to the conversation thread (`role=dora`), keeping Flutter's chat panel in sync
7. Brain updated: locality + POIs recorded, categories balanced, `next_eligible_at` advanced

### User Conversation (on-demand)
1. User types in the side panel → `POST /conversation/send` → persists `user_query` message + creates `on_demand` AdvisoryJob linked via `parent_message_id`
2. `route_segmentation` loads last 10 conversation messages from `conversation:{trip_id}:messages` cache (or DB on miss) and attaches to `scrape_plan.conversation_context` for LLM context
3. If `ADVISORY_CLARIFY_ENABLED`: `clarify_intent` stage runs. LLM decides:
   - **ready** → pipeline continues
   - **clarify** → persists `clarifying_question` message (`role=dora`) with options, sets `conversation:{trip_id}:pending_question` cache, blocks job with `status=blocked`, sends `advisory_clarifying` push
4. User answers via `POST /conversation/answer` → persists `user_response` message, patches blocked job (`scrape_plan.clarified_filters`, `status=queued`, `stage=reddit_scrape`), clears pending_question cache
5. Worker resumes, delivers advisories, auto-appends them to the thread

### Push Notification → Focused Advisory
1. Delivery stage pushes `type=advisory` (or `advisory_clarifying`) with `advisory_id` in payload
2. Flutter deep-link handler receives → navigates to `/trips/{local_id}/live?advisoryFocus={id}&openSidePanel=1`
3. `LiveCaptureScreen` reads router extras, opens side panel, scrolls to + highlights the advisory message

### User Feedback Loop
- **Accept** (`liked`/`saved`/`acted_on`/`converted_to_place`): `ignore_streak` reset → 0; if paused due to inactivity, implicit resume. Recording an action also appends a `system_note` to the conversation ("You saved this")
- **Reject** (`dismissed`): `ignore_streak` reset → 0; no re-suggestion of that POI
- **Ignore** (no action for 1hr): sweep marks expired, `brain.ignore_streak++`
- **3 consecutive ignores**: pipeline paused, "paused due to inactivity" push sent
- **Manual pause**: `POST /advisory/pause` → `paused_reason='user'`; only explicit `POST /advisory/resume` clears

### Route/Metadata Change (reseed)
1. Route update detected via `routes.geom_sig` change → `reseed(route_changed)`
2. Trip metadata PATCH → `reseed(metadata_changed)` (via `_best_effort_metadata_reseed` helper)
3. Debounced: if `last_seed_at < 120s` ago, reasons queued in `pending_reseed_reasons[]`
4. Cycle worker flushes pending reseeds after window; single coalesced run
5. Preserves `advised_locality_keys` + `advised_poi_place_ids` + `ignore_streak`

## Trip Classification Rule Table

| trip_class | Detection | cadence |
|---|---|---|
| long_road | route exists, distance > 300km | 60min |
| short_road | route exists, 50 < distance ≤ 300km | 30min |
| multi_day_leisure | duration > 3d, distance ≤ 300km | 120min |
| day_trip | duration ≤ 1d, distance ≤ 150km | 45min |
| intra_city | no route OR distance < 50km | 90min |
| unclassified | fallback | 60min |

Intra-city uses **radius mode** (rolling 2h GPS centroid); all others use **route mode** (polyline sample traversal).

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Per-trip durable brain (`trip_advisory_state`) + Redis hot cache | Auditable state machine; Redis only for hot reads + centroid buffer |
| Per-trip conversation thread (`advisory_conversation_messages`), not separate thread table | One thread per trip keeps model simple; composite index on `(trip_id, created_at)` serves both "load tail" and "time range" queries |
| Cache-aside conversation tail (`conversation:{trip_id}:messages`, 30-msg, 24h TTL) | Chat panel polls every 15s while open; cache read is 5ms vs 50-100ms DB join. Write-through via `append_conversation_message` |
| Fire-and-forget `enrich_on_tracking_start` with fresh DB session | Session start is latency-sensitive; brain activation shouldn't block the response |
| Shared `spawn_best_effort` utility for async side-effect tasks | Single pattern for advisory brain seed, reseed, enrich, and reseed-on-metadata-change |
| Claim-then-process cycle worker with `make_interval` lease | Short row-lock on claim (ms); crashed worker's claim auto-expires |
| `mark_cycle_outcome` with 5 outcomes (delivered/no_pick/failed/no_target/off_route) | Eliminates stall where `next_eligible_at` never advances |
| no_pick retry budget (2) before locality marked covered | Transient failures (API blip, thin scrape results) don't permanently kill a locality |
| Off-route skip (5km nearest-leg threshold via `route_geom` geography) | Prevents advising on wrong corridor when user deviates |
| Self-hosted Chrome CDP on EC2 (replaced BrightData) | Persistent Chromium profile needed to bypass Google Maps "limited view"; BrightData's fresh-context browsers couldn't render reviews |
| Atomic BrightData counter with cap check in single UPDATE | Legacy cost cap carried over — still enforced as a safety net |
| Push throttle per-user (not per-trip) via Redis INCR | Stricter across multi-trip scenarios; avoids notification spam |
| Ignore detection via TTL sweep + NOT EXISTS guarded UPDATE | Race-safe with late user actions; defense-in-depth in `apply_feedback` |
| Reseed debounce (120s) with `pending_reseed_reasons TEXT[]` | Prevents thrashing on rapid route edits; single coalesced run |
| Delivery auto-appends `advisory_suggestion` to conversation | Every Dora advisory naturally appears in the chat thread — no separate sync path, DB is source of truth |

## External Dependencies

| Service | Purpose | Required? |
|---------|---------|-----------|
| OpenRouter (LLM) | Reddit extraction + POI ranking + (future) clarify intent | Yes — stages skip if missing |
| Self-hosted Chrome CDP on EC2 | Google Maps POI search + reviews via Playwright `connect_over_cdp` | No — `gmaps_scrape` skips gracefully; Reddit-only advisories still fire. See [hosted-chromium-cdp-setup](../scraping/hosted-chromium-cdp-setup.md) |
| Mapbox (Geocoding) | Reverse geocode route samples + radius centroid | Yes — advisory trigger disabled without it |
| Open-Meteo (Weather) | 3h forecast for POI weather-matching | No — rule-filter falls through without it |
| Upstash Redis | Brain cache, centroid buffer, push throttle, geocode/weather cache, conversation tail, pending_question | No — pipeline works without it, just slower |
| Crawl4AI | Reddit deep crawling | Yes — core scraping engine |
| Playwright + Chromium | Browser for Crawl4AI + hosted CDP | Yes |
| Firebase Admin SDK | Push notifications | No — delivery still writes DB rows without it |

## Deployment

```
Railway Worker Service (separate processes, same Docker image):
  ├── python -m app.workers.export_worker                 (video exports)
  ├── python -m app.workers.live_tracking_worker          (location inference)
  ├── python -m app.workers.advisory_worker               (advisory pipeline)
  ├── python -m app.workers.advisory_cycle_worker         (periodic brain cycle)
  └── python -m app.workers.advisory_ignore_sweep_worker  (ignore detection)

EC2 scraping node (ap-south-1, t3.medium, 60GB gp3):
  ├── chrome-cdp.service          (Xvfb + headed Chrome on :9223)
  └── chrome-cdp-proxy.service    (socat :9222 → :9223, public CDP endpoint)
```

All workers poll PostgreSQL independently using `FOR UPDATE SKIP LOCKED`. The backend's `BRIGHTDATA_WS_ENDPOINT` config points to the EC2 CDP endpoint — no code change was needed when switching from BrightData.

## Flutter Architecture (live screen)

```
LiveCaptureScreen (5 stacked layers via Stack)
├── Layer 1: LiveCaptureMapWidget
│     ├── GPS dot + trail (existing)
│     └── Advisory POI markers (suggested pulse / accepted solid)
│         via third PointAnnotationManager, diff-based reconcile
├── Layer 2: HUD
│     ├── LiveCaptureTopBar (resolver badge + Dora bell)
│     ├── LiveCaptureActionDock (photo / note / warn / media / tag)
│     ├── AdvisoryActiveCard (floats above bottom panel when pending)
│     └── LiveCaptureBottomPanel (start/pause/resume/stop)
├── Layer 3: LiveCaptureTransientEffects (Lottie bursts)
├── Layer 4: AdvisorySidePanel (slides from right, chat thread + input)
│     ├── Dora advisory_suggestion bubbles (rich card, Save/Dismiss inline)
│     ├── Dora clarifying_question bubbles (option chips)
│     ├── User bubbles (right-aligned accent)
│     ├── System notes (centered, italic)
│     ├── Text input + send button (optimistic + polling)
│     └── Quick-answer chips pinned above input when pending question
└── Layer 5: LiveCaptureBottomDetailSheet (DraggableScrollableSheet)
      └── POI detail / photo review / place notes
```

## Related Docs

- [02-database-schema.md](./02-database-schema.md) — table definitions, indexes, constraints
- [03-implementation-status.md](./03-implementation-status.md) — what's built, what's pending, how to test
- [04-current-server-behavior-baseline.md](./04-current-server-behavior-baseline.md) — server-validated runtime behavior and prioritized gaps
- [../scraping/hosted-chromium-cdp-setup.md](../scraping/hosted-chromium-cdp-setup.md) — EC2 Chrome CDP runbook
