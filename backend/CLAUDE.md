# Backend Development Rules

## Structure
```
app/
├── main.py          # FastAPI app, CORS, routers
├── config.py        # Settings from environment
├── database.py      # SQLAlchemy connection
├── dependencies.py  # get_db, get_current_user
├── models/          # SQLAlchemy models
├── schemas/         # Pydantic schemas
├── api/v1/          # API routes
└── services/        # Business logic
```

## Patterns

### Database Connection
```python
# database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = settings.SUPABASE_DB_URL
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### Auth Dependency
```python
# dependencies.py
from jose import jwt

async def get_current_user(
    authorization: str = Header(...),
    db: Session = Depends(get_db)
):
    token = authorization.replace("Bearer ", "")
    payload = jwt.decode(token, SUPABASE_JWT_SECRET, algorithms=["HS256"])
    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(401)
    return user
```

### PostGIS Queries
```python
# Use Geography type, always
from geoalchemy2 import Geography
from sqlalchemy import func

# Distance query
db.query(TripPlace).filter(
    func.ST_DWithin(
        TripPlace.location,
        func.ST_SetSRID(func.ST_MakePoint(lng, lat), 4326).cast(Geography),
        radius_meters
    )
)
```

## Commands
```bash
# Run server
cd backend && uvicorn app.main:app --reload

# Run tests
cd backend && pytest

# New migration
cd backend && alembic revision --autogenerate -m "description"

# Apply migration
cd backend && alembic upgrade head

# Check types
cd backend && mypy app/
```

## Requirements
- Always use Depends(get_current_user) for protected routes
- Always check resource ownership before update/delete
- Always use parameterized queries (SQLAlchemy ORM)
- PostGIS queries use Geography not Geometry
- Free tier users: max 3 trips (enforce in service layer)

