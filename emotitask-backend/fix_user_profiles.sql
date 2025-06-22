-- Fix user_profiles table to be standalone (not dependent on auth.users)

-- Drop the existing foreign key constraint
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_id_fkey;

-- Modify the table to be standalone
-- The id column should just be a UUID, not a foreign key
ALTER TABLE user_profiles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE user_profiles ALTER COLUMN id TYPE UUID USING id::UUID;

-- Add a comment to clarify this is standalone
COMMENT ON TABLE user_profiles IS 'Standalone user profiles created during onboarding assessment';
COMMENT ON COLUMN user_profiles.id IS 'Standalone UUID identifier for user profile';
COMMENT ON COLUMN user_profiles.persona_id IS 'References personality_types.persona_id (e.g., INTJ, ENFP)';

-- Update RLS policies to be more permissive since we're not using auth.users
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can create own profile" ON user_profiles;

-- Create more permissive policies for standalone operation
CREATE POLICY "Allow read access to user profiles" ON user_profiles FOR SELECT USING (true);
CREATE POLICY "Allow insert to user profiles" ON user_profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update to user profiles" ON user_profiles FOR UPDATE USING (true);

-- For now, disable RLS entirely on user_profiles for development
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

COMMENT ON POLICY "Allow read access to user profiles" ON user_profiles IS 'Permissive policy for development';
