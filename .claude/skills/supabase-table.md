---
name: supabase-table
description: Create table with RLS policies in Supabase
arguments:
  - name: table_name
    description: Name of table to create
---

# Supabase Table Creation Pattern

## 1. Create SQLAlchemy model

File: `backend/app/models/{table_name}.py`
```python
from sqlalchemy import Column, String, UUID, ForeignKey
from geoalchemy2 import Geography
from app.database import Base

class {TableName}(Base):
    __tablename__ = "{table_name}"
    
    id = Column(UUID, primary_key=True, server_default=func.gen_random_uuid())
    user_id = Column(UUID, ForeignKey("users.id"), nullable=False)
    # other columns
```

## 2. Create Alembic migration
```bash
cd backend
alembic revision --autogenerate -m "create {table_name} table"
```

Review migration file, then:
```bash
alembic upgrade head
```

## 3. Add RLS policy (optional, for extra security)

In Supabase SQL Editor:
```sql
ALTER TABLE {table_name} ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access own records"
ON {table_name}
FOR ALL
USING (auth.uid()::uuid = user_id);
```

## 4. Add spatial index (if Geography column exists)
```sql
CREATE INDEX idx_{table_name}_location 
ON {table_name} USING GIST(location);
```

## Notes
- RLS is backup security (FastAPI does primary auth checks)
- Always add indexes for foreign keys
- Use Geography type for lat/lng (not Geometry)