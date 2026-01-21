# Travel Memory Vault - AI Development Instructions

## Project Overview
A personal travel journal app where creators pin places, attach memories, and build visual trip timelines. Private by default, shareable by choice.

**Tech Stack:**
- Backend: FastAPI + Python 3.11+
- Database: Supabase (PostgreSQL + PostGIS)
- Auth: Supabase Auth (JWT)
- Storage: Supabase Storage (photos/videos)
- Frontend: React 18 + Vite + TypeScript
- Maps: Mapbox GL JS
- External APIs: Foursquare (places), Mapbox (geocoding, search)

## Core Development Rules

### Always Do
1. **Start every session:** Run `/new-session` to load context
2. **Commit frequently:** After each logical unit (not just at session end)
3. **Use structured commits:** Follow format in `/commit` skill
4. **End every session:** Run `/close-session` to update status
5. **Load files dynamically:** Only read what you need for current task
6. **Use skills for patterns:** Don't reinvent, use `/api-endpoint`, `/supabase-table`, etc.
7. **Test before committing:** Run tests, ensure they pass

### Never Do
1. Don't load entire codebase at once (context bloat)
2. Don't skip tests before committing
3. Don't commit without structured message (COMPLETED/NEXT/FILES)
4. Don't hardcode secrets or API keys
5. Don't write code without reading relevant phase PRD first
6. Don't use `/compact` - use git log instead

## Session Workflow

### Start Session
```bash
/new-session
# This will:
# - Read .claude/PROJECT_STATUS.md
# - Read git log --oneline -20
# - Read .claude/CURRENT_PHASE.md
# - Show current task and context
```

### During Session
- Work on focused task from CURRENT_PHASE.md
- Load relevant docs/phases/*.md only when needed
- Use skills for common patterns
- **Commit after each logical unit** (not just at end)
- Run `/commit` with structured message

### End Session
```bash
/close-session
# This will:
# - Update .claude/PROJECT_STATUS.md
# - Update .claude/CURRENT_PHASE.md if phase complete
# - Create final session summary commit
```

## Memory Strategy

**Your memory between sessions:**
1. `git log --oneline -20` - Recent commit history
2. `git log -1 --format=full` - Last commit details
3. `.claude/PROJECT_STATUS.md` - Current state, blockers, progress
4. `.claude/CURRENT_PHASE.md` - Active phase details

**Don't rely on conversation history - it's gone next session.**

## Commit Message Format

**CRITICAL:** All commits must follow this structure:
```
<type>(<scope>): <short description>

COMPLETED:
- Specific task 1
- Specific task 2
- Specific task 3

NEXT SESSION:
- What to do next
- Clear starting point

FILES CHANGED:
- path/to/file1.py (new/modified, X lines)
- path/to/file2.py (modified, Y lines)

TESTS: X passed, Y% coverage
```

Types: `feat`, `fix`, `test`, `docs`, `chore`, `refactor`
Scopes: `auth`, `trips`, `places`, `media`, `search`, `frontend`, `db`

## Project Structure
```
├── .claude/              # AI instructions (you are here)
│   ├── CLAUDE.md         # Core rules (this file)
│   ├── PROJECT_STATUS.md # Current state
│   ├── CURRENT_PHASE.md  # Active phase
│   ├── skills/           # Reusable commands
│   ├── agents/           # Autonomous workflows
│   └── hooks/            # Automation triggers
│
├── docs/                 # Reference documentation
│   ├── phases/           # Mini-PRDs (one per phase)
│   ├── schemas/          # Database schema
│   ├── apis/             # External API guides
│   └── supabase/         # Supabase setup guides
│
├── backend/              # FastAPI backend
│   ├── CLAUDE.md         # Backend-specific rules
│   └── app/
│
└── frontend/             # React frontend
    ├── CLAUDE.md         # Frontend-specific rules
    └── src/
```

## Quick Reference

- **Architecture overview:** `docs/architecture.md`
- **Database schema:** `docs/schemas/database.md`
- **Current phase details:** `.claude/CURRENT_PHASE.md`
- **Task list:** `.claude/PROJECT_STATUS.md`
- **Supabase setup:** `docs/supabase/setup-guide.md`

## Available Skills (Commands)

- `/new-session` - Start session with context loading
- `/commit` - Create structured commit
- `/close-session` - End session, update status
- `/api-endpoint` - Create FastAPI endpoint
- `/supabase-table` - Create table with RLS policies
- `/react-page` - Create React page with Mapbox
- `/search-service` - Multi-source search pattern
- `/media-upload` - Supabase Storage upload

## Available Agents

- `backend-builder` - Build complete API resource (high autonomy)
- `frontend-builder` - Build complete page (high autonomy)
- `test-runner` - Run tests, fix failures (medium autonomy)
- `code-reviewer` - Review code before commit (low autonomy)

## Key Patterns

### Backend (FastAPI + Supabase)
- Models: SQLAlchemy with GeoAlchemy2 for PostGIS
- Schemas: Pydantic for validation
- Services: Business logic layer
- Routes: Thin controllers, delegate to services
- Auth: Validate Supabase JWT, use `Depends(get_current_user)`
- Database: Connect to Supabase PostgreSQL via SQLAlchemy

### Frontend (React + Mapbox)
- Components: Functional components with hooks
- State: Zustand for global, React Query for server state
- Maps: Mapbox GL JS for all map rendering
- Auth: Supabase client SDK
- API: Axios with interceptors for auth tokens

### Supabase Integration
- Auth: Email/password, JWT validation in FastAPI
- Database: PostgreSQL + PostGIS, connect via SQLAlchemy
- Storage: Upload to buckets, use signed URLs
- RLS: Row-Level Security for additional protection

## Important Notes

- **No Google Maps APIs** (ToS violation with Mapbox)
- **Use Foursquare + Mapbox** for place search
- **PostGIS for geospatial queries** (ST_Distance, ST_DWithin)
- **Free tier limit:** 3 trips per user (enforce in backend)
- **Premium tier:** Unlimited trips, offered at $8/month

## When in Doubt

1. Check `git log -5` to see recent work
2. Check `.claude/PROJECT_STATUS.md` for current task
3. Read relevant `docs/phases/*.md` for phase details
4. Ask human before making architectural decisions

---

**Version:** 1.0.0
**Last Updated:** 2025-01-15
**Project Start:** 2025-01-15