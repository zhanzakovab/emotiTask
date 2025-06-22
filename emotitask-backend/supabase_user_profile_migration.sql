-- Migration: Update user_profiles table to use persona_id with foreign key
-- Run this in your Supabase SQL Editor

-- Step 1: Add the new persona_id column
ALTER TABLE user_profiles 
ADD COLUMN persona_id VARCHAR(10);

-- Step 2: Copy existing data from personality_type to persona_id
-- (Only if there's existing data that matches personality_types.persona_id)
UPDATE user_profiles 
SET persona_id = personality_type 
WHERE personality_type IN (
    SELECT persona_id FROM personality_types
);

-- Step 3: Drop the old personality_type column
ALTER TABLE user_profiles 
DROP COLUMN personality_type;

-- Step 4: Add foreign key constraint
ALTER TABLE user_profiles 
ADD CONSTRAINT fk_user_profiles_persona_id 
FOREIGN KEY (persona_id) REFERENCES personality_types(persona_id) ON DELETE SET NULL;

-- Step 5: Add index for better performance
CREATE INDEX idx_user_profiles_persona_id ON user_profiles(persona_id);

-- Step 6: Update the trigger to handle the new column
-- The existing update trigger should still work since it updates updated_at

-- Optional: Add a comment to document the relationship
COMMENT ON COLUMN user_profiles.persona_id IS 'References personality_types.persona_id (e.g., INTJ, ENFP)';

-- Verify the changes
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
ORDER BY ordinal_position; 