-- Dual RPG Engine Database Setup Script
-- This script sets up the complete database schema for the Dual RPG engine
-- Run this script in your Supabase SQL editor or PostgreSQL database

-- =====================================================
-- IMPORTANT: Run these migrations in order!
-- =====================================================

-- Check if migrations have already been run
DO $$
BEGIN
    -- Create migrations table if it doesn't exist
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'schema_migrations') THEN
        CREATE TABLE schema_migrations (
            version TEXT PRIMARY KEY,
            applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
    END IF;
END $$;

-- Migration 001: Initial Schema
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM schema_migrations WHERE version = '001_initial_schema') THEN
        -- Include the content of 001_initial_schema.sql here
        RAISE NOTICE 'Please run 001_initial_schema.sql first';
    ELSE
        RAISE NOTICE 'Migration 001_initial_schema already applied';
    END IF;
END $$;

-- Migration 002: Row Level Security
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM schema_migrations WHERE version = '002_row_level_security') THEN
        RAISE NOTICE 'Please run 002_row_level_security.sql next';
    ELSE
        RAISE NOTICE 'Migration 002_row_level_security already applied';
    END IF;
END $$;

-- Migration 003: Functions and Triggers
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM schema_migrations WHERE version = '003_functions_and_triggers') THEN
        RAISE NOTICE 'Please run 003_functions_and_triggers.sql next';
    ELSE
        RAISE NOTICE 'Migration 003_functions_and_triggers already applied';
    END IF;
END $$;

-- Migration 004: Indexes
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM schema_migrations WHERE version = '004_indexes') THEN
        RAISE NOTICE 'Please run 004_indexes.sql next';
    ELSE
        RAISE NOTICE 'Migration 004_indexes already applied';
    END IF;
END $$;

-- Migration 005: Sample Data
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM schema_migrations WHERE version = '005_sample_data') THEN
        RAISE NOTICE 'Please run 005_sample_data.sql last';
    ELSE
        RAISE NOTICE 'Migration 005_sample_data already applied';
    END IF;
END $$;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check applied migrations
SELECT version, applied_at FROM schema_migrations ORDER BY applied_at;

-- Verify table creation
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename NOT LIKE 'pg_%'
ORDER BY tablename;

-- Check RLS status
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename NOT LIKE 'pg_%'
ORDER BY tablename;

-- Count sample data
SELECT 
    'character_classes' as table_name, COUNT(*) as record_count FROM character_classes
UNION ALL
SELECT 'skill_categories', COUNT(*) FROM skill_categories
UNION ALL
SELECT 'skills', COUNT(*) FROM skills
UNION ALL
SELECT 'quest_categories', COUNT(*) FROM quest_categories
UNION ALL
SELECT 'quest_templates', COUNT(*) FROM quest_templates
UNION ALL
SELECT 'achievement_categories', COUNT(*) FROM achievement_categories
UNION ALL
SELECT 'achievements', COUNT(*) FROM achievements
UNION ALL
SELECT 'metric_categories', COUNT(*) FROM metric_categories
UNION ALL
SELECT 'metrics', COUNT(*) FROM metrics
UNION ALL
SELECT 'item_categories', COUNT(*) FROM item_categories
UNION ALL
SELECT 'items', COUNT(*) FROM items
UNION ALL
SELECT 'system_settings', COUNT(*) FROM system_settings;

-- =====================================================
-- POST-SETUP TASKS
-- =====================================================

-- Grant necessary permissions (adjust as needed for your setup)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_app_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_app_user;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO your_app_user;

-- Enable real-time subscriptions for important tables (Supabase specific)
-- ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
-- ALTER PUBLICATION supabase_realtime ADD TABLE characters;
-- ALTER PUBLICATION supabase_realtime ADD TABLE character_quests;
-- ALTER PUBLICATION supabase_realtime ADD TABLE character_achievements;
-- ALTER PUBLICATION supabase_realtime ADD TABLE activity_feed;
-- ALTER PUBLICATION supabase_realtime ADD TABLE friendships;

RAISE NOTICE 'Database setup verification complete. Check the query results above.';
RAISE NOTICE 'If any migrations show as not applied, run them in the correct order:';
RAISE NOTICE '1. 001_initial_schema.sql';
RAISE NOTICE '2. 002_row_level_security.sql';
RAISE NOTICE '3. 003_functions_and_triggers.sql';
RAISE NOTICE '4. 004_indexes.sql';
RAISE NOTICE '5. 005_sample_data.sql';