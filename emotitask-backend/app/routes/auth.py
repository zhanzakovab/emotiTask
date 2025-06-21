from fastapi import APIRouter, HTTPException, status, Depends
from app.models import UserSignUp, UserSignIn, Token, UserProfile, UserProfileUpdate
from app.database import db
from app.auth import get_current_user_id
from app.config import settings

router = APIRouter(prefix="/auth", tags=["authentication"])

@router.post("/signup", response_model=Token, status_code=status.HTTP_201_CREATED)
async def sign_up(user_data: UserSignUp):
    """Sign up a new user"""
    try:
        # Use Supabase client directly for auth operations
        response = db.client.auth.sign_up({
            "email": user_data.email,
            "password": user_data.password
        })
        
        if response.user:
            # Create user profile
            try:
                await db.create_user_profile(response.user.id, {
                    "personality_type": None
                })
            except:
                # Profile creation failed, but user was created
                pass
            
            return Token(
                access_token=response.session.access_token if response.session else "",
                expires_in=response.session.expires_in if response.session else 3600,
                user=response.user.__dict__
            )
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create user"
            )
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Sign up failed: {str(e)}"
        )

@router.post("/signin", response_model=Token)
async def sign_in(user_data: UserSignIn):
    """Sign in an existing user"""
    try:
        response = db.client.auth.sign_in_with_password({
            "email": user_data.email,
            "password": user_data.password
        })
        
        if response.user and response.session:
            return Token(
                access_token=response.session.access_token,
                expires_in=response.session.expires_in,
                user=response.user.__dict__
            )
        else:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Sign in failed: {str(e)}"
        )

@router.post("/signout")
async def sign_out(user_id: str = Depends(get_current_user_id)):
    """Sign out the current user"""
    try:
        db.client.auth.sign_out()
        return {"message": "Successfully signed out"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Sign out failed: {str(e)}"
        )

@router.get("/profile", response_model=UserProfile)
async def get_user_profile(user_id: str = Depends(get_current_user_id)):
    """Get current user's profile"""
    try:
        profile = await db.get_user_profile(user_id)
        if not profile:
            # Create default profile if it doesn't exist
            profile = await db.create_user_profile(user_id, {
                "personality_type": None
            })
        return profile
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to fetch profile: {str(e)}"
        )

@router.put("/profile", response_model=UserProfile)
async def update_user_profile(
    profile_update: UserProfileUpdate,
    user_id: str = Depends(get_current_user_id)
):
    """Update current user's profile"""
    try:
        update_data = profile_update.model_dump(exclude_unset=True)
        updated_profile = await db.update_user_profile(user_id, update_data)
        return updated_profile
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update profile: {str(e)}"
        )

@router.get("/me")
async def get_current_user_info(user_id: str = Depends(get_current_user_id)):
    """Get current user information"""
    try:
        # Get user info from Supabase
        user = db.client.auth.get_user()
        profile = await db.get_user_profile(user_id)
        
        return {
            "user": user.user.__dict__ if user.user else None,
            "profile": profile
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to fetch user info: {str(e)}"
        ) 