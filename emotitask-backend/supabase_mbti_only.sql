-- MBTI Personality System Tables for Supabase
-- Run this in your Supabase SQL Editor

-- Questions table for MBTI questionnaire
CREATE TABLE IF NOT EXISTS questions (
    id SERIAL PRIMARY KEY,
    question VARCHAR(500) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Answers table for question responses
CREATE TABLE IF NOT EXISTS answers (
    id SERIAL PRIMARY KEY,
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE NOT NULL,
    answer TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Personality types table for MBTI types
CREATE TABLE IF NOT EXISTS personality_types (
    id SERIAL PRIMARY KEY,
    persona_id VARCHAR(10) UNIQUE NOT NULL, -- e.g., "INTJ", "ENFP"
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat styles table for MBTI-specific chat styles
CREATE TABLE IF NOT EXISTS chat_styles (
    id SERIAL PRIMARY KEY,
    personality_type_id INTEGER REFERENCES personality_types(id) ON DELETE CASCADE NOT NULL,
    keywords TEXT, -- JSON string of keywords
    temperature DECIMAL(3,2) NOT NULL DEFAULT 0.7, -- 0-2 range
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- MBTI tables policies (read-only for all authenticated users)
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE personality_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_styles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can read questions" ON questions;
DROP POLICY IF EXISTS "Anyone can read answers" ON answers;
DROP POLICY IF EXISTS "Anyone can read personality types" ON personality_types;
DROP POLICY IF EXISTS "Anyone can read chat styles" ON chat_styles;

CREATE POLICY "Anyone can read questions" ON questions FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Anyone can read answers" ON answers FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Anyone can read personality types" ON personality_types FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Anyone can read chat styles" ON chat_styles FOR SELECT USING (auth.role() = 'authenticated');

-- MBTI tables indexes
CREATE INDEX IF NOT EXISTS idx_answers_question_id ON answers(question_id);
CREATE INDEX IF NOT EXISTS idx_personality_types_persona_id ON personality_types(persona_id);
CREATE INDEX IF NOT EXISTS idx_chat_styles_personality_type_id ON chat_styles(personality_type_id);

-- Insert 16 MBTI personality types
INSERT INTO personality_types (persona_id, name, description) VALUES
    ('INTJ', 'The Architect', 'Imaginative and strategic thinkers, with a plan for everything.'),
    ('INTP', 'The Thinker', 'Innovative inventors with an unquenchable thirst for knowledge.'),
    ('ENTJ', 'The Commander', 'Bold, imaginative and strong-willed leaders, always finding a way – or making one.'),
    ('ENTP', 'The Debater', 'Smart and curious thinkers who cannot resist an intellectual challenge.'),
    ('INFJ', 'The Advocate', 'Creative and insightful, inspired and independent.'),
    ('INFP', 'The Mediator', 'Poetic, kind and altruistic people, always eager to help a good cause.'),
    ('ENFJ', 'The Protagonist', 'Charismatic and inspiring leaders, able to mesmerize their listeners.'),
    ('ENFP', 'The Campaigner', 'Enthusiastic, creative and sociable free spirits, who can always find a reason to smile.'),
    ('ISTJ', 'The Logistician', 'Practical and fact-minded, reliable and responsible.'),
    ('ISFJ', 'The Protector', 'Warm-hearted and dedicated, always ready to protect their loved ones.'),
    ('ESTJ', 'The Executive', 'Excellent administrators, unsurpassed at managing things – or people.'),
    ('ESFJ', 'The Consul', 'Extraordinarily caring, social and popular people, always eager to help.'),
    ('ISTP', 'The Virtuoso', 'Bold and practical experimenters, masters of all kinds of tools.'),
    ('ISFP', 'The Adventurer', 'Flexible and charming artists, always ready to explore new possibilities.'),
    ('ESTP', 'The Entrepreneur', 'Smart, energetic and very perceptive people, who truly enjoy living on the edge.'),
    ('ESFP', 'The Entertainer', 'Spontaneous, energetic and enthusiastic people – life is never boring around them.')
ON CONFLICT (persona_id) DO NOTHING;

-- Insert sample questions for MBTI assessment
INSERT INTO questions (question) VALUES
    ('When making decisions, do you prefer to rely on logic and objective analysis, or do you consider personal values and how decisions affect people?'),
    ('Do you prefer to focus on the big picture and future possibilities, or do you prefer to focus on concrete details and present realities?'),
    ('When working on projects, do you prefer to have a clear plan and stick to it, or do you prefer to keep your options open and adapt as you go?'),
    ('Do you feel more energized after spending time with groups of people, or after spending time alone or with one or two close friends?'),
    ('When learning something new, do you prefer to understand the underlying principles first, or do you prefer to jump in and learn through hands-on experience?'),
    ('Do you prefer environments that are structured and predictable, or do you prefer environments that are flexible and spontaneous?'),
    ('When solving problems, do you rely more on established methods and past experience, or do you prefer to explore new and innovative approaches?'),
    ('Do you prefer to express your thoughts and feelings openly, or do you prefer to keep them private until you have thought them through?'),
    ('When working in teams, do you prefer to take charge and lead, or do you prefer to support others and work collaboratively?'),
    ('Do you make decisions quickly based on available information, or do you prefer to gather extensive information before deciding?');

-- Insert sample answers for each question (4 answers per question)
-- Question 1 answers
INSERT INTO answers (question_id, answer) VALUES
    (1, 'I rely primarily on logic and objective analysis, setting aside personal feelings'),
    (1, 'I consider both logic and personal values, but logic usually wins'),
    (1, 'I consider both logic and personal values, but personal impact usually wins'),
    (1, 'I prioritize personal values and how decisions affect people over pure logic');

-- Question 2 answers
INSERT INTO answers (question_id, answer) VALUES
    (2, 'I focus almost entirely on future possibilities and big picture thinking'),
    (2, 'I prefer big picture but also pay attention to important details'),
    (2, 'I prefer concrete details but also consider future implications'),
    (2, 'I focus primarily on concrete details and present realities');

-- Question 3 answers
INSERT INTO answers (question_id, answer) VALUES
    (3, 'I strongly prefer having a clear plan and sticking to it'),
    (3, 'I like having a plan but am comfortable with minor adjustments'),
    (3, 'I prefer flexibility but appreciate having some structure'),
    (3, 'I strongly prefer keeping options open and adapting as I go');

-- Question 4 answers
INSERT INTO answers (question_id, answer) VALUES
    (4, 'I feel most energized after spending time with large groups of people'),
    (4, 'I enjoy group activities but also need some alone time to recharge'),
    (4, 'I prefer small groups or one-on-one interactions over large gatherings'),
    (4, 'I feel most energized after spending time alone or with very close friends');

-- Question 5 answers
INSERT INTO answers (question_id, answer) VALUES
    (5, 'I strongly prefer understanding underlying principles before starting'),
    (5, 'I like to understand basics first but also learn through doing'),
    (5, 'I prefer hands-on learning but appreciate understanding the why'),
    (5, 'I strongly prefer jumping in and learning through hands-on experience');

-- Question 6 answers
INSERT INTO answers (question_id, answer) VALUES
    (6, 'I strongly prefer structured and predictable environments'),
    (6, 'I like some structure but appreciate occasional flexibility'),
    (6, 'I prefer flexibility but can work well with some structure'),
    (6, 'I strongly prefer flexible and spontaneous environments');

-- Question 7 answers
INSERT INTO answers (question_id, answer) VALUES
    (7, 'I rely heavily on established methods and past experience'),
    (7, 'I prefer proven methods but am open to new approaches when needed'),
    (7, 'I like exploring new approaches but also value proven methods'),
    (7, 'I strongly prefer exploring new and innovative approaches');

-- Question 8 answers
INSERT INTO answers (question_id, answer) VALUES
    (8, 'I express my thoughts and feelings openly and immediately'),
    (8, 'I usually share my thoughts but may hold back on deeper feelings'),
    (8, 'I prefer to think things through before sharing, but do share eventually'),
    (8, 'I keep my thoughts and feelings private until I have thoroughly processed them');

-- Question 9 answers
INSERT INTO answers (question_id, answer) VALUES
    (9, 'I naturally take charge and prefer to lead in most situations'),
    (9, 'I am comfortable leading when needed but do not always seek it out'),
    (9, 'I prefer collaborative approaches but can lead when necessary'),
    (9, 'I prefer to support others and work collaboratively rather than lead');

-- Question 10 answers
INSERT INTO answers (question_id, answer) VALUES
    (10, 'I make decisions quickly based on available information'),
    (10, 'I prefer to decide relatively quickly but gather key information first'),
    (10, 'I like to gather substantial information but do not over-analyze'),
    (10, 'I prefer to gather extensive information before making any decision');

-- Insert chat styles for each personality type
INSERT INTO chat_styles (personality_type_id, keywords, temperature) VALUES
    (1, '["analytical", "strategic", "efficient", "systematic", "goal-oriented"]', 0.6), -- INTJ
    (2, '["curious", "theoretical", "innovative", "logical", "exploratory"]', 0.8), -- INTP
    (3, '["decisive", "leadership", "strategic", "ambitious", "results-focused"]', 0.7), -- ENTJ
    (4, '["creative", "brainstorming", "possibilities", "debate", "innovative"]', 0.9), -- ENTP
    (5, '["insightful", "meaningful", "empathetic", "visionary", "authentic"]', 0.7), -- INFJ
    (6, '["values-based", "compassionate", "creative", "harmonious", "personal"]', 0.8), -- INFP
    (7, '["inspiring", "motivational", "people-focused", "collaborative", "growth"]', 0.8), -- ENFJ
    (8, '["enthusiastic", "energetic", "optimistic", "social", "spontaneous"]', 0.9), -- ENFP
    (9, '["practical", "organized", "reliable", "systematic", "traditional"]', 0.5), -- ISTJ
    (10, '["caring", "supportive", "helpful", "considerate", "nurturing"]', 0.6), -- ISFJ
    (11, '["organized", "efficient", "leadership", "structured", "results-driven"]', 0.6), -- ESTJ
    (12, '["helpful", "social", "caring", "cooperative", "community-focused"]', 0.7), -- ESFJ
    (13, '["practical", "hands-on", "problem-solving", "adaptable", "action-oriented"]', 0.7), -- ISTP
    (14, '["gentle", "artistic", "flexible", "personal", "experiential"]', 0.8), -- ISFP
    (15, '["energetic", "action-oriented", "practical", "spontaneous", "direct"]', 0.8), -- ESTP
    (16, '["fun", "energetic", "people-focused", "spontaneous", "positive"]', 0.9); -- ESFP

-- Verify the setup
SELECT 'MBTI Setup Complete!' as status,
       (SELECT COUNT(*) FROM personality_types) as personality_types_count,
       (SELECT COUNT(*) FROM questions) as questions_count,
       (SELECT COUNT(*) FROM answers) as answers_count,
       (SELECT COUNT(*) FROM chat_styles) as chat_styles_count;
