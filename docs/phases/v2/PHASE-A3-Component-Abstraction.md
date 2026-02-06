# **PHASE A3: Component Abstraction - Complete PRD (UPDATED)**

---

## **📋 Phase Overview**

**Phase ID:** A3   
**Dependencies:** Phase A1, A2 (completed)  
**Goal:** Create unified timeline view combining places + routes

---

## **🎯 Objectives**

Enable frontend to query **all trip components** (places + routes) in **chronological order** as a single unified timeline.

**Deliverables:**
- 1 database view (`trip_components_view`)
- 3 API endpoints for timeline operations
- Normalized reordering logic
- Tests

---

## **🗄️ Database Schema**

### **Database View: trip_components_view**

**Purpose:** Virtual table combining places + routes for timeline display.

**SQL Definition:**
```sql
CREATE OR REPLACE VIEW trip_components_view AS
SELECT 
    id,
    trip_id,
    user_id,
    'place' as component_type,
    name,
    order_in_trip,
    created_at,
    updated_at,
    'trip_places' as source_table,
    id as source_id
FROM trip_places
UNION ALL
SELECT 
    id,
    trip_id,
    user_id,
    'route' as component_type,
    COALESCE(name, 'Route') as name,
    order_in_trip,
    created_at,
    updated_at,
    'routes' as source_table,
    id as source_id
FROM routes;
```

**⚠️ IMPORTANT:** No `ORDER BY` in view definition. PostgreSQL does not guarantee order in views. Always order in SELECT queries.

**Columns:**
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Component ID |
| `trip_id` | UUID | Parent trip |
| `user_id` | UUID | Owner |
| `component_type` | TEXT | 'place' or 'route' |
| `name` | TEXT | Display name |
| `order_in_trip` | INTEGER | Sort order |
| `created_at` | TIMESTAMP | Creation time |
| `updated_at` | TIMESTAMP | Last modified |
| `source_table` | TEXT | 'trip_places' or 'routes' |
| `source_id` | UUID | Original record ID |

**Why a VIEW?**
- No data duplication
- Always up-to-date (reflects places + routes in real-time)
- Simplifies queries
- No additional storage

---

## **📁 File Structure**

```
backend/
├── app/
│   ├── models/
│   │   └── trip_component.py     (NEW - Read-only model)
│   ├── schemas/
│   │   └── trip_component.py     (NEW)
│   ├── api/v1/
│   │   └── components.py         (NEW)
│   └── services/
│       └── component_service.py  (NEW - Reordering logic)
├── migrations/versions/
│   └── xxx_add_components_view.py (NEW)
└── tests/
    └── test_components.py        (NEW)
```

---

## **🔧 API Endpoints**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/trips/{trip_id}/components` | Get unified timeline (ordered) |
| PATCH | `/api/v1/trips/{trip_id}/components/reorder` | Bulk reorder with normalization |
| GET | `/api/v1/trips/{trip_id}/components/{component_id}` | Get full details (auto-detect type) |

---

## **📄 Pydantic Schemas**

**app/schemas/trip_component.py:**

```python
from pydantic import BaseModel
from uuid import UUID
from datetime import datetime
from typing import Literal

class TripComponentBase(BaseModel):
    id: UUID
    trip_id: UUID
    component_type: Literal['place', 'route']
    name: str
    order_in_trip: int
    created_at: datetime

class TripComponentResponse(TripComponentBase):
    """Lightweight timeline item"""
    model_config = ConfigDict(from_attributes=True)

class TripComponentListResponse(BaseModel):
    components: list[TripComponentResponse]
    total: int
    trip_id: UUID

class TripComponentDetailResponse(BaseModel):
    """Full details including original entity"""
    id: UUID
    component_type: Literal['place', 'route']
    order_in_trip: int
    
    # Polymorphic data (one will be None)
    place_data: PlaceResponse | None = None
    route_data: RouteResponse | None = None
    
class ComponentReorderRequest(BaseModel):
    """Bulk reorder request"""
    items: list[ComponentReorderItem]
    
class ComponentReorderItem(BaseModel):
    id: UUID
    component_type: Literal['place', 'route']
    new_order: int
```

---

## **🛠️ Backend Implementation**

### **1. Read-Only Model**

**app/models/trip_component.py:**

```python
from sqlalchemy import Column, String, Integer, DateTime, Text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class TripComponent(Base):
    """
    Read-only model for trip_components_view
    No INSERT/UPDATE/DELETE operations allowed
    """
    __tablename__ = 'trip_components_view'
    
    id = Column(UUID, primary_key=True)
    trip_id = Column(UUID)
    user_id = Column(UUID)
    component_type = Column(String)
    name = Column(Text)
    order_in_trip = Column(Integer)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)
    source_table = Column(String)
    source_id = Column(UUID)
```

---

### **2. Service Layer**

**app/services/component_service.py:**

```python
from sqlalchemy.orm import Session
from app.models.trip_place import TripPlace
from app.models.route import Route
from app.models.trip_component import TripComponent
from uuid import UUID

class ComponentService:
    def __init__(self, db: Session):
        self.db = db
    
    async def reorder_components(
        self, 
        trip_id: UUID, 
        items: list[dict]
    ) -> int:
        """
        Bulk reorder places and routes with normalization.
        Ensures clean sequential ordering: 0, 1, 2, 3...
        
        Args:
            trip_id: Trip ID
            items: [
                {'id': UUID, 'component_type': 'place', 'new_order': 2},
                {'id': UUID, 'component_type': 'route', 'new_order': 0},
                ...
            ]
        
        Returns:
            Number of components updated
        """
        # Sort by new_order first
        sorted_items = sorted(items, key=lambda x: x['new_order'])
        
        updated_count = 0
        
        # Normalize to sequential integers (0, 1, 2, 3...)
        for idx, item in enumerate(sorted_items):
            if item['component_type'] == 'place':
                place = self.db.query(TripPlace).filter(
                    TripPlace.id == item['id'],
                    TripPlace.trip_id == trip_id
                ).first()
                if place:
                    place.order_in_trip = idx
                    updated_count += 1
            
            elif item['component_type'] == 'route':
                route = self.db.query(Route).filter(
                    Route.id == item['id'],
                    Route.trip_id == trip_id
                ).first()
                if route:
                    route.order_in_trip = idx
                    updated_count += 1
        
        self.db.commit()
        return updated_count
    
    async def get_component_details(
        self, 
        trip_id: UUID,
        component_id: UUID
    ) -> dict:
        """
        Fetch full details of a component.
        Auto-detects type from view, no type parameter needed.
        
        Returns:
            {
                'id': UUID,
                'component_type': 'place',
                'order_in_trip': int,
                'place_data': {...full place object...},
                'route_data': None
            }
        """
        # Get component from view to determine type
        component = self.db.query(TripComponent).filter(
            TripComponent.id == component_id,
            TripComponent.trip_id == trip_id
        ).first()
        
        if not component:
            return None
        
        if component.component_type == 'place':
            place = self.db.query(TripPlace).filter(
                TripPlace.id == component.source_id
            ).first()
            return {
                'id': component_id,
                'component_type': 'place',
                'order_in_trip': component.order_in_trip,
                'place_data': place,
                'route_data': None
            }
        
        elif component.component_type == 'route':
            route = self.db.query(Route).filter(
                Route.id == component.source_id
            ).first()
            return {
                'id': component_id,
                'component_type': 'route',
                'order_in_trip': component.order_in_trip,
                'place_data': None,
                'route_data': route
            }
```

---

### **3. API Endpoints**

**app/api/v1/components.py:**

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.trip import Trip
from app.models.trip_component import TripComponent
from app.schemas.trip_component import (
    TripComponentListResponse,
    TripComponentDetailResponse,
    ComponentReorderRequest
)
from app.services.component_service import ComponentService

router = APIRouter(prefix="/api/v1", tags=["components"])

@router.get(
    "/trips/{trip_id}/components",
    response_model=TripComponentListResponse
)
async def get_components(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get unified timeline of places + routes for a trip.
    Returns items sorted by order_in_trip.
    """
    # Verify trip exists and check access
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )
    
    # Check access (owner or public/unlisted trip)
    if trip.user_id != current_user.id and trip.visibility == 'private':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied"
        )
    
    # Query view with explicit ORDER BY
    components = db.query(TripComponent)\
        .filter(TripComponent.trip_id == trip_id)\
        .order_by(TripComponent.order_in_trip)\
        .all()
    
    return {
        'components': components,
        'total': len(components),
        'trip_id': trip_id
    }


@router.patch("/trips/{trip_id}/components/reorder")
async def reorder_components(
    trip_id: UUID,
    request: ComponentReorderRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Bulk reorder components with automatic normalization.
    Ensures clean sequential ordering: 0, 1, 2, 3...
    """
    # Verify ownership
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(status_code=404, detail="Trip not found")
    
    if trip.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    # Validate all items belong to this trip
    for item in request.items:
        component = db.query(TripComponent).filter(
            TripComponent.id == item.id,
            TripComponent.trip_id == trip_id
        ).first()
        if not component:
            raise HTTPException(
                status_code=422,
                detail=f"Component {item.id} not found in trip {trip_id}"
            )
    
    # Reorder with normalization
    service = ComponentService(db)
    updated_count = await service.reorder_components(
        trip_id, 
        [item.dict() for item in request.items]
    )
    
    return {
        'message': 'Components reordered successfully',
        'updated_count': updated_count
    }


@router.get(
    "/trips/{trip_id}/components/{component_id}",
    response_model=TripComponentDetailResponse
)
async def get_component_details(
    trip_id: UUID,
    component_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get full details of a component (place or route).
    Auto-detects type from view, no type parameter needed.
    """
    # Verify trip access
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(status_code=404, detail="Trip not found")
    
    if trip.user_id != current_user.id and trip.visibility == 'private':
        raise HTTPException(status_code=403, detail="Access denied")
    
    # Get details via service
    service = ComponentService(db)
    details = await service.get_component_details(trip_id, component_id)
    
    if not details:
        raise HTTPException(
            status_code=404,
            detail="Component not found"
        )
    
    return details
```

---

## **🔄 Database Migration**

**migrations/versions/xxx_add_components_view.py:**

```python
"""Add trip_components_view

Revision ID: xxx
Revises: yyy (Phase A2 migration)
Create Date: 2025-02-02
"""

from alembic import op

revision = 'xxx'
down_revision = 'yyy'  # Previous migration ID
branch_labels = None
depends_on = None

def upgrade():
    # Create view without ORDER BY
    op.execute("""
        CREATE OR REPLACE VIEW trip_components_view AS
        SELECT 
            id,
            trip_id,
            user_id,
            'place'::text as component_type,
            name,
            order_in_trip,
            created_at,
            updated_at,
            'trip_places'::text as source_table,
            id as source_id
        FROM trip_places
        UNION ALL
        SELECT 
            id,
            trip_id,
            user_id,
            'route'::text as component_type,
            COALESCE(name, 'Route'::text) as name,
            order_in_trip,
            created_at,
            updated_at,
            'routes'::text as source_table,
            id as source_id
        FROM routes;
    """)

def downgrade():
    op.execute("DROP VIEW IF EXISTS trip_components_view;")
```

---

## **✅ Success Criteria**

### **Database:**
- [ ] View created (`trip_components_view`)
- [ ] View has NO ORDER BY clause
- [ ] View combines places + routes correctly
- [ ] Migration reversible

### **API:**
- [ ] GET components returns unified list (ordered by order_in_trip)
- [ ] PATCH reorder normalizes to 0,1,2,3... (no gaps)
- [ ] GET component details auto-detects type (no ?type param)
- [ ] Auth checks (owner-only for private trips)
- [ ] Validation (all IDs belong to trip)

### **Testing:**
- [ ] Create place + route → both appear in timeline
- [ ] Reorder [2,0,1] → normalized to [0,1,2]
- [ ] Delete place → removed from timeline
- [ ] Non-owner can't reorder
- [ ] Component details return correct polymorphic data

### **V1 Compatibility:**
- [ ] Existing endpoints unchanged

---

## **🧪 Test Cases**

**tests/test_components.py:**

```python
# Timeline retrieval
def test_get_components_returns_places_and_routes():
    """View combines both entity types"""

def test_components_ordered_by_order_in_trip():
    """Results sorted correctly via ORDER BY in query"""

def test_empty_timeline_returns_empty_list():
    """Handles trips with no components"""

# Reordering
def test_reorder_normalizes_to_sequential():
    """[5,2,8] becomes [0,1,2]"""

def test_reorder_multiple_types():
    """Can reorder places + routes together"""

def test_reorder_validates_trip_ownership():
    """All components must belong to trip"""

def test_reorder_auth_owner_only():
    """Non-owners cannot reorder"""

# Component details
def test_get_place_component_details_no_type_param():
    """Auto-detects type from view"""

def test_get_route_component_details_returns_route_data():
    """Returns full route object"""

def test_get_component_invalid_id_returns_404():
    """Handles missing components"""

# Edge cases
def test_delete_place_removes_from_timeline():
    """Cascade works via view"""

def test_delete_route_removes_from_timeline():
    """Cascade works via view"""

# Auth
def test_public_trip_timeline_visible():
    """Non-owners can view public trips"""

def test_private_trip_timeline_hidden():
    """Non-owners blocked from private trips"""
```

---

## **🚀 Deployment Steps**

1. **Apply migration:**
   ```bash
   alembic upgrade head
   ```

2. **Verify view:**
   ```bash
   psql -d your_database
   \d+ trip_components_view
   SELECT * FROM trip_components_view LIMIT 5;
   ```

3. **Test ordering:**
   ```sql
   SELECT component_type, name, order_in_trip 
   FROM trip_components_view 
   WHERE trip_id = 'test-trip-uuid'
   ORDER BY order_in_trip;
   ```

4. **Test endpoints:**
   - Visit http://localhost:8000/docs
   - Test GET /trips/{id}/components
   - Test PATCH /trips/{id}/components/reorder

5. **Run tests:**
   ```bash
   pytest tests/test_components.py -v
   ```

---

## **⚠️ Critical Implementation Notes**

### **1. ORDER BY Placement**
```python
# ❌ WRONG - Relies on view ordering (unreliable)
components = db.query(TripComponent).filter(...).all()

# ✅ CORRECT - Explicit ORDER BY in query
components = db.query(TripComponent)\
    .filter(...)\
    .order_by(TripComponent.order_in_trip)\
    .all()
```

### **2. Reorder Normalization**
```python
# ❌ WRONG - Allows duplicates/gaps [0,0,5,7]
for item in items:
    update(order_in_trip=item['new_order'])

# ✅ CORRECT - Normalize to [0,1,2,3]
sorted_items = sorted(items, key=lambda x: x['new_order'])
for idx, item in enumerate(sorted_items):
    update(order_in_trip=idx)
```

### **3. Type Detection**
```python
# ❌ WRONG - Requires frontend to pass type
@router.get("/components/{id}?type=place")

# ✅ CORRECT - Auto-detect from view
component = db.query(TripComponent).filter_by(id=id).first()
if component.component_type == 'place':
    ...
```

---

## **📦 Deliverables**

1. 1 database view (trip_components_view)
2. 1 model file (read-only TripComponent)
3. 1 schema file (4 schemas)
4. 1 API router (3 endpoints)
5. 1 service file (2 methods)
6. 1 migration file
7. 1 test file (20+ tests)

**LOC Estimate:** ~450 LOC

---

**END OF PHASE A3 PRD (UPDATED)**

---

**Changes from original:**
- ✅ Removed ORDER BY from view definition
- ✅ Added explicit ORDER BY in API queries
- ✅ Added normalization logic to reorder service
- ✅ Removed ?type parameter from details endpoint
- ✅ Updated all code examples
- ✅ Added critical implementation notes

**Ready for AI Agent: START A3**