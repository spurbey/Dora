"""
Application configuration from environment variables.

All settings loaded from .env file.
Never commit .env file to git.
"""

import os
import sys

from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional


class Settings(BaseSettings):
    """
    Application settings.
    
    Attributes:
        APP_NAME: Application name
        DEBUG: Debug mode (disable in production)
        SUPABASE_URL: Supabase project URL
        SUPABASE_ANON_KEY: Supabase anonymous key (safe for frontend)
        SUPABASE_DB_URL: PostgreSQL connection string
        TEST_DATABASE_URL: Optional test database URL
        FOURSQUARE_API_KEY: Foursquare Places API key
        MAPBOX_API_KEY: Mapbox API key
        SECRET_KEY: Backend secret for internal use (NOT for JWT)
        ALLOWED_ORIGINS: CORS allowed origins (comma-separated)
        
    Note:
        - No SUPABASE_JWT_SECRET (uses JWKS verification)
        - No ALGORITHM config (hardcoded to ES256)
        - No ACCESS_TOKEN_EXPIRE_MINUTES (Supabase controls token expiry)
    """
    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        # Allow unrelated keys in .env (Flutter/AWS/tooling) without crashing backend boot.
        extra="ignore",
    )

    # App
    APP_NAME: str = "Travel Memory Vault API"
    DEBUG: bool = True
    ENVIRONMENT: str = "development"
    FREE_TIER_MAX_TRIPS: int = 6

    # Observability
    SENTRY_DSN: Optional[str] = None
    
    # Supabase
    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_DB_URL: str
    SUPABASE_SERVICE_ROLE_KEY: str
    TEST_DATABASE_URL: str | None = None
    
    # External APIs
    FOURSQUARE_API_KEY: str
    MAPBOX_API_KEY: str
    
    # Backend secret (for internal use only, NOT for JWT verification)
    SECRET_KEY: str = "your-secret-key-change-this"
    
    # CORS
    ALLOWED_ORIGINS: str = "http://localhost:3000,http://localhost:5173"

    # Export renderer (Phase 6)
    RENDER_BACKEND: str = "mock"
    RENDERER_URL: str = "http://localhost:3100"

    # AWS / Lambda export settings
    AWS_REGION: str = "us-east-1"
    AWS_WORKER_ROLE_ARN: Optional[str] = None
    LAMBDA_FUNCTION_NAME: Optional[str] = None
    LAMBDA_SERVE_URL: Optional[str] = None
    LAMBDA_OUTPUT_BUCKET: Optional[str] = None

    # Export worker + guardrails
    EXPORT_WORKER_POLL_SECONDS: float = 2.0
    EXPORT_WORKER_STALE_SECONDS: int = 300
    # Optional explicit poll interval override. Set <= 0 to use backend defaults.
    EXPORT_RENDER_POLL_SECONDS: float = 0.0
    EXPORT_MAX_CONCURRENT_PER_USER: int = 2
    EXPORT_GLOBAL_QUEUE_CAP: int = 50
    EXPORT_FREE_TIER_MAX_QUALITY: str = "720p"
    EXPORT_FREE_TIER_MAX_DURATION_SEC: int = 15


settings = Settings()

# --- Production startup guards ---

if not settings.DEBUG and settings.SECRET_KEY == "your-secret-key-change-this":
    print("FATAL: SECRET_KEY must be changed from default in production", file=sys.stderr)
    sys.exit(1)

if settings.ENVIRONMENT == "production" and settings.DEBUG:
    print("FATAL: DEBUG=True is not allowed when ENVIRONMENT=production", file=sys.stderr)
    sys.exit(1)

if settings.ENVIRONMENT == "production" and settings.RENDER_BACKEND == "lambda":
    # API needs AWS creds for S3 presigned download URLs.
    # LAMBDA_OUTPUT_BUCKET is NOT checked here — API parses bucket from the
    # s3:// URL stored in the DB by the worker. The worker/renderer own that config.
    _missing = [v for v in ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
                if not os.getenv(v)]
    if _missing:
        print(f"FATAL: Lambda mode requires: {', '.join(_missing)}", file=sys.stderr)
        sys.exit(1)
