-- Fix user_profiles table schema for standalone operation
-- Run this in your Supabase SQL Editor

-- Step 1: Drop the existing foreign key constraint
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_id_fkey;

-- Step 2: Drop existing RLS policies that depend on auth.uid()
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can create own profile" ON user_profiles;

-- Step 3: Disable RLS for development (can be re-enabled later)
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- Step 4: Add comments for documentation
COMMENT ON TABLE user_profiles IS 'Standalone user profiles created during onboarding assessment';
COMMENT ON COLUMN user_profiles.id IS 'Standalone UUID identifier for user profile';
COMMENT ON COLUMN user_profiles.persona_id IS 'References personality_types.persona_id (e.g., INTJ, ENFP)';

-- Step 5: Verify the table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
ORDER BY ordinal_position;

-- Step 6: Test insert capability
-- This should work now without foreign key constraints
-- (This is just a test - will be deleted immediately)
INSERT INTO user_profiles (id, persona_id, created_at, updated_at) 
VALUES (
    'test-' || gen_random_uuid()::text,
    'INTJ',
    NOW(),
    NOW()
);

-- Clean up test data
DELETE FROM user_profiles WHERE id LIKE 'test-%';

-- Verification complete
SELECT 'user_profiles table is now ready for standalone operation' AS status; 