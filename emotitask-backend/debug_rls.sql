-- Debug RLS and create helper function for development
-- Run this in Supabase SQL Editor

-- Check current RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'tasks';

-- Check existing policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'tasks';

-- Create a function to get tasks bypassing RLS (for development)
CREATE OR REPLACE FUNCTION get_user_tasks(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    project_id UUID,
    title TEXT,
    notes TEXT,
    is_completed BOOLEAN,
    emotional_tag TEXT,
    scheduled_date TIMESTAMPTZ,
    priority TEXT,
    estimated_duration INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
SECURITY DEFINER
LANGUAGE SQL
AS $$
    SELECT 
        t.id,
        t.user_id,
        t.project_id,
        t.title,
        t.notes,
        t.is_completed,
        t.emotional_tag,
        t.scheduled_date,
        t.priority,
        t.estimated_duration,
        t.created_at,
        t.updated_at
    FROM tasks t
    WHERE t.user_id = p_user_id
    ORDER BY t.scheduled_date;
$$;

-- Grant execute permission to service role
GRANT EXECUTE ON FUNCTION get_user_tasks(UUID) TO service_role;

-- Check if tasks exist (this should show all tasks regardless of RLS)
SELECT count(*) as total_tasks FROM tasks;

-- Check tasks for specific user
SELECT count(*) as user_tasks FROM tasks WHERE user_id = 'bc5c3ff4-6011-4c9d-b057-b7989552114d'; 