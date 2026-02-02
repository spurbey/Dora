"""
FastAPI application entry point.

Configures:
    - CORS middleware
    - API routers
    - Global exception handlers
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings

# Import routers
from app.api.v1 import auth, users, trips, places, media, search, metadata, routes, components

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
    """Health check endpoint."""
    return {"status": "healthy"}