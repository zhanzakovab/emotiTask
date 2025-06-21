#!/usr/bin/env python3
"""
Setup Development User for EmotiTask
This script creates a development user in Supabase for testing purposes.
"""

import asyncio
from supabase import create_client
from app.config import settings

async def setup_dev_user():
    """Create a development user in Supabase"""
    
    if not settings.SUPABASE_URL or not settings.SUPABASE_ANON_KEY:
        print("❌ Supabase credentials not found in .env file")
        return False
    
    # Use anon key for auth operations
    client = create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY)
    
    dev_email = "dev.user@example.com"
    dev_password = "devpassword123"
    
    try:
        # Try to sign up the development user
        print(f"🔧 Creating development user: {dev_email}")
        
        response = client.auth.sign_up({
            "email": dev_email,
            "password": dev_password
        })
        
        if response.user:
            user_id = response.user.id
            print(f"✅ Development user created successfully!")
            print(f"   User ID: {user_id}")
            print(f"   Email: {dev_email}")
            print(f"   Password: {dev_password}")
            print()
            print("🔧 Now update your auth.py file to use this user ID:")
            print(f'   Change "12345678-1234-1234-1234-123456789012" to "{user_id}"')
            return user_id
        else:
            print("❌ Failed to create user - no user returned")
            return False
            
    except Exception as e:
        error_message = str(e)
        if "User already registered" in error_message:
            print(f"ℹ️ Development user already exists: {dev_email}")
            
            # Try to sign in to get the user ID
            try:
                response = client.auth.sign_in_with_password({
                    "email": dev_email,
                    "password": dev_password
                })
                
                if response.user:
                    user_id = response.user.id
                    print(f"✅ Retrieved existing user ID: {user_id}")
                    print()
                    print("🔧 Update your auth.py file to use this user ID:")
                    print(f'   Change "12345678-1234-1234-1234-123456789012" to "{user_id}"')
                    return user_id
                    
            except Exception as signin_error:
                print(f"❌ Failed to sign in existing user: {signin_error}")
                return False
        else:
            print(f"❌ Error creating development user: {e}")
            return False

if __name__ == "__main__":
    print("🚀 EmotiTask Development User Setup")
    print("=" * 40)
    
    result = asyncio.run(setup_dev_user())
    
    if result:
        print()
        print("🎉 Setup complete! Your development user is ready.")
        print("   Tasks will now be saved to your Supabase database.")
    else:
        print()
        print("❌ Setup failed. Please check your Supabase configuration.") 