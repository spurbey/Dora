# Travel Memory Vault - AI Development Instructions

## Project Overview
A two-sided travel platform: Creators build rich, interactive travelogues on a map canvas. Planners discover semantically-matched travel content.

**Tech Stack:**
- Backend: FastAPI + Python 3.11+
- Database: Supabase (PostgreSQL + PostGIS)
- Auth: Supabase Auth (JWT)
- Storage: Supabase Storage (photos/videos)
- Frontend: React 18 + Vite + TypeScript
- Maps: Mapbox GL JS (NOT react-map-gl)
- External APIs: Foursquare (places), Mapbox (directions, geocoding)

## Core Development Rules

### Always Do
1. **Start every session:** Run `/new-session` to load context
3. **Use structured commits:** Follow format in `/commit` skill
4. **End every session:** Run `/close-session` to update status
5. **Load files dynamically:** Only read what you need for current task
6. **Test before committing:** Run tests, ensure they pass
7. **Read phase PRD first:** Load `docs/phases/v2/phase-{X}.md` before coding

### Never Do
1. Don't load entire codebase at once (context bloat)
2. Don't skip tests before committing
3. Don't commit without structured message (COMPLETED/NEXT/FILES)
4. Don't hardcode secrets or API keys
5. Don't modify V1 tables - only ADD new tables
6. Don't break backward compatibility with V1 features

## V2 Architecture Principles

### Data Strategy
- **Additive, not destructive:** V1 trips/places continue working
- **Metadata in separate tables:** trip_metadata, place_metadata, route_metadata
- **1:1 relationships:** Core entities unchanged, metadata optional
- **Semantic tagging:** All components tagged for intelligent search
- **PostgreSQL arrays + GIN indexes:** Fast multi-tag queries

### Frontend Strategy
- **Parallel interfaces:** V1 view (`/trips/:id`) + V2 editor (`/trips/:id/edit`)
- **Feature flags:** Enable V2 features gradually via env vars
- **Shared components:** Reuse V1 map/place components in V2 editor
- **State separation:** V1 uses existing stores, V2 has `editorStore`

## Session Workflow

### Start Session
```bash
/new-session
# Reads:
# - .claude/PROJECT_STATUS.md (current state)
# - git log --oneline -20 (recent work)
# - .claude/CURRENT_PHASE.md (active phase)
```

### During Session
- **Load phase PRD:** Read `docs/phases/v2/phase-{X}.md` before starting
- **Use reference patterns:** Check existing V1 code for patterns
- **Commit per logical unit:** Don't wait until session end
- **Test incrementally:** Run tests after each component

### End Session
```bash
/close-session
# Updates PROJECT_STATUS.md and CURRENT_PHASE.md
```

## Commit Message Format
```
<type>(<scope>): <short description>

COMPLETED:
- Specific task 1
- Specific task 2

NEXT SESSION:
- Clear starting point

FILES CHANGED:
- path/to/file.py (new/modified, X lines)

TESTS: X passed, Y% coverage
```

**Types:** `feat`, `fix`, `test`, `docs`, `refactor`, `migration`  
**Scopes:** `metadata`, `routes`, `editor`, `timeline`, `search`, `db`

## Project Structure
```
├── .claude/              # AI instructions
│   ├── CLAUDE.md         # This file
│   ├── PROJECT_STATUS.md # Current state
│   ├── CURRENT_PHASE.md  # Active phase
│   └── skills/           # Reusable commands
│
├── docs/
│   └── phases/           # V2 phase PRDs
│       ├── phase-a1-metadata-infrastructure.md
│       ├── phase-a2-route-system.md
│       ├── phase-b1-editor-layout.md
│       └── ...
│
├── backend/
│   ├── app/
│   │   ├── models/       # SQLAlchemy models
│   │   ├── schemas/      # Pydantic schemas
│   │   ├── api/v1/       # API endpoints
│   │   └── services/     # Business logic
│   └── migrations/       # Alembic migrations
│
└── frontend/
    ├── src/
    │   ├── pages/        # V1 pages + V2 editor
    │   ├── components/   # Shared + editor-specific
    │   ├── store/        # Zustand stores
    │   └── hooks/        # React Query hooks
    └── CLAUDE.md         # Frontend-specific rules
```

## V2 Phase Structure

**Current Phase System:**
```
PHASE A: Database Evolution (Backend)
  A1: Metadata Infrastructure    ← START HERE
  A2: Route System
  A3: Component Abstraction

PHASE B: Immersive Editor (Frontend)
  B1: Editor Layout
  B2: State Management
  B3: Map Canvas

PHASE C: Route Creation
  C1: Drawing Tools
  C2: Waypoint Management
  C3: Metadata UI

PHASE D: Timeline & Sync
  D1: Dynamic Timeline
  D2: Map-Timeline Sync
  D3: Drag & Drop

PHASE E: Semantic Tagging
  E1: Component Metadata Forms
  E2: Trip Profile Builder
  E3: Public/Private Controls

PHASE F: Discovery Engine (Future)
  F1: Search API
  F2: Ranking Algorithm
  F3: Recommendations
```

## Important V2 Rules

### Database
- ✅ **DO:** Create new tables with FK to existing tables
- ✅ **DO:** Use PostgreSQL ARRAY + GIN indexes for tags
- ✅ **DO:** Set ON DELETE CASCADE for metadata tables
- ❌ **DON'T:** Modify existing V1 tables (trips, trip_places)
- ❌ **DON'T:** Use JSONB for structured data (use proper columns)

### Frontend
- ✅ **DO:** Create `/trips/:id/edit` route for V2 editor
- ✅ **DO:** Keep V1 `/trips/:id` route unchanged
- ✅ **DO:** Use feature flags for gradual rollout
- ❌ **DON'T:** Break V1 components or pages
- ❌ **DON'T:** Use react-map-gl (use Mapbox GL JS directly)

### API
- ✅ **DO:** Add new endpoints under `/api/v1/`
- ✅ **DO:** Maintain backward compatibility
- ✅ **DO:** Use existing auth patterns (`get_current_user`)
- ❌ **DON'T:** Change existing V1 endpoint responses
- ❌ **DON'T:** Remove or rename V1 endpoints

## Quick Reference

- **Current phase:** `.claude/CURRENT_PHASE.md`
- **Phase PRDs:** `docs/phases/v2/phase-{X}.md`
- **Database schema:** `docs/schemas/database.md`
- **V1 reference code:** `backend/app/models/trip.py`, `frontend/src/pages/Dashboard.tsx`
- **Recent commits:** `git log --oneline -20`

## When in Doubt

1. **Check recent work:** `git log -5`
2. **Check current task:** `.claude/PROJECT_STATUS.md`
3. **Read phase PRD:** `docs/phases/phase-{current}.md`
4. **Reference V1 code:** Use existing patterns from V1
5. **Ask human:** Before architectural changes

---

**Version:** 2.0.0  
**Phase:** A1 (Metadata Infrastructure)  
**Last Updated:** 2025-02-02  
**V1 Shipped:** 2025-02-01  