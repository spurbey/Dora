# Database Schema Reference

## Core Tables

### users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    bio TEXT,
    is_premium BOOLEAN DEFAULT FALSE,
    subscription_ends_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### trips
```sql
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    cover_photo_url TEXT,
    visibility VARCHAR(20) DEFAULT 'private' CHECK (visibility IN ('private', 'unlisted', 'public')),
    views_count INT DEFAULT 0,
    saves_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_trips_user_id ON trips(user_id);
CREATE INDEX idx_trips_visibility ON trips(visibility);
```

### trip_places
```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE trip_places (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    place_type VARCHAR(50),
    location GEOGRAPHY(Point, 4326) NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    user_notes TEXT,
    user_rating INT CHECK (user_rating BETWEEN 1 AND 5),
    visit_date DATE,
    photos JSONB DEFAULT '[]'::jsonb,
    external_data JSONB,
    order_in_trip INT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_trip_places_trip_id ON trip_places(trip_id);
CREATE INDEX idx_trip_places_location ON trip_places USING GIST(location);
```

### trip_routes
```sql
CREATE TABLE trip_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    path GEOGRAPHY(LineString, 4326) NOT NULL,
    distance_km DOUBLE PRECISION,
    duration_minutes INT,
    transportation_mode VARCHAR(20) CHECK (transportation_mode IN ('walk', 'drive', 'bike', 'train', 'flight')),
    from_place_id UUID REFERENCES trip_places(id),
    to_place_id UUID REFERENCES trip_places(id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_trip_routes_trip_id ON trip_routes(trip_id);
```

### media_files
```sql
CREATE TABLE media_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trip_place_id UUID REFERENCES trip_places(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_type VARCHAR(20) NOT NULL CHECK (file_type IN ('photo', 'video')),
    file_size_bytes BIGINT,
    mime_type VARCHAR(100),
    width INT,
    height INT,
    thumbnail_url TEXT,
    caption TEXT,
    taken_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_media_user_id ON media_files(user_id);
CREATE INDEX idx_media_trip_place_id ON media_files(trip_place_id);
```

### subscriptions
```sql
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stripe_customer_id VARCHAR(255),
    stripe_subscription_id VARCHAR(255),
    plan_type VARCHAR(20) DEFAULT 'free' CHECK (plan_type IN ('free', 'premium')),
    status VARCHAR(20) CHECK (status IN ('active', 'cancelled', 'past_due')),
    current_period_start TIMESTAMP,
    current_period_end TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
```

## PostGIS Functions

### Calculate trip bounds
```sql
CREATE OR REPLACE FUNCTION calculate_trip_bounds(trip_uuid UUID)
RETURNS TABLE(min_lat DOUBLE PRECISION, min_lng DOUBLE PRECISION, 
              max_lat DOUBLE PRECISION, max_lng DOUBLE PRECISION) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        MIN(lat), MIN(lng), MAX(lat), MAX(lng)
    FROM trip_places
    WHERE trip_id = trip_uuid;
END;
$$ LANGUAGE plpgsql;
```

### Find nearby places
```sql
CREATE OR REPLACE FUNCTION nearby_places(
    user_lat DOUBLE PRECISION,
    user_lng DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 5.0
)
RETURNS TABLE(place_id UUID, place_name VARCHAR, distance_km DOUBLE PRECISION) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tp.id,
        tp.name,
        ST_Distance(
            tp.location,
            ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
        ) / 1000 AS distance_km
    FROM trip_places tp
    WHERE ST_DWithin(
        tp.location,
        ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
        radius_km * 1000
    )
    ORDER BY distance_km;
END;
$$ LANGUAGE plpgsql;
```

## Indexes Summary

Spatial indexes (GIST):
- trip_places.location
- trip_routes.path

Foreign key indexes:
- trips.user_id
- trip_places.trip_id
- trip_places.user_id
- media_files.user_id
- media_files.trip_place_id

Visibility/status indexes:
- trips.visibility
- subscriptions.user_id