from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_NAME: str = "Dora"
    DEBUG: bool = True
    
    # Supabase
    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_DB_URL: str
    
    # External APIs
    FOURSQUARE_API_KEY: str
    MAPBOX_API_KEY: str
    
    # Backend secret (NOT for JWT verification, only for internal use)
    SECRET_KEY: str = "6mviiwo4eweuvtuyer7stj3uylnxd3q0"
    
    # CORS
    ALLOWED_ORIGINS: str = "http://localhost:3000,http://localhost:5173"
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()