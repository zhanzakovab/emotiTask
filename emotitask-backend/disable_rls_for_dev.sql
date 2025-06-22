-- Temporarily disable RLS for development testing
-- Run this in your Supabase SQL editor for development only

-- Disable RLS on tasks table for development
ALTER TABLE tasks DISABLE ROW LEVEL SECURITY;

-- Re-enable with a permissive policy for development
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Create a permissive development policy
CREATE POLICY "Allow all operations for development" ON tasks
    FOR ALL 
    TO authenticated 
    USING (true)
    WITH CHECK (true);

-- You can also disable RLS entirely for development (not recommended for production)
-- ALTER TABLE tasks DISABLE ROW LEVEL SECURITY; 