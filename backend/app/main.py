"""
FastAPI application entry point.

Configures:
    - Sentry error tracking
    - CORS middleware
    - API routers
    - Health check endpoints (liveness + readiness)
"""

import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.sqlalchemy import SqlalchemyIntegration

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import text
from app.config import settings
from app.database import SessionLocal

# --- Sentry ---
if settings.SENTRY_DSN:
    sentry_sdk.init(
        dsn=settings.SENTRY_DSN,
        integrations=[
            FastApiIntegration(transaction_style="endpoint"),
            SqlalchemyIntegration(),
        ],
        traces_sample_rate=0.1,
        environment=settings.ENVIRONMENT,
        send_default_pii=False,
    )

# Import routers
from app.api.v1 import auth, users, trips, places, media, search, metadata, routes, components, exports

app = FastAPI(
    title=settings.APP_NAME,
    debug=settings.DEBUG,
    version="1.0.0",
    description="Travel Memory Vault - Personal travel journal with AI-powered search"
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS.split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1")
app.include_router(trips.router, prefix="/api/v1")
app.include_router(places.router, prefix="/api/v1")
app.include_router(media.router, prefix="/api/v1")
app.include_router(search.router, prefix="/api/v1")
app.include_router(metadata.router, prefix="/api/v1")
app.include_router(routes.router, prefix="/api/v1")
app.include_router(components.router, prefix="/api/v1")
app.include_router(exports.router, prefix="/api/v1")

@app.get("/")
def root():
    """API root endpoint."""
    return {
        "message": "Travel Memory Vault API",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
def health():
    """Liveness probe — lightweight, always 200 if process is running.
    Railway health check should point here to avoid restart loops during transient DB blips."""
    return {"status": "alive"}


@app.get("/ready")
def ready():
    """Readiness probe — checks DB connectivity. Use for monitoring/alerting, not for container restarts."""
    db = None
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        return {"status": "ready", "database": "connected"}
    except Exception:
        return JSONResponse(status_code=503, content={"status": "not_ready", "database": "disconnected"})
    finally:
        if db:
            db.close()
