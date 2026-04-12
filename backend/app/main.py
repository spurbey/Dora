"""
FastAPI application entry point.

Configures:
    - Sentry error tracking
    - CORS middleware
    - API routers
    - Health check endpoints (liveness + readiness)
"""

import logging

import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.sqlalchemy import SqlalchemyIntegration

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import text
from app.config import settings
from app.database import SessionLocal
from app.services.storage_service import validate_supabase_runtime_configuration

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
from app.api.v1 import (
    auth,
    users,
    trips,
    places,
    media,
    search,
    metadata,
    routes,
    components,
    exports,
    live_tracking,
    compiled_projection,
)
from app.api.v2 import live_tracking as live_tracking_v2

logger = logging.getLogger(__name__)

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
app.include_router(live_tracking.router, prefix="/api/v1")
app.include_router(compiled_projection.router, prefix="/api/v1")
app.include_router(live_tracking_v2.router, prefix="/api/v2")


@app.on_event("startup")
def _validate_supabase_runtime_config() -> None:
    diagnostics = validate_supabase_runtime_configuration(
        environment=settings.ENVIRONMENT,
        supabase_url=settings.SUPABASE_URL,
        service_role_key=settings.SUPABASE_SERVICE_ROLE_KEY,
        strict=False,
    )

    if diagnostics["url_sanitized"] or diagnostics["key_sanitized"]:
        logger.warning(
            "Supabase runtime configuration required sanitization (host=%s, key_format=%s)",
            diagnostics["supabase_host"],
            diagnostics["key_format"],
        )

    if diagnostics["key_format"] != "jwt":
        logger.error(
            "Supabase service key format is incompatible with current backend client (host=%s, key_format=%s)",
            diagnostics["supabase_host"],
            diagnostics["key_format"],
        )

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
