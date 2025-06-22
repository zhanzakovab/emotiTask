-- Chat Data Table Schema for EmotiTask
-- Run this in your Supabase SQL Editor

-- Create chat_data table
CREATE TABLE chat_data (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
    messages JSONB DEFAULT '[]'::jsonb NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_chat_data_user_id ON chat_data(user_id);
CREATE INDEX idx_chat_data_updated_at ON chat_data(updated_at);

-- Enable Row Level Security (optional - can be disabled for development)
ALTER TABLE chat_data ENABLE ROW LEVEL SECURITY;

-- Create RLS policy (allows users to access their own chat data)
CREATE POLICY "Users can access own chat data" ON chat_data
    FOR ALL USING (true); -- Permissive for development

-- Add trigger for automatic updated_at timestamp
CREATE TRIGGER update_chat_data_updated_at 
    BEFORE UPDATE ON chat_data 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Add comments for documentation
COMMENT ON TABLE chat_data IS 'Stores persistent chat conversations for each user';
COMMENT ON COLUMN chat_data.id IS 'Unique identifier for chat session';
COMMENT ON COLUMN chat_data.user_id IS 'References user_profiles.id - one chat per user';
COMMENT ON COLUMN chat_data.messages IS 'JSONB array of chat messages with role, content, timestamp';
COMMENT ON COLUMN chat_data.created_at IS 'When the chat session was first created';
COMMENT ON COLUMN chat_data.updated_at IS 'Last time a message was added to the chat';

-- Example of messages JSONB structure:
-- [
--   {
--     "role": "user",
--     "content": "Hello, how can you help me?",
--     "timestamp": "2024-01-01T10:00:00Z"
--   },
--   {
--     "role": "assistant", 
--     "content": "Hi! I'm here to help with your tasks based on your ESTJ personality...",
--     "timestamp": "2024-01-01T10:00:05Z"
--   }
-- ]

-- Verify table creation
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'chat_data' 
ORDER BY ordinal_position;
