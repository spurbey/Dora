# Supabase Integration Guide

## Setup

### Create Project
1. Go to https://supabase.com
2. Create new project
3. Wait for database to provision (~2 minutes)

### Get Credentials
From Project Settings → API:
- Project URL: `https://xxxxx.supabase.co`
- Anon key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
- Service role key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (secret)

### Enable PostGIS
SQL Editor → New Query:
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

## Auth Integration

### FastAPI Configuration
```python
# config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_JWT_SECRET: str
    
    class Config:
        env_file = ".env"
```

### JWT Validation
```python
# dependencies.py
from jose import jwt, JWTError
from fastapi import Depends, HTTPException, Header

async def get_current_user(
    authorization: str = Header(...),
    db: Session = Depends(get_db)
):
    try:
        token = authorization.replace("Bearer ", "")
        payload = jwt.decode(
            token,
            settings.SUPABASE_JWT_SECRET,
            algorithms=["HS256"]
        )
        user_id = payload.get("sub")
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(401, "User not found")
        return user
    except JWTError:
        raise HTTPException(401, "Invalid token")
```

## Database Connection

### SQLAlchemy Setup
```python
# database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

SQLALCHEMY_DATABASE_URL = settings.SUPABASE_DB_URL
# Format: postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

## Storage Integration

### Python Client
```python
from supabase import create_client

supabase = create_client(
    settings.SUPABASE_URL,
    settings.SUPABASE_ANON_KEY
)

# Upload file
supabase.storage.from_("photos").upload(
    path="user_123/photo.jpg",
    file=file_bytes,
    file_options={"content-type": "image/jpeg"}
)

# Get public URL
url = supabase.storage.from_("photos").get_public_url("user_123/photo.jpg")
```

### Create Storage Bucket
Dashboard → Storage → New Bucket:
- Name: `photos`
- Public: Yes (or use RLS for private)

### RLS Policy (Optional)
```sql
CREATE POLICY "Users can upload to own folder"
ON storage.objects
FOR INSERT
WITH CHECK (
    bucket_id = 'photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
);
```

## Frontend Client

### React Integration
```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
);

// Sign up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123'
});

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123'
});

// Get session
const { data: { session } } = await supabase.auth.getSession();
```

## Environment Variables

### Backend (.env)
```bash
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_JWT_SECRET=your-jwt-secret
SUPABASE_DB_URL=postgresql://postgres:[password]@db.[ref].supabase.co:5432/postgres
```

### Frontend (.env)
```bash
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Best Practices
- Use anon key in frontend (safe to expose)
- Use service role key only in backend (never expose)
- Validate JWT in FastAPI (don't trust client)
- Use RLS as backup security layer
- Enable Row Level Security on all tables