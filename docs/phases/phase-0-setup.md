# Phase 0: Foundation Setup

Duration: 2 sessions, Week 1
Goal: Infrastructure ready for development

## Session 1: Supabase + FastAPI Scaffold

### Objective
Create Supabase project and FastAPI structure with working database connection.

### Tasks
1. Create Supabase project
   - Sign up at supabase.com
   - Create new project: "travel-memory-vault"
   - Choose region close to India
   - Generate strong database password (save it)
   
2. Enable PostGIS
   - SQL Editor → New Query
   - Run: `CREATE EXTENSION IF NOT EXISTS postgis;`
   - Verify: `SELECT PostGIS_version();`
   
3. Get credentials
   - Project URL
   - Anon key
   - Service role key
   - JWT secret
   - Database connection string
   
4. Initialize FastAPI project
```bash
   mkdir backend
   cd backend