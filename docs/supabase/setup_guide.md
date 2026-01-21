# Supabase Project Setup Guide

## Step 1: Create Project

1. Go to https://supabase.com
2. Sign up or log in
3. Click "New Project"
4. Fill in:
   - Name: `travel-memory-vault`
   - Database Password: (generate strong password, save it)
   - Region: Choose closest to target users (India: `ap-south-1`)
5. Click "Create new project"
6. Wait 2-3 minutes for provisioning

## Step 2: Enable PostGIS

1. Go to SQL Editor (left sidebar)
2. Click "New Query"
3. Run:
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```
4. Verify:
```sql
SELECT PostGIS_version();
```
Should return version number (e.g., `3.4.0`)

## Step 3: Get Credentials

1. Go to Project Settings → API
2. Copy these values:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **Project API keys**:
     - `anon` `public`: (safe to use in frontend)
     - `service_role`: (backend only, keep secret)
3. Go to Project Settings → Database
4. Copy **Connection string** (URI format):
```
   postgresql://postgres:[YOUR-PASSWORD]@db.xxxxx.supabase.co:5432/postgres
```
5. Go to Project Settings → API → JWT Settings
6. Copy **JWT Secret** (used to validate tokens in FastAPI)

## Step 4: Configure Environment Variables

Create `backend/.env`:
```bash
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_JWT_SECRET=your-jwt-secret-from-dashboard
SUPABASE_DB_URL=postgresql://postgres:[PASSWORD]@db.xxxxx.supabase.co:5432/postgres

FOURSQUARE_API_KEY=your-foursquare-key
MAPBOX_API_KEY=your-mapbox-token
```

Create `frontend/.env`:
```bash
VITE_API_URL=http://localhost:8000
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
VITE_MAPBOX_TOKEN=pk.eyJ1IjoieW91ciIsImEiOiJjbHF4eHh4In0...
```

## Step 5: Create Storage Bucket

1. Go to Storage (left sidebar)
2. Click "New Bucket"
3. Name: `photos`
4. Public bucket: Yes
5. Click "Create bucket"

## Step 6: Configure Auth

1. Go to Authentication → Providers
2. Enable Email provider (should be enabled by default)
3. Configure email templates (optional):
   - Confirmation email
   - Password reset email
4. Go to URL Configuration
5. Set Site URL: `http://localhost:3000` (dev) or your production domain

## Step 7: Test Connection

Run in SQL Editor:
```sql
SELECT 1;
```
Should return `1`

Test PostGIS:
```sql
SELECT ST_Distance(
    ST_SetSRID(ST_MakePoint(77.2090, 28.6139), 4326)::geography,
    ST_SetSRID(ST_MakePoint(77.2345, 28.6517), 4326)::geography
) / 1000 as distance_km;
```
Should return distance in km

## Step 8: Free Tier Limits

Be aware:
- Database: 500 MB
- Storage: 1 GB
- Bandwidth: 2 GB
- Edge functions: 500k executions/month
- Auth users: Unlimited

For MVP, this is sufficient. Upgrade to Pro ($25/month) when needed.

## Troubleshooting

### Can't connect to database
- Check password is correct
- Check connection string format
- Verify database is active (not paused)

### PostGIS not working
- Re-run `CREATE EXTENSION postgis;`
- Check extension exists: `SELECT * FROM pg_extension WHERE extname = 'postgis';`

### JWT validation failing
- Check JWT_SECRET matches dashboard value
- Verify token hasn't expired
- Check algorithm is HS256