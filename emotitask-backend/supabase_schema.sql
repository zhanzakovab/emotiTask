-- EmotiTask Supabase Database Schema
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User profiles table
CREATE TABLE user_profiles (
    id UUID REFERENCES auth.users PRIMARY KEY,
    personality_type TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Projects table
CREATE TABLE projects (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    color TEXT DEFAULT 'blue',
    icon TEXT DEFAULT 'folder.fill',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table
CREATE TABLE tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    notes TEXT DEFAULT '',
    is_completed BOOLEAN DEFAULT FALSE,
    emotional_tag TEXT,
    scheduled_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    priority TEXT DEFAULT 'medium',
    estimated_duration INTEGER DEFAULT 30,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Goals table
CREATE TABLE goals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    target_date TIMESTAMP WITH TIME ZONE,
    progress DECIMAL(3,2) DEFAULT 0.0,
    category TEXT DEFAULT 'wellness',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Goal-Task relationships
CREATE TABLE goal_tasks (
    goal_id UUID REFERENCES goals(id) ON DELETE CASCADE,
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    PRIMARY KEY (goal_id, task_id)
);

-- Row Level Security (RLS) Policies
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_tasks ENABLE ROW LEVEL SECURITY;

-- User profiles policies
CREATE POLICY "Users can view own profile" ON user_profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can create own profile" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Projects policies
CREATE POLICY "Users can view own projects" ON projects FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own projects" ON projects FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own projects" ON projects FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own projects" ON projects FOR DELETE USING (auth.uid() = user_id);

-- Tasks policies
CREATE POLICY "Users can view own tasks" ON tasks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own tasks" ON tasks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own tasks" ON tasks FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own tasks" ON tasks FOR DELETE USING (auth.uid() = user_id);

-- Goals policies
CREATE POLICY "Users can view own goals" ON goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own goals" ON goals FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own goals" ON goals FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own goals" ON goals FOR DELETE USING (auth.uid() = user_id);

-- Goal-tasks policies
CREATE POLICY "Users can manage own goal-task relationships" ON goal_tasks 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM goals WHERE goals.id = goal_tasks.goal_id AND goals.user_id = auth.uid()
        )
    );

-- Indexes for better performance
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_scheduled_date ON tasks(scheduled_date);
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_is_completed ON tasks(is_completed);
CREATE INDEX idx_tasks_emotional_tag ON tasks(emotional_tag);
CREATE INDEX idx_tasks_priority ON tasks(priority);

CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_created_at ON projects(created_at);

CREATE INDEX idx_goals_user_id ON goals(user_id);
CREATE INDEX idx_goals_target_date ON goals(target_date);
CREATE INDEX idx_goals_category ON goals(category);
CREATE INDEX idx_goals_progress ON goals(progress);

-- Functions for automatic updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for automatic updated_at
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_goals_updated_at BEFORE UPDATE ON goals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert some sample data (optional)
-- You can uncomment these after setting up authentication

/*
-- Sample projects
INSERT INTO projects (user_id, title, description, color, icon) VALUES
    ('YOUR_USER_ID', 'Work Project Alpha', 'Q1 product launch preparation', 'blue', 'briefcase.fill'),
    ('YOUR_USER_ID', 'Home Renovation', 'Kitchen and living room updates', 'green', 'house.fill'),
    ('YOUR_USER_ID', 'iOS Development', 'Master SwiftUI and iOS development', 'purple', 'swift');

-- Sample tasks
INSERT INTO tasks (user_id, title, notes, emotional_tag, priority, estimated_duration) VALUES
    ('YOUR_USER_ID', '10-minute meditation', 'Daily mindfulness practice', 'self care', 'Medium', 10),
    ('YOUR_USER_ID', 'Review project proposal', 'Go through the Q1 launch details', 'focus', 'High', 60),
    ('YOUR_USER_ID', 'Call mom', 'Weekly check-in call', 'social', 'Medium', 30),
    ('YOUR_USER_ID', 'Grocery shopping', 'Weekly grocery run', 'routine', 'Low', 45);

-- Sample goals
INSERT INTO goals (user_id, title, description, target_date, category, progress) VALUES
    ('YOUR_USER_ID', 'Improve Work-Life Balance', 'Create better boundaries between work and personal time', NOW() + INTERVAL '30 days', 'Wellness', 0.4),
    ('YOUR_USER_ID', 'Learn SwiftUI', 'Master SwiftUI for iOS development', NOW() + INTERVAL '60 days', 'Learning', 0.7),
    ('YOUR_USER_ID', 'Daily Meditation', 'Establish a consistent meditation practice', NOW() + INTERVAL '30 days', 'Wellness', 0.6);
*/ 