"""
Application configuration from environment variables.

All settings loaded from .env file.
Never commit .env file to git.
"""

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
    FREE_TIER_MAX_TRIPS: int = 6
    
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
