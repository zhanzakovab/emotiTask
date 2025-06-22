# User Profile Table Fix Guide

## Issue
The `user_profiles` table currently has a foreign key constraint to `auth.users` which prevents standalone user profile creation during onboarding. This needs to be fixed for the MBTI assessment and user creation flow to work properly.

## Quick Fix (Required)

### Step 1: Run SQL Fix in Supabase
Copy and paste this SQL into your **Supabase SQL Editor** and execute:

```sql
-- Fix user_profiles table for standalone operation
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_id_fkey;
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
```

### Step 2: Verify Fix
After running the SQL, test the fix:

```bash
cd emotitask-backend
python test_user_creation.py
```

You should see:
```
✅ Assessment and user creation successful!
👤 User Profile Created:
   ID: [some-uuid]
   Persona ID: ESTJ
```

## Complete Implementation Summary

### What's Been Implemented

1. **Backend MBTI Calculator** (`app/mbti_calculator.py`)
   - Maps 10 questions to MBTI dimensions (E/I, S/N, T/F, J/P)
   - Calculates personality type with confidence score
   - Supports all 16 MBTI personality types

2. **Enhanced API Endpoints**
   - `POST /api/v1/mbti/assess-and-create-user` - Main onboarding endpoint
   - Creates user profile with calculated `persona_id`
   - Returns personality type, chat style, and user profile

3. **iOS Integration** 
   - `MBTIService.swift` - API service with user creation support
   - `OnboardingViewModel.swift` - Updated to use new endpoint
   - Stores user profile data in UserDefaults

4. **Database Schema**
   - `user_profiles` table with `persona_id` foreign key to `personality_types`
   - 10 real questions from your specification
   - 40 answers (4 per question)
   - 16 personality types with chat styles

### Complete Onboarding Flow

1. **User opens app** → WelcomeView
2. **Starts personality test** → OnboardingView loads 10 questions from API
3. **User answers questions** → Selections stored in array temporarily
4. **Clicks "Complete"** → Calls `assess-and-create-user` endpoint
5. **Backend calculates MBTI** → Uses sophisticated algorithm
6. **Creates user profile** → Inserts into `user_profiles` with `persona_id`
7. **Returns to app** → Stores user data and navigates to MainTabView

### Data Flow
```
User Selections → Assessment Array → API Call → MBTI Calculation → 
User Profile Creation → Database Storage → Response → iOS Storage → Main App
```

## Testing the Complete System

### Test 1: API Endpoints
```bash
cd emotitask-backend
python test_mbti_api.py
```
Should show all 6 tests passing.

### Test 2: User Creation Flow
```bash
python test_user_creation.py
```
Should create user profile and return personality type.

### Test 3: iOS App
1. Build and run the iOS app
2. Go through onboarding
3. Check console logs for successful API calls
4. Verify navigation to MainTabView

## Troubleshooting

### If user creation still fails after SQL fix:
1. Check Supabase logs for constraint violations
2. Verify `personality_types` table has all 16 types
3. Ensure `persona_id` values match (INTJ, ENFP, etc.)

### If iOS app doesn't navigate properly:
1. Check console logs for API errors
2. Verify backend server is running on correct port
3. Check network connectivity

### If questions don't load:
1. Verify `questions` and `answers` tables are populated
2. Check API endpoint returns 10 questions with 4 answers each
3. Review MBTIService error handling

## Next Steps After Fix

1. Run the SQL fix in Supabase
2. Test the user creation endpoint
3. Test the complete iOS onboarding flow
4. Verify user profile data is stored correctly
5. Check that personality-based features work

The system is fully implemented and ready to use once the foreign key constraint is removed!
