from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.config import settings
from app.routes import auth, tasks, projects, goals, chat
import uvicorn

# Create FastAPI app
app = FastAPI(
    title="EmotiTask API",
    description="Emotionally intelligent task management backend with Supabase",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your frontend domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/v1")
app.include_router(tasks.router, prefix="/api/v1")
app.include_router(projects.router, prefix="/api/v1")
app.include_router(goals.router, prefix="/api/v1")
app.include_router(chat.router, prefix="/api/v1")

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "EmotiTask API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs"
    }

# Health check endpoint
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "supabase_configured": bool(settings.SUPABASE_URL and settings.SUPABASE_ANON_KEY),
        "openai_configured": bool(settings.OPENAI_API_KEY)
    }

# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": f"Internal server error: {str(exc)}"}
    )

# Startup event
@app.on_event("startup")
async def startup_event():
    print("🚀 EmotiTask API starting up...")
    print(f"📊 Debug mode: {settings.DEBUG}")
    print(f"🔗 Supabase URL: {settings.SUPABASE_URL[:50]}..." if settings.SUPABASE_URL else "❌ Supabase not configured")
    print(f"🤖 OpenAI: {'✅ Configured' if settings.OPENAI_API_KEY else '❌ Not configured'}")
    print("✅ EmotiTask API ready!")

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=settings.DEBUG
    ) 