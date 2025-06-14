-- Dual RPG Engine Database Schema
-- Migration 005: Sample Data and Reference Tables

-- =====================================================
-- CHARACTER CLASSES
-- =====================================================

INSERT INTO character_classes (id, name, description, base_attributes, skill_affinities, is_starter_class, sort_order) VALUES
(uuid_generate_v4(), 'Warrior', 'A strong fighter focused on physical combat and protection', 
 '{"strength": 5, "constitution": 3, "dexterity": 2}', 
 '["Combat", "Athletics", "Leadership"]', true, 1),
(uuid_generate_v4(), 'Mage', 'A wielder of arcane magic and keeper of ancient knowledge', 
 '{"intelligence": 5, "wisdom": 3, "charisma": 2}', 
 '["Magic", "Research", "Academics"]', true, 2),
(uuid_generate_v4(), 'Rogue', 'A stealthy character skilled in deception and precision', 
 '{"dexterity": 5, "intelligence": 3, "charisma": 2}', 
 '["Stealth", "Technology", "Social"]', true, 3),
(uuid_generate_v4(), 'Cleric', 'A divine spellcaster focused on healing and support', 
 '{"wisdom": 5, "charisma": 3, "constitution": 2}', 
 '["Healing", "Social", "Spirituality"]', true, 4),
(uuid_generate_v4(), 'Ranger', 'A versatile outdoorsman with survival and tracking skills', 
 '{"dexterity": 3, "wisdom": 3, "constitution": 3, "intelligence": 1}', 
 '["Nature", "Survival", "Athletics"]', true, 5),
(uuid_generate_v4(), 'Paladin', 'A holy warrior combining combat prowess with divine magic', 
 '{"strength": 3, "charisma": 3, "constitution": 3, "wisdom": 1}', 
 '["Combat", "Leadership", "Spirituality"]', false, 6);

-- =====================================================
-- SKILL CATEGORIES
-- =====================================================

INSERT INTO skill_categories (id, name, description, icon, sort_order) VALUES
(uuid_generate_v4(), 'Combat', 'Physical fighting and warfare skills', 'sword', 1),
(uuid_generate_v4(), 'Magic', 'Arcane and mystical abilities', 'sparkles', 2),
(uuid_generate_v4(), 'Athletics', 'Physical fitness and sports', 'figure.run', 3),
(uuid_generate_v4(), 'Academics', 'Learning and intellectual pursuits', 'book', 4),
(uuid_generate_v4(), 'Technology', 'Digital skills and programming', 'laptopcomputer', 5),
(uuid_generate_v4(), 'Social', 'Interpersonal and communication skills', 'person.2', 6),
(uuid_generate_v4(), 'Creative', 'Artistic and creative endeavors', 'paintbrush', 7),
(uuid_generate_v4(), 'Survival', 'Outdoor and survival skills', 'leaf', 8),
(uuid_generate_v4(), 'Healing', 'Medical and wellness skills', 'cross.case', 9),
(uuid_generate_v4(), 'Leadership', 'Management and leadership abilities', 'crown', 10),
(uuid_generate_v4(), 'Stealth', 'Infiltration and covert operations', 'eye.slash', 11),
(uuid_generate_v4(), 'Research', 'Investigation and analytical skills', 'magnifyingglass', 12),
(uuid_generate_v4(), 'Spirituality', 'Meditation and spiritual practices', 'moon.stars', 13),
(uuid_generate_v4(), 'Nature', 'Environmental and ecological knowledge', 'tree', 14);

-- =====================================================
-- SKILLS
-- =====================================================

-- Combat Skills
INSERT INTO skills (id, category_id, name, description, max_level, base_experience_cost, sort_order) VALUES
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Combat'), 'Sword Fighting', 'Mastery of blade combat techniques', 100, 100, 1),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Combat'), 'Archery', 'Precision with bow and arrow', 100, 100, 2),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Combat'), 'Shield Defense', 'Protective combat techniques', 100, 100, 3),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Combat'), 'Unarmed Combat', 'Hand-to-hand fighting techniques', 100, 100, 4);

-- Magic Skills
INSERT INTO skills (id, category_id, name, description, max_level, base_experience_cost, sort_order) VALUES
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Magic'), 'Elemental Magic', 'Control over fire, water, earth, and air', 100, 150, 1),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Magic'), 'Illusion Magic', 'Creating false images and deceptions', 100, 150, 2),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Magic'), 'Enchantment', 'Imbuing objects with magical properties', 100, 150, 3),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Magic'), 'Divination', 'Gaining knowledge through magical means', 100, 150, 4);

-- Athletics Skills
INSERT INTO skills (id, category_id, name, description, max_level, base_experience_cost, sort_order) VALUES
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Athletics'), 'Running', 'Cardiovascular endurance and speed', 100, 50, 1),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Athletics'), 'Strength Training', 'Building physical power and muscle', 100, 50, 2),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Athletics'), 'Gymnastics', 'Flexibility and acrobatic skills', 100, 75, 3),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Athletics'), 'Swimming', 'Aquatic fitness and technique', 100, 50, 4);

-- Academics Skills
INSERT INTO skills (id, category_id, name, description, max_level, base_experience_cost, sort_order) VALUES
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Academics'), 'Mathematics', 'Mathematical reasoning and calculation', 100, 100, 1),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Academics'), 'History', 'Knowledge of past events and civilizations', 100, 100, 2),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Academics'), 'Science', 'Understanding of natural phenomena', 100, 100, 3),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Academics'), 'Philosophy', 'Deep thinking about existence and meaning', 100, 125, 4);

-- Technology Skills
INSERT INTO skills (id, category_id, name, description, max_level, base_experience_cost, sort_order) VALUES
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Technology'), 'Programming', 'Creating software and applications', 100, 150, 1),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Technology'), 'Web Development', 'Building websites and web applications', 100, 125, 2),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Technology'), 'Data Analysis', 'Interpreting and analyzing data sets', 100, 125, 3),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Technology'), 'Cybersecurity', 'Protecting digital systems and data', 100, 175, 4);

-- Social Skills
INSERT INTO skills (id, category_id, name, description, max_level, base_experience_cost, sort_order) VALUES
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Social'), 'Public Speaking', 'Effective communication to audiences', 100, 100, 1),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Social'), 'Negotiation', 'Reaching mutually beneficial agreements', 100, 125, 2),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Social'), 'Networking', 'Building professional relationships', 100, 100, 3),
(uuid_generate_v4(), (SELECT id FROM skill_categories WHERE name = 'Social'), 'Empathy', 'Understanding and sharing others emotions', 100, 75, 4);

-- =====================================================
-- QUEST CATEGORIES
-- =====================================================

INSERT INTO quest_categories (id, name, description, color_code, icon, sort_order) VALUES
(uuid_generate_v4(), 'Daily Habits', 'Regular activities to build consistency', '#10B981', 'calendar', 1),
(uuid_generate_v4(), 'Fitness', 'Physical health and exercise challenges', '#EF4444', 'figure.run', 2),
(uuid_generate_v4(), 'Learning', 'Educational and skill development tasks', '#3B82F6', 'book', 3),
(uuid_generate_v4(), 'Social', 'Interpersonal and community activities', '#8B5CF6', 'person.2', 4),
(uuid_generate_v4(), 'Creative', 'Artistic and creative projects', '#F59E0B', 'paintbrush', 5),
(uuid_generate_v4(), 'Work', 'Professional and career development', '#6B7280', 'briefcase', 6),
(uuid_generate_v4(), 'Adventure', 'Exploration and new experiences', '#EC4899', 'map', 7),
(uuid_generate_v4(), 'Wellness', 'Mental health and self-care', '#14B8A6', 'heart', 8);

-- =====================================================
-- SAMPLE QUEST TEMPLATES
-- =====================================================

-- Daily Habits Quests
INSERT INTO quest_templates (id, category_id, title, description, difficulty_level, estimated_duration, experience_reward, objectives, is_repeatable, cooldown_hours) VALUES
(uuid_generate_v4(), (SELECT id FROM quest_categories WHERE name = 'Daily Habits'), 'Morning Routine Master', 'Complete your morning routine for 7 consecutive days', 2, 30, 200, 
 '[{"id": "morning_routine", "type": "streak", "description": "Complete morning routine", "target": 7}]', true, 168),
(uuid_generate_v4(), (SELECT id FROM quest_categories WHERE name = 'Daily Habits'), 'Hydration Hero', 'Drink 8 glasses of water today', 1, 480, 50, 
 '[{"id": "water_intake", "type": "count", "description": "Glasses of water", "target": 8}]', true, 24),
(uuid_generate_v4(), (SELECT id FROM quest_categories WHERE name = 'Daily Habits'), 'Digital Detox', 'Spend less than 2 hours on social media today', 3, 120, 75, 
 '[{"id": "social_media_time", "type": "limit", "description": "Social media time", "target": 120}]', true, 24);

-- Fitness Quests
INSERT INTO quest_templates (id, category_id, title, description, difficulty_level, estimated_duration, experience_reward, skill_experience_rewards, objectives, is_repeatable, cooldown_hours) VALUES
(uuid_generate_v4(), (SELECT id FROM quest_categories WHERE name = 'Fitness'), 'Step Counter Champion', 'Walk 10,000 steps in a single day', 2, 300, 100, 
 '{"' || (SELECT id FROM skills WHERE name = 'Running') || '": 50}', 
 '[{"id": "steps", "type": "count", "description": "Steps walked", "target": 10000}]', true, 24),
(uuid_generate_v4(), (SELECT id FROM quest_categories WHERE name = 'Fitness'), 'Strength Builder', 'Complete a 30-minute strength training session', 3, 30, 150, 
 '{"' || (SELECT id FROM skills WHERE name = 'Strength Training') || '": 75}', 
 '[{"id": "strength_training", "type": "duration", "description": "Strength training minutes", "target": 30}]', true, 48),
(uuid_generate_v4(), (SELECT id FROM quest_categories WHERE name = 'Fitness'), 'Flexibility Focus', 'Do 20 minutes of stretching or yoga', 1, 20, 75, 
 '{"' || (SELECT id FROM skills WHERE name = 'Gymnastics') || '": 50}', 
 '[{"id": "flexibility", "type": "duration", "description": "Stretching minutes", "target": 20}]', true, 24);

-- Learning Quests
INSERT INTO quest_templates (id, category_id, title, description, difficulty_level, estimated_duration, experience_reward, skill_experience_rewards, objectives, is_repeatable, cooldown_hours) VALUES
(uuid_generate_v4(), (SELECT id FROM quest_categories WHERE name = 'Learning'), 'Code Warrior', 'Write and test 100 lines of code', 4, 120, 200, 
 '{"' || (SELECT id FROM skills WHERE name = 'Programming') || '": 100}', 
 '[{"id": "lines_of_code", "type": "count", "description": "Lines of code written", "target": 100}]', true, 24),
(uuid_generate_v4(), (SELECT id FROM quest_categories WHERE name = 'Learning'), 'Book Worm', 'Read for 1 hour without interruption', 2, 60, 100, 
 '{"' || (SELECT id FROM skills WHERE name = 'History') || '": 50}', 
 '[{"id": "reading_time", "type": "duration", "description": "Reading minutes", "target": 60}]', true, 24),
(uuid_generate_v4(), (SELECT id FROM quest_categories WHERE name = 'Learning'), 'Math Mastery', 'Solve 50 math problems correctly', 3, 45, 125, 
 '{"' || (SELECT id FROM skills WHERE name = 'Mathematics') || '": 75}', 
 '[{"id": "math_problems", "type": "count", "description": "Math problems solved", "target": 50}]', true, 24);

-- =====================================================
-- ACHIEVEMENT CATEGORIES
-- =====================================================

INSERT INTO achievement_categories (id, name, description, icon, sort_order) VALUES
(uuid_generate_v4(), 'Milestones', 'Major progression achievements', 'trophy', 1),
(uuid_generate_v4(), 'Streaks', 'Consistency and habit achievements', 'flame', 2),
(uuid_generate_v4(), 'Mastery', 'Skill and expertise achievements', 'star', 3),
(uuid_generate_v4(), 'Social', 'Community and relationship achievements', 'person.2', 4),
(uuid_generate_v4(), 'Explorer', 'Discovery and adventure achievements', 'map', 5),
(uuid_generate_v4(), 'Collector', 'Gathering and completion achievements', 'square.grid.3x3', 6);

-- =====================================================
-- SAMPLE ACHIEVEMENTS
-- =====================================================

-- Milestone Achievements
INSERT INTO achievements (id, category_id, title, description, rarity, requirements, experience_reward, attribute_rewards) VALUES
(uuid_generate_v4(), (SELECT id FROM achievement_categories WHERE name = 'Milestones'), 'First Steps', 'Reach level 5', 'common', 
 '{"min_level": 5}', 100, '{"strength": 1}'),
(uuid_generate_v4(), (SELECT id FROM achievement_categories WHERE name = 'Milestones'), 'Apprentice', 'Reach level 10', 'common', 
 '{"min_level": 10}', 200, '{"intelligence": 1}'),
(uuid_generate_v4(), (SELECT id FROM achievement_categories WHERE name = 'Milestones'), 'Journeyman', 'Reach level 25', 'uncommon', 
 '{"min_level": 25}', 500, '{"wisdom": 1}'),
(uuid_generate_v4(), (SELECT id FROM achievement_categories WHERE name = 'Milestones'), 'Expert', 'Reach level 50', 'rare', 
 '{"min_level": 50}', 1000, '{"charisma": 1}'),
(uuid_generate_v4(), (SELECT id FROM achievement_categories WHERE name = 'Milestones'), 'Master', 'Reach level 75', 'epic', 
 '{"min_level": 75}', 2000, '{"constitution": 1}'),
(uuid_generate_v4(), (SELECT id FROM achievement_categories WHERE name = 'Milestones'), 'Grandmaster', 'Reach level 100', 'legendary', 
 '{"min_level": 100}', 5000, '{"dexterity": 1}');

-- Streak Achievements
INSERT INTO achievements (id, category_id, title, description, rarity, requirements, experience_reward, title_reward) VALUES
(uuid_generate_v4(), (SELECT id FROM achievement_categories WHERE name = 'Streaks'), 'Consistent', 'Maintain a 7-day streak on any habit', 'common', 
 '{"min_streak": 7}', 150, 'The Consistent'),
(uuid_generate_v4(), (SELECT id FROM achievement_categories WHERE name = 'Streaks'), 'Dedicated', 'Maintain a 30-day streak on any habit', 'uncommon', 
 '{"min_streak": 30}', 400, 'The Dedicated'),
(uuid_generate_v4(), (SELECT id FROM achievement_categories WHERE name = 'Streaks'), 'Unwavering', 'Maintain a 100-day streak on any habit', 'rare', 
 '{"min_streak": 100}', 1000, 'The Unwavering'),
(uuid_generate_v4(), (SELECT id FROM achievement_categories WHERE name = 'Streaks'), 'Legendary Persistence', 'Maintain a 365-day streak on any habit', 'legendary', 
 '{"min_streak": 365}', 5000, 'The Eternal');

-- =====================================================
-- METRIC CATEGORIES
-- =====================================================

INSERT INTO metric_categories (id, name, description, icon, color_code, sort_order) VALUES
(uuid_generate_v4(), 'Health', 'Physical and mental wellness metrics', 'heart', '#EF4444', 1),
(uuid_generate_v4(), 'Fitness', 'Exercise and activity measurements', 'figure.run', '#F97316', 2),
(uuid_generate_v4(), 'Productivity', 'Work and task completion metrics', 'checkmark.circle', '#10B981', 3),
(uuid_generate_v4(), 'Learning', 'Educational progress and knowledge gain', 'book', '#3B82F6', 4),
(uuid_generate_v4(), 'Social', 'Relationship and community engagement', 'person.2', '#8B5CF6', 5),
(uuid_generate_v4(), 'Creative', 'Artistic and creative output', 'paintbrush', '#F59E0B', 6),
(uuid_generate_v4(), 'Habits', 'Daily routines and consistency', 'calendar', '#6B7280', 7);

-- =====================================================
-- SAMPLE METRICS
-- =====================================================

-- Health Metrics
INSERT INTO metrics (id, category_id, name, description, unit, data_type, show_in_dashboard, chart_type) VALUES
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Health'), 'Sleep Hours', 'Hours of sleep per night', 'hours', 'decimal', true, 'line'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Health'), 'Water Intake', 'Glasses of water consumed daily', 'glasses', 'integer', true, 'bar'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Health'), 'Mood Rating', 'Daily mood on a scale of 1-10', 'rating', 'integer', true, 'line'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Health'), 'Stress Level', 'Daily stress level on a scale of 1-10', 'rating', 'integer', true, 'line');

-- Fitness Metrics
INSERT INTO metrics (id, category_id, name, description, unit, data_type, show_in_dashboard, chart_type) VALUES
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Fitness'), 'Steps', 'Daily step count', 'steps', 'integer', true, 'line'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Fitness'), 'Workout Duration', 'Minutes spent exercising', 'minutes', 'integer', true, 'bar'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Fitness'), 'Weight', 'Body weight tracking', 'lbs', 'decimal', true, 'line'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Fitness'), 'Calories Burned', 'Calories burned through exercise', 'calories', 'integer', true, 'bar');

-- Productivity Metrics
INSERT INTO metrics (id, category_id, name, description, unit, data_type, show_in_dashboard, chart_type) VALUES
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Productivity'), 'Tasks Completed', 'Number of tasks finished daily', 'tasks', 'integer', true, 'bar'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Productivity'), 'Focus Time', 'Minutes spent in deep focus', 'minutes', 'integer', true, 'line'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Productivity'), 'Pomodoros', 'Number of Pomodoro sessions completed', 'sessions', 'integer', true, 'bar'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Productivity'), 'Emails Processed', 'Emails handled and responded to', 'emails', 'integer', false, 'bar');

-- Learning Metrics
INSERT INTO metrics (id, category_id, name, description, unit, data_type, show_in_dashboard, chart_type) VALUES
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Learning'), 'Reading Time', 'Minutes spent reading', 'minutes', 'integer', true, 'line'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Learning'), 'Lines of Code', 'Lines of code written', 'lines', 'integer', true, 'bar'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Learning'), 'Courses Completed', 'Online courses or tutorials finished', 'courses', 'integer', true, 'bar'),
(uuid_generate_v4(), (SELECT id FROM metric_categories WHERE name = 'Learning'), 'Study Hours', 'Hours spent studying', 'hours', 'decimal', true, 'line');

-- =====================================================
-- ITEM CATEGORIES
-- =====================================================

INSERT INTO item_categories (id, name, description, icon, sort_order) VALUES
(uuid_generate_v4(), 'Consumables', 'Items that can be used once', 'pill', 1),
(uuid_generate_v4(), 'Equipment', 'Wearable items that provide bonuses', 'shield', 2),
(uuid_generate_v4(), 'Tools', 'Utility items for various tasks', 'wrench', 3),
(uuid_generate_v4(), 'Collectibles', 'Rare items for collection', 'gem', 4),
(uuid_generate_v4(), 'Materials', 'Crafting and upgrade components', 'cube', 5);

-- =====================================================
-- SAMPLE ITEMS
-- =====================================================

-- Consumables
INSERT INTO items (id, category_id, name, description, rarity, is_consumable, is_stackable, max_stack_size, use_effects, base_value) VALUES
(uuid_generate_v4(), (SELECT id FROM item_categories WHERE name = 'Consumables'), 'Health Potion', 'Restores 50 health points instantly', 'common', true, true, 10, 
 '{"restore_health": 50}', 25),
(uuid_generate_v4(), (SELECT id FROM item_categories WHERE name = 'Consumables'), 'Mana Potion', 'Restores 30 mana points instantly', 'common', true, true, 10, 
 '{"restore_mana": 30}', 20),
(uuid_generate_v4(), (SELECT id FROM item_categories WHERE name = 'Consumables'), 'Energy Drink', 'Provides +2 to all attributes for 1 hour', 'uncommon', true, true, 5, 
 '{"attribute_boost": {"all": 2}, "duration": 3600}', 50),
(uuid_generate_v4(), (SELECT id FROM item_categories WHERE name = 'Consumables'), 'Focus Pill', 'Doubles experience gain for 30 minutes', 'rare', true, true, 3, 
 '{"experience_multiplier": 2, "duration": 1800}', 100);

-- Equipment
INSERT INTO items (id, category_id, name, description, rarity, is_consumable, is_stackable, passive_effects, base_value) VALUES
(uuid_generate_v4(), (SELECT id FROM item_categories WHERE name = 'Equipment'), 'Iron Sword', 'A sturdy iron blade that increases combat effectiveness', 'common', false, false, 
 '{"attribute_bonus": {"strength": 3}}', 150),
(uuid_generate_v4(), (SELECT id FROM item_categories WHERE name = 'Equipment'), 'Wizard Hat', 'A pointed hat that enhances magical abilities', 'uncommon', false, false, 
 '{"attribute_bonus": {"intelligence": 5}}', 200),
(uuid_generate_v4(), (SELECT id FROM item_categories WHERE name = 'Equipment'), 'Leather Boots', 'Comfortable boots that improve agility', 'common', false, false, 
 '{"attribute_bonus": {"dexterity": 2}}', 75),
(uuid_generate_v4(), (SELECT id FROM item_categories WHERE name = 'Equipment'), 'Amulet of Wisdom', 'A mystical amulet that enhances perception', 'rare', false, false, 
 '{"attribute_bonus": {"wisdom": 7}}', 500);

-- Tools
INSERT INTO items (id, category_id, name, description, rarity, is_consumable, is_stackable, passive_effects, base_value) VALUES
(uuid_generate_v4(), (SELECT id FROM item_categories WHERE name = 'Tools'), 'Productivity Planner', 'Increases task completion efficiency by 10%', 'uncommon', false, false, 
 '{"productivity_bonus": 0.1}', 100),
(uuid_generate_v4(), (SELECT id FROM item_categories WHERE name = 'Tools'), 'Lucky Charm', 'Increases quest reward chances by 5%', 'rare', false, false, 
 '{"luck_bonus": 0.05}', 250),
(uuid_generate_v4(), (SELECT id FROM item_categories WHERE name = 'Tools'), 'Meditation Cushion', 'Increases wisdom skill experience by 25%', 'uncommon', false, false, 
 '{"skill_experience_bonus": {"wisdom": 0.25}}', 150);

-- =====================================================
-- SYSTEM SETTINGS
-- =====================================================

INSERT INTO system_settings (setting_key, setting_value, description, is_public) VALUES
('max_character_level', '100', 'Maximum level a character can reach', true),
('daily_quest_limit', '10', 'Maximum number of daily quests per character', true),
('friend_limit', '100', 'Maximum number of friends per user', true),
('experience_multiplier', '1.0', 'Global experience point multiplier', false),
('maintenance_mode', 'false', 'Whether the system is in maintenance mode', true),
('welcome_message', '"Welcome to Dual RPG! Your real life adventure begins now."', 'Message shown to new users', true),
('latest_version', '"1.0.0"', 'Current version of the application', true);

-- Insert migration record
INSERT INTO schema_migrations (version) VALUES ('005_sample_data');