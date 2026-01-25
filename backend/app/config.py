"""
Application configuration from environment variables.

All settings loaded from .env file.
Never commit .env file to git.
"""

from pydantic_settings import BaseSettings
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
    
    # App
    APP_NAME: str = "Travel Memory Vault API"
    DEBUG: bool = True
    
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
    
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
