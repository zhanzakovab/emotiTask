#!/usr/bin/env python3
"""
EmotiTask Backend Server
Run this to start the FastAPI server
"""

import uvicorn
from app.main import app
from app.config import settings

if __name__ == "__main__":
    print("🚀 Starting EmotiTask Backend...")
    print(f"📍 Server will run on: http://{settings.API_HOST}:{settings.API_PORT}")
    print(f"📖 API Documentation: http://{settings.API_HOST}:{settings.API_PORT}/docs")
    print(f"🔧 Debug mode: {settings.DEBUG}")
    
    uvicorn.run(
        "app.main:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=settings.DEBUG,
        log_level="info" if settings.DEBUG else "warning"
    ) 