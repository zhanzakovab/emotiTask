-- Populate MBTI Answers and Chat Styles
-- Run this AFTER creating the tables and inserting questions/personality_types

-- Insert sample answers for each question (4 answers per question)
-- Question 1 answers (Logic vs Values)
INSERT INTO answers (question_id, answer) VALUES
    (1, 'I rely primarily on logic and objective analysis, setting aside personal feelings'),
    (1, 'I consider both logic and personal values, but logic usually wins'),
    (1, 'I consider both logic and personal values, but personal impact usually wins'),
    (1, 'I prioritize personal values and how decisions affect people over pure logic');

-- Question 2 answers (Big Picture vs Details)
INSERT INTO answers (question_id, answer) VALUES
    (2, 'I focus almost entirely on future possibilities and big picture thinking'),
    (2, 'I prefer big picture but also pay attention to important details'),
    (2, 'I prefer concrete details but also consider future implications'),
    (2, 'I focus primarily on concrete details and present realities');

-- Question 3 answers (Planning vs Flexibility)
INSERT INTO answers (question_id, answer) VALUES
    (3, 'I strongly prefer having a clear plan and sticking to it'),
    (3, 'I like having a plan but am comfortable with minor adjustments'),
    (3, 'I prefer flexibility but appreciate having some structure'),
    (3, 'I strongly prefer keeping options open and adapting as I go');

-- Question 4 answers (Extraversion vs Introversion)
INSERT INTO answers (question_id, answer) VALUES
    (4, 'I feel most energized after spending time with large groups of people'),
    (4, 'I enjoy group activities but also need some alone time to recharge'),
    (4, 'I prefer small groups or one-on-one interactions over large gatherings'),
    (4, 'I feel most energized after spending time alone or with very close friends');

-- Question 5 answers (Theory vs Practice)
INSERT INTO answers (question_id, answer) VALUES
    (5, 'I strongly prefer understanding underlying principles before starting'),
    (5, 'I like to understand basics first but also learn through doing'),
    (5, 'I prefer hands-on learning but appreciate understanding the why'),
    (5, 'I strongly prefer jumping in and learning through hands-on experience');

-- Question 6 answers (Structure vs Spontaneity)
INSERT INTO answers (question_id, answer) VALUES
    (6, 'I strongly prefer structured and predictable environments'),
    (6, 'I like some structure but appreciate occasional flexibility'),
    (6, 'I prefer flexibility but can work well with some structure'),
    (6, 'I strongly prefer flexible and spontaneous environments');

-- Question 7 answers (Traditional vs Innovative)
INSERT INTO answers (question_id, answer) VALUES
    (7, 'I rely heavily on established methods and past experience'),
    (7, 'I prefer proven methods but am open to new approaches when needed'),
    (7, 'I like exploring new approaches but also value proven methods'),
    (7, 'I strongly prefer exploring new and innovative approaches');

-- Question 8 answers (Open vs Private)
INSERT INTO answers (question_id, answer) VALUES
    (8, 'I express my thoughts and feelings openly and immediately'),
    (8, 'I usually share my thoughts but may hold back on deeper feelings'),
    (8, 'I prefer to think things through before sharing, but do share eventually'),
    (8, 'I keep my thoughts and feelings private until I have thoroughly processed them');

-- Question 9 answers (Leadership vs Collaboration)
INSERT INTO answers (question_id, answer) VALUES
    (9, 'I naturally take charge and prefer to lead in most situations'),
    (9, 'I am comfortable leading when needed but do not always seek it out'),
    (9, 'I prefer collaborative approaches but can lead when necessary'),
    (9, 'I prefer to support others and work collaboratively rather than lead');

-- Question 10 answers (Quick vs Thorough Decision Making)
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

-- Verify the population
SELECT 'Data Population Complete!' as status,
       (SELECT COUNT(*) FROM answers) as answers_count,
       (SELECT COUNT(*) FROM chat_styles) as chat_styles_count,
       'Expected: 40 answers, 16 chat_styles' as expected;
