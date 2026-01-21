# Row Level Security (RLS) Policies

## Overview
RLS is backup security. Primary auth checks happen in FastAPI.
Enable RLS on all tables for defense-in-depth.

## Enable RLS
```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE trip_places ENABLE ROW LEVEL SECURITY;
ALTER TABLE trip_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE media_files ENABLE ROW LEVEL SECURITY;
```

## Users Table Policies
```sql
-- Users can read their own record
CREATE POLICY "Users can read own record"
ON users FOR SELECT
USING (auth.uid()::uuid = id);

-- Users can update their own record
CREATE POLICY "Users can update own record"
ON users FOR UPDATE
USING (auth.uid()::uuid = id);
```

## Trips Table Policies
```sql
-- Users can read own trips
CREATE POLICY "Users can read own trips"
ON trips FOR SELECT
USING (user_id = auth.uid()::uuid);

-- Users can read public trips
CREATE POLICY "Anyone can read public trips"
ON trips FOR SELECT
USING (visibility = 'public');

-- Users can insert own trips
CREATE POLICY "Users can insert own trips"
ON trips FOR INSERT
WITH CHECK (user_id = auth.uid()::uuid);

-- Users can update own trips
CREATE POLICY "Users can update own trips"
ON trips FOR UPDATE
USING (user_id = auth.uid()::uuid);

-- Users can delete own trips
CREATE POLICY "Users can delete own trips"
ON trips FOR DELETE
USING (user_id = auth.uid()::uuid);
```

## Trip Places Policies
```sql
-- Users can read places from their trips
CREATE POLICY "Users can read own trip places"
ON trip_places FOR SELECT
USING (user_id = auth.uid()::uuid);

-- Users can read places from public trips
CREATE POLICY "Anyone can read public trip places"
ON trip_places FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM trips
        WHERE trips.id = trip_places.trip_id
        AND trips.visibility = 'public'
    )
);

-- Users can insert places to own trips
CREATE POLICY "Users can insert own places"
ON trip_places FOR INSERT
WITH CHECK (user_id = auth.uid()::uuid);

-- Users can update own places
CREATE POLICY "Users can update own places"
ON trip_places FOR UPDATE
USING (user_id = auth.uid()::uuid);

-- Users can delete own places
CREATE POLICY "Users can delete own places"
ON trip_places FOR DELETE
USING (user_id = auth.uid()::uuid);
```

## Media Files Policies
```sql
-- Users can read own media
CREATE POLICY "Users can read own media"
ON media_files FOR SELECT
USING (user_id = auth.uid()::uuid);

-- Users can insert own media
CREATE POLICY "Users can insert own media"
ON media_files FOR INSERT
WITH CHECK (user_id = auth.uid()::uuid);

-- Users can delete own media
CREATE POLICY "Users can delete own media"
ON media_files FOR DELETE
USING (user_id = auth.uid()::uuid);
```

## Storage Policies
```sql
-- Users can upload to their own folder
CREATE POLICY "Users can upload to own folder"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can read own files
CREATE POLICY "Users can read own files"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can delete own files
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
);
```

## Testing RLS

Run as authenticated user (will work):
```sql
SELECT * FROM trips WHERE user_id = auth.uid()::uuid;
```

Run as different user (will return empty):
```sql
SELECT * FROM trips WHERE user_id = 'other-user-id';
```

## Notes
- RLS runs on Supabase server, not in FastAPI
- Even if FastAPI has bug, RLS prevents unauthorized access
- Performance impact is minimal
- Always test policies after creating