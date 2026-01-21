# Current Phase: Phase 0 - Foundation Setup

**Phase Number:** 0
**Phase Goal:** Set up development environment and core infrastructure
**Estimated Duration:** Week 1 (2 sessions, ~3-5 hours total)
**Status:** Not Started

---

## Phase Overview

This phase establishes the foundation:
1. Supabase project configuration
2. FastAPI project structure
3. Database connection
4. Core database schema with PostGIS

**No coding of business logic yet** - this is pure infrastructure.

---

## Deliverables

By end of this phase, we should have:
- ✅ Supabase project created and configured
- ✅ PostgreSQL with PostGIS extension enabled
- ✅ FastAPI project structure scaffolded
- ✅ Database connection working (tested)
- ✅ Core tables created: users, trips, trip_places
- ✅ Spatial indexes working (PostGIS GIST)
- ✅ Alembic migrations functional

---

## Sessions in This Phase

### Session 1: Supabase + FastAPI Scaffold
**Duration:** 60-90 minutes
**Focus:** Get infrastructure running

**Tasks:**
1. Create Supabase project (via web UI)
2. Enable PostGIS extension
```sql
   CREATE EXTENSION IF NOT EXISTS postgis;
```
3. Create FastAPI project structure:
```
   backend/
   ├── app/
   │   ├── __init__.py
   │   ├── main.py
   │   ├── config.py
   │   ├── database.py
   │   └── api/
   ├── tests/
   ├── requirements.txt
   └── .env.example
```
4. Install dependencies:
```
   fastapi
   uvicorn[standard]
   sqlalchemy
   geoalchemy2
   psycopg2-binary
   alembic
   python-dotenv
   pydantic-settings
```
5. Create database connection in `database.py`
6. Test connection with simple query

**Success Criteria:**
- FastAPI server runs on localhost:8000
- Can query Supabase database successfully
- `/health` endpoint returns 200 OK

**Reference Docs:**
- `docs/supabase/setup-guide.md`
- `docs/architecture.md`

---

### Session 2: Database Schema
**Duration:** 90-120 minutes
**Focus:** Create core tables with PostGIS

**Tasks:**
1. Create SQLAlchemy models:
   - User model (basic fields only)
   - Trip model (with dates, visibility)
   - TripPlace model (with PostGIS Geography column)
2. Set up Alembic:
```bash
   alembic init alembic
   alembic revision --autogenerate -m "create core tables"
   alembic upgrade head
```
3. Create spatial indexes:
```sql
   CREATE INDEX idx_trip_places_location 
   ON trip_places USING GIST(location);
```
4. Write test to verify PostGIS:
```python
   # Test ST_Distance works
   SELECT ST_Distance(
     location, 
     ST_SetSRID(ST_MakePoint(77.2090, 28.6139), 4326)::geography
   ) / 1000 as distance_km
   FROM trip_places;
```

**Success Criteria:**
- All tables exist in Supabase
- PostGIS Geography columns work
- Spatial index exists (check with `\d trip_places` in SQL)
- Can insert and query places with lat/lng

**Reference Docs:**
- `docs/schemas/database.md`
- `docs/phases/phase-0-setup.md`

---

## Key Decisions Made

1. **Database:** Supabase PostgreSQL (not self-hosted)
   - Reason: Managed service, includes PostGIS, easier for solo dev
   
2. **ORM:** SQLAlchemy 2.0 + GeoAlchemy2
   - Reason: Best PostGIS support, mature ecosystem
   
3. **Migrations:** Alembic
   - Reason: Standard with SQLAlchemy, good for PostGIS

4. **Environment Variables:** python-dotenv
   - Reason: Simple, works with Pydantic Settings

---

## Phase Completion Criteria

Phase 0 is complete when:
- [ ] FastAPI server runs without errors
- [ ] Database connection works
- [ ] All core tables exist in Supabase
- [ ] PostGIS extension is enabled
- [ ] Can insert a test trip and place
- [ ] Spatial query returns correct distance
- [ ] Alembic migrations run successfully
- [ ] `.env` file configured (not committed)
- [ ] `README.md` has setup instructions

**Phase 0 Success = Ready to build auth in Phase 1A**

---

## Blockers / Risks

**Potential Issues:**
1. PostGIS version compatibility with GeoAlchemy2
   - Mitigation: Use Supabase's default PostGIS version
2. Connection string format for Supabase
   - Mitigation: Follow Supabase docs exactly
3. Alembic autogenerate missing PostGIS columns
   - Mitigation: Manually verify migration before applying

**Current Blockers:** None

---

## Notes

- Keep `.env` file out of git (add to .gitignore)
- Supabase free tier has limits (500MB database, 1GB file storage)
- Use `psycopg2-binary` for dev, `psycopg2` for production
- Test PostGIS functions work before moving to Phase 1

---

## Next Phase Preview

**Phase 1A: Authentication (Week 2)**
- Integrate Supabase Auth with FastAPI
- JWT token validation
- User profile endpoints
- Protected route middleware