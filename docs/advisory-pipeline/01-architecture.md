# Advisory Pipeline — Architecture

> Dora's travel advisory system proactively recommends POIs, warns about scams, and suggests activities to travelers during live trips. It scrapes Reddit + Google Maps, ranks results via rules + LLM, and delivers push notifications — all driven by a per-trip "brain" that tracks state, adapts to user feedback, and pauses on inactivity.

## System Overview

```
Flutter App
    │
    ├── POST /advisory/start        (pre-trip or manual reseed)
    ├── POST /advisory/query        (NL: "find me a quiet cafe")
    ├── POST /advisory/pause        (manual pipeline pause)
    ├── POST /advisory/resume       (explicit resume)
    ├── GET  /advisory/insights     (inbox: pending + delivered)
    ├── GET  /advisory/state        (debug: brain state, gated)
    └── POST /advisory/{id}/action  (liked / dismissed / saved / acted_on)
          │
          ▼
    FastAPI Backend
          │
          ├── Advisory Service (creates jobs, records actions)
          ├── Trip Brain Service (per-trip state machine)
          └── advisory_jobs table (status=queued)
                │
                ▼
    ┌─── Advisory Cycle Worker (polls trip_advisory_state every 30s) ──┐
    │                                                                   │
    │  For each active trip whose next_eligible_at <= now():            │
    │    pick_next_target(trip_id)                                      │
    │      route mode: sample polyline, project GPS, geocode next city │
    │      radius mode: centroid of live GPS, reverse geocode          │
    │    → create location_trigger AdvisoryJob                         │
    └──────────────────────────────────────────────────────────────────┘
                │
                ▼
    Advisory Worker (polls advisory_jobs)
          │
          ├── 1. route_segmentation   → derive keywords from target locality + metadata
          ├── 2. reddit_scrape        → Crawl4AI deep crawl + OpenRouter LLM extraction
          ├── 3. tripadvisor_scrape   → (deferred, stub)
          ├── 4. gmaps_scrape         → BrightData CDP: POI search + 3-4 reviews each
          ├── 5. llm_extraction       → merge + dedupe Reddit insights
          ├── 6. scoring              → hard filter + soft score + LLM final 3 picks
          └── 7. delivery             → TripAdvisory rows + Firebase push + brain update
                │
                ▼
    trip_advisories table → Flutter inbox
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
1. User creates trip → `trip_advisory_state` row auto-created (lifecycle=seeded)
2. Trip classified by rule table (long_road / short_road / intra_city / day_trip / multi_day_leisure)
3. If route exists: polyline sampled into 22 equal-distance points, each reverse-geocoded (Mapbox)
4. Metadata snapshot frozen (trip_metadata + user_metadata)

### Tracking Start (enrich + activate)
1. User starts live tracking → brain enriched (weather for first samples)
2. lifecycle_state → active, next_eligible_at set
3. Cycle worker begins firing every `cadence_seconds` (determined by trip class)

### Per-Cycle Advisory (location_trigger)
1. Cycle worker picks next uncovered locality (route mode) or geocodes live centroid (radius mode)
2. Creates location_trigger AdvisoryJob with target context
3. Worker runs: Reddit scrape for target locality → GMaps POI search → rule-filter (weather/dedupe/warnings) → soft-score (dietary/time/activity) → LLM picks top 3 with copy
4. TripAdvisory rows persisted with poi_place_id + weather_snapshot
5. Firebase push for confidence ≥ 0.7 (Redis per-user throttle: max 3/hr)
6. Brain updated: locality + POIs recorded, categories balanced, next_eligible_at advanced

### User Feedback Loop
- **Accept** (liked/saved/acted_on/converted_to_place): ignore_streak reset → 0; if paused due to inactivity, implicit resume
- **Reject** (dismissed): ignore_streak reset → 0; no re-suggestion of that POI
- **Ignore** (no action for 1hr): sweep marks expired, brain.ignore_streak++
- **3 consecutive ignores**: pipeline paused, "paused due to inactivity" push sent
- **Manual pause**: `POST /advisory/pause` → paused_reason='user'; only explicit `POST /advisory/resume` clears

### Route/Metadata Change (reseed)
1. Route update detected via `routes.geom_sig` change → reseed(route_changed)
2. Trip metadata update → reseed(metadata_changed)
3. Debounced: if last_seed_at < 120s ago, reasons queued in pending_reseed_reasons[]
4. Cycle worker flushes pending reseeds after window; single coalesced run
5. Preserves advised_locality_keys + advised_poi_place_ids + ignore_streak

### Pre-Trip / On-Demand (manual)
- `POST /advisory/start` with `job_type=pre_trip` → force reseed or one-shot insights
- `POST /advisory/query` with NL text → on_demand job, worker parses intent

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
| Claim-then-process cycle worker with make_interval lease | Short row-lock on claim (ms); crashed worker's claim auto-expires |
| mark_cycle_outcome with 5 outcomes (delivered/no_pick/failed/no_target/off_route) | Eliminates stall where next_eligible_at never advances |
| no_pick retry budget (2) before locality marked covered | Transient failures (API blip, thin scrape results) don't permanently kill a locality |
| Off-route skip (5km nearest-leg threshold via route_geom geography) | Prevents advising on wrong corridor when user deviates |
| Atomic BrightData counter with cap check in single UPDATE | No double-spend under concurrent cycle ticks or retries |
| Push throttle per-user (not per-trip) via Redis INCR | Stricter across multi-trip scenarios; avoids notification spam |
| Ignore detection via TTL sweep + NOT EXISTS guarded UPDATE | Race-safe with late user actions; defense-in-depth in apply_feedback |
| Reseed debounce (120s) with pending_reseed_reasons TEXT[] | Prevents thrashing on rapid route edits; single coalesced run |

## External Dependencies

| Service | Purpose | Required? |
|---------|---------|-----------|
| OpenRouter (LLM) | Reddit extraction + POI ranking | Yes — stages skip if missing |
| BrightData (Scraping Browser) | Google Maps POI search + reviews via CDP | No — gmaps_scrape skips gracefully; Reddit-only advisories still fire |
| Mapbox (Geocoding) | Reverse geocode route samples + radius centroid | Yes — advisory trigger disabled without it |
| Open-Meteo (Weather) | 3h forecast for POI weather-matching | No — rule-filter falls through without it |
| Upstash Redis | Brain cache, centroid buffer, push throttle, geocode/weather cache | No — pipeline works without it, just slower |
| Crawl4AI | Reddit deep crawling | Yes — core scraping engine |
| Playwright + Chromium | Browser for Crawl4AI + BrightData CDP | Yes |
| Firebase Admin SDK | Push notifications | No — delivery still writes DB rows without it |

## Deployment

```
Railway Worker Service:
  ├── python -m app.workers.export_worker                 (video exports)
  ├── python -m app.workers.live_tracking_worker          (location inference)
  ├── python -m app.workers.advisory_worker               (advisory pipeline)
  ├── python -m app.workers.advisory_cycle_worker         (periodic brain cycle)
  └── python -m app.workers.advisory_ignore_sweep_worker  (ignore detection)
```

All workers share the same Docker image and codebase. They poll PostgreSQL independently using `FOR UPDATE SKIP LOCKED`.

## Related Docs

- [02-database-schema.md](./02-database-schema.md) — table definitions, indexes, constraints
- [03-implementation-status.md](./03-implementation-status.md) — what's built, what's pending, how to test
