import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    # Supabase
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_ANON_KEY: str = os.getenv("SUPABASE_ANON_KEY", "")
    SUPABASE_SERVICE_ROLE_KEY: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
    
    # FastAPI
    API_HOST: str = os.getenv("API_HOST", "0.0.0.0")
    API_PORT: int = int(os.getenv("API_PORT", "8000"))
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"
    
    # Security
    JWT_SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "your-secret-key-here")
    JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
    JWT_EXPIRE_MINUTES: int = int(os.getenv("JWT_EXPIRE_MINUTES", "30"))
    
    # OpenAI
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    
    # Validation (only warn, don't fail for development)
    def validate(self):
        if not self.SUPABASE_URL:
            print("⚠️  WARNING: SUPABASE_URL not configured - some features will not work")
        if not self.SUPABASE_ANON_KEY:
            print("⚠️  WARNING: SUPABASE_ANON_KEY not configured - authentication will not work")
        if not self.SUPABASE_SERVICE_ROLE_KEY:
            print("⚠️  WARNING: SUPABASE_SERVICE_ROLE_KEY not configured - database operations will not work")
        if not self.OPENAI_API_KEY:
            print("⚠️  WARNING: OPENAI_API_KEY not configured - AI chat will use dummy responses")

settings = Settings()
settings.validate() 