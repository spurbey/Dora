---
name: api-endpoint
description: Create FastAPI endpoint following project patterns
arguments:
  - name: resource
    description: Resource name (e.g., trips, places)
  - name: action
    description: create, read, update, delete, list
---

# API Endpoint Pattern

## Files to create/modify:

1. Schema: `backend/app/schemas/{resource}.py`
2. Service: `backend/app/services/{resource}_service.py`
3. Route: `backend/app/api/v1/{resource}.py`
4. Test: `backend/tests/test_{resource}.py`

## Pattern to follow:

### Schema (Pydantic)
```python
from pydantic import BaseModel
from uuid import UUID

class {Resource}Base(BaseModel):
    # fields

class {Resource}Create({Resource}Base):
    pass

class {Resource}Update(BaseModel):
    # optional fields

class {Resource}Response({Resource}Base):
    id: UUID
    user_id: UUID
    created_at: datetime
    
    class Config:
        from_attributes = True
```

### Service
```python
from sqlalchemy.orm import Session
from app.models.{resource} import {Resource}

class {Resource}Service:
    def __init__(self, db: Session):
        self.db = db
    
    def create(self, data, user_id):
        obj = {Resource}(**data.dict(), user_id=user_id)
        self.db.add(obj)
        self.db.commit()
        return obj
```

### Route
```python
from fastapi import APIRouter, Depends
from app.dependencies import get_current_user

router = APIRouter(prefix="/{resources}", tags=["{resources}"])

@router.post("", response_model={Resource}Response)
def create_{resource}(
    data: {Resource}Create,
    current_user = Depends(get_current_user),
    db = Depends(get_db)
):
    service = {Resource}Service(db)
    return service.create(data, current_user.id)
```

### Test
```python
def test_create_{resource}(client, auth_headers):
    response = client.post(
        "/api/v1/{resources}",
        json={...},
        headers=auth_headers
    )
    assert response.status_code == 201
```

## Notes
- Always check ownership before update/delete
- Use Depends(get_current_user) for protected routes
- Return 404 if resource not found
- Return 403 if user doesn't own resource