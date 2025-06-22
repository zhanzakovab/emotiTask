-- Temporarily disable RLS for development testing
-- Run this in your Supabase SQL Editor

-- Disable RLS on tasks table
ALTER TABLE tasks DISABLE ROW LEVEL SECURITY;

-- You can re-enable it later with:
-- ALTER TABLE tasks ENABLE ROW LEVEL SECURITY; 