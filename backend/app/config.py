"""
Application configuration from environment variables.

All settings loaded from .env file.
Never commit .env file to git.
"""

import os
import sys

from pydantic import field_validator
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
    RENDERER_SHARED_SECRET: str = ""

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

    # Live-tracking worker and inference defaults (Phase 3)
    TRACKING_WORKER_POLL_SECONDS: float = 5.0
    TRACKING_WORKER_BATCH_SIZE: int = 25
    TRACKING_POINT_MAX_ACCURACY_M: float = 80.0
    TRACKING_POINT_DEDUP_DISTANCE_M: float = 15.0
    TRACKING_POINT_DEDUP_WINDOW_SECONDS: int = 20
    TRACKING_STAY_RADIUS_M: float = 120.0
    TRACKING_STAY_MIN_DURATION_MINUTES: int = 10
    TRACKING_NOTIFICATION_CONFIDENCE_MIN: float = 0.35
    TRACKING_NOTIFICATION_CONFIDENCE_MAX: float = 0.85
    TRACKING_NOTIFICATION_MAX_ATTEMPTS: int = 3
    TRACKING_NOTIFICATION_BACKOFF_SECONDS: str = "30,120,480"
    TRACKING_PUSH_SUPPRESS_RECENT_ACTIVITY_SECONDS: int = 120
    TRACKING_AUTO_END_INACTIVITY_HOURS: int = 6
    TRACKING_AUTO_END_PROMPT_GRACE_MINUTES: int = 30
    TRACKING_WORKER_MAX_BATCH_MULTIPLIER: int = 4
    TRACKING_ALERT_RETRYABLE_BACKLOG_THRESHOLD: int = 100
    TRACKING_ALERT_DISPATCH_LAG_MINUTES: int = 30
    TRACKING_ALERT_STUCK_SESSION_THRESHOLD: int = 25
    TRACKING_ALERT_INFERENCE_BACKLOG_THRESHOLD: int = 200

    # Push notifications (Firebase)
    FIREBASE_PUSH_ENABLED: bool = False
    FIREBASE_PROJECT_ID: Optional[str] = None
    FIREBASE_CREDENTIALS_PATH: Optional[str] = None
    FIREBASE_CREDENTIALS_JSON: Optional[str] = None

    # Advisory worker (Phase P4)
    ADVISORY_WORKER_POLL_SECONDS: float = 5.0
    ADVISORY_WORKER_STALE_SECONDS: int = 900
    ADVISORY_MIN_CONFIDENCE_PUSH: float = 0.7
    ADVISORY_MAX_PER_HOUR: int = 3

    # Advisory external services (optional — worker skips stages if missing)
    OPENROUTER_API_KEY: Optional[str] = None
    OPENROUTER_MODEL: str = "openai/gpt-oss-120b:free"
    BRIGHTDATA_WS_ENDPOINT: Optional[str] = None
    # Debug-only switch to run backend gmaps scraper against local Chromium
    # instead of BrightData CDP. Keep disabled in normal operation.
    ADVISORY_GMAPS_LOCAL_DEBUG: bool = False
    ADVISORY_GMAPS_LOCAL_HEADLESS: bool = False
    ADVISORY_GMAPS_LOCAL_SLOWMO_MS: int = 0

    # Upstash Redis (advisory session cache)
    UPSTASH_REDIS_URL: Optional[str] = None
    UPSTASH_REDIS_TOKEN: Optional[str] = None

    # Advisory trip-brain + cycle engine (this slice)
    ADVISORY_CYCLE_POLL_SECONDS: float = 30.0
    ADVISORY_CYCLE_BATCH_SIZE: int = 50
    ADVISORY_CYCLE_PROCESSING_TIMEOUT_SECONDS: int = 120
    ADVISORY_RETRY_BACKOFF_SECONDS: int = 300
    ADVISORY_RESEED_MIN_INTERVAL_SECONDS: int = 120
    ADVISORY_NO_PICK_RETRY_BUDGET: int = 2

    # Advisory feedback loop
    ADVISORY_IGNORE_TTL_SECONDS: int = 3600
    ADVISORY_IGNORE_PAUSE_THRESHOLD: int = 3

    # Advisory sampling + geo
    ADVISORY_SAMPLE_COUNT: int = 22
    ADVISORY_CENTROID_WINDOW_SECONDS: int = 7200
    ADVISORY_INTRA_CITY_DISTANCE_THRESHOLD_KM: float = 50.0
    ADVISORY_LONG_ROAD_DISTANCE_THRESHOLD_KM: float = 300.0
    ADVISORY_OFF_ROUTE_THRESHOLD_METERS: int = 5000

    # Advisory caches (Redis TTLs)
    ADVISORY_GEOCODE_CACHE_TTL_SECONDS: int = 604800  # 7d
    ADVISORY_WEATHER_CACHE_TTL_SECONDS: int = 10800   # 3h
    ADVISORY_REDDIT_SEED_CACHE_TTL_SECONDS: int = 259200  # 72h
    ADVISORY_BRAIN_CACHE_TTL_SECONDS: int = 86400     # 24h
    ADVISORY_MODE_CACHE_TTL_SECONDS: int = 86400      # 24h

    # GMaps / BrightData cost governors
    BRIGHTDATA_AUTH: Optional[str] = None
    BRIGHTDATA_REVIEWS_PER_POI: int = 4
    BRIGHTDATA_MAX_REVIEWS_PER_CYCLE: int = 15
    BRIGHTDATA_MAX_CALLS_PER_TRIP: int = 50

    # Brain array guardrails
    MAX_ADVISED_POIS_PER_TRIP: int = 500
    MAX_ADVISED_LOCALITIES_PER_TRIP: int = 200

    # Debug endpoint gate
    EXPOSE_ADVISORY_STATE_ENDPOINT: bool = False

    # V2 publish storage verification
    V2_STORAGE_REQUIRE_EXISTENCE_CHECK: bool = True
    V2_ROUTE_MAP_MATCH_ENABLED: bool = True
    V2_ROUTE_MAP_MATCH_TIMEOUT_SECONDS: float = 2.0
    V2_ROUTE_MAP_MATCH_PROFILE: str = "mapbox/driving"

    # Stories moderation allow-list (comma-separated Supabase user UUIDs).
    STORIES_MODERATOR_USER_IDS: str = ""

    @field_validator("DEBUG", mode="before")
    @classmethod
    def _coerce_debug(cls, value: object) -> object:
        """Support common profile-style values used by tooling in this monorepo."""
        if isinstance(value, str):
            normalized = value.strip().lower()
            if normalized in {"release", "profile"}:
                return False
            if normalized == "debug":
                return True
        return value


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

if settings.ENVIRONMENT == "production" and settings.RENDER_BACKEND in {"local", "lambda"}:
    if not settings.RENDERER_SHARED_SECRET:
        print("FATAL: RENDERER_SHARED_SECRET must be set in production", file=sys.stderr)
        sys.exit(1)
