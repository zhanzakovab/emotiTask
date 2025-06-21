from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.database import db
from app.config import settings
from typing import Optional, Dict, Any
import jwt

security = HTTPBearer(auto_error=False)

async def get_current_user(credentials: Optional[HTTPAuthorizationCredentials] = Depends(security)) -> Dict[str, Any]:
    """
    Validate JWT token and return current user
    """
    # DEVELOPMENT MODE: Allow unauthenticated access when DEBUG is True
    if settings.DEBUG and not credentials:
        print("🔧 Development mode: Using dummy user (no auth required)")
        return {"id": "12345678-1234-1234-1234-123456789012", "email": "dev@example.com"}
    
    # In development mode without Supabase, return dummy user
    if not db.configured:
        return {"id": "dummy-user-id", "email": "test@example.com"}
    
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header required"
        )
    
    token = credentials.credentials
    
    try:
        # Try to get user from Supabase
        user = await db.get_user_by_token(token)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication token"
            )
        return user
    except Exception as e:
        print(f"Auth error: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials"
        )

async def get_current_user_id(current_user: Dict[str, Any] = Depends(get_current_user)) -> str:
    """
    Extract user ID from current user
    """
    user_id = current_user.get("id")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User ID not found in token"
        )
    return user_id

def verify_token(token: str) -> Optional[Dict[str, Any]]:
    """
    Verify JWT token without raising exceptions
    """
    if not db.configured:
        return {"id": "dummy-user-id", "email": "test@example.com"}
    
    try:
        # Decode JWT token
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        return payload
    except jwt.PyJWTError:
        return None 