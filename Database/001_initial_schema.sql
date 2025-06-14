-- Dual RPG Engine Database Schema
-- Migration 001: Initial Schema Setup

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =====================================================
-- CORE USER SYSTEM
-- =====================================================

-- Users table (extends Supabase auth.users)
CREATE TABLE profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    timezone TEXT DEFAULT 'UTC',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Privacy settings
    is_public BOOLEAN DEFAULT TRUE,
    allow_friend_requests BOOLEAN DEFAULT TRUE,
    
    -- Onboarding
    onboarding_completed BOOLEAN DEFAULT FALSE,
    tutorial_completed BOOLEAN DEFAULT FALSE
);

-- User preferences
CREATE TABLE user_preferences (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    preference_key TEXT NOT NULL,
    preference_value JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, preference_key)
);

-- =====================================================
-- CHARACTER SYSTEM
-- =====================================================

-- Character classes/archetypes
CREATE TABLE character_classes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    base_attributes JSONB NOT NULL DEFAULT '{}', -- Starting attribute bonuses
    skill_affinities JSONB NOT NULL DEFAULT '[]', -- Skills this class excels at
    unlock_requirements JSONB DEFAULT '{}', -- Requirements to unlock this class
    is_starter_class BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User characters (RPG avatar)
CREATE TABLE characters (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    class_id UUID REFERENCES character_classes(id) NOT NULL,
    name TEXT NOT NULL,
    level INTEGER DEFAULT 1 CHECK (level >= 1 AND level <= 100),
    experience_points BIGINT DEFAULT 0 CHECK (experience_points >= 0),
    
    -- Core attributes
    strength INTEGER DEFAULT 10 CHECK (strength >= 1 AND strength <= 100),
    intelligence INTEGER DEFAULT 10 CHECK (intelligence >= 1 AND intelligence <= 100),
    wisdom INTEGER DEFAULT 10 CHECK (wisdom >= 1 AND wisdom <= 100),
    charisma INTEGER DEFAULT 10 CHECK (charisma >= 1 AND charisma <= 100),
    constitution INTEGER DEFAULT 10 CHECK (constitution >= 1 AND constitution <= 100),
    dexterity INTEGER DEFAULT 10 CHECK (dexterity >= 1 AND dexterity <= 100),
    
    -- Derived stats
    health_points INTEGER DEFAULT 100 CHECK (health_points >= 0),
    max_health_points INTEGER DEFAULT 100 CHECK (max_health_points > 0),
    mana_points INTEGER DEFAULT 50 CHECK (mana_points >= 0),
    max_mana_points INTEGER DEFAULT 50 CHECK (max_mana_points >= 0),
    
    -- Character status
    is_active BOOLEAN DEFAULT TRUE,
    is_alive BOOLEAN DEFAULT TRUE,
    last_death_at TIMESTAMP WITH TIME ZONE,
    respawn_available_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- One active character per user
    UNIQUE(user_id) WHERE is_active = TRUE
);

-- =====================================================
-- SKILLS SYSTEM
-- =====================================================

-- Skill categories
CREATE TABLE skill_categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    icon TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Available skills
CREATE TABLE skills (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    category_id UUID REFERENCES skill_categories(id) NOT NULL,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    max_level INTEGER DEFAULT 100 CHECK (max_level > 0),
    base_experience_cost INTEGER DEFAULT 100 CHECK (base_experience_cost > 0),
    experience_scaling_factor DECIMAL(3,2) DEFAULT 1.5,
    
    -- Skill requirements
    prerequisites JSONB DEFAULT '[]', -- Array of required skill IDs and levels
    attribute_requirements JSONB DEFAULT '{}', -- Minimum attribute requirements
    
    -- Skill effects and bonuses
    passive_effects JSONB DEFAULT '{}',
    active_abilities JSONB DEFAULT '[]',
    
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Character skills (user's skill progress)
CREATE TABLE character_skills (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    character_id UUID REFERENCES characters(id) ON DELETE CASCADE NOT NULL,
    skill_id UUID REFERENCES skills(id) NOT NULL,
    current_level INTEGER DEFAULT 0 CHECK (current_level >= 0),
    experience_points BIGINT DEFAULT 0 CHECK (experience_points >= 0),
    mastery_bonus DECIMAL(5,2) DEFAULT 0.0, -- Additional effectiveness
    last_used_at TIMESTAMP WITH TIME ZONE,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(character_id, skill_id)
);

-- =====================================================
-- QUEST AND ADVENTURE SYSTEM
-- =====================================================

-- Quest categories
CREATE TABLE quest_categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    color_code TEXT DEFAULT '#3B82F6',
    icon TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quest templates (reusable quest definitions)
CREATE TABLE quest_templates (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    category_id UUID REFERENCES quest_categories(id) NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level >= 1 AND difficulty_level <= 10),
    estimated_duration INTEGER, -- in minutes
    
    -- Requirements
    level_requirement INTEGER DEFAULT 1,
    skill_requirements JSONB DEFAULT '{}',
    prerequisite_quests JSONB DEFAULT '[]',
    
    -- Rewards
    experience_reward INTEGER DEFAULT 0,
    skill_experience_rewards JSONB DEFAULT '{}', -- Skill-specific XP
    attribute_rewards JSONB DEFAULT '{}',
    item_rewards JSONB DEFAULT '[]',
    
    -- Quest mechanics
    objectives JSONB NOT NULL DEFAULT '[]', -- Array of objective definitions
    auto_complete BOOLEAN DEFAULT FALSE,
    is_repeatable BOOLEAN DEFAULT FALSE,
    cooldown_hours INTEGER DEFAULT 0,
    
    -- Availability
    is_active BOOLEAN DEFAULT TRUE,
    availability_conditions JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User quest instances
CREATE TABLE character_quests (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    character_id UUID REFERENCES characters(id) ON DELETE CASCADE NOT NULL,
    template_id UUID REFERENCES quest_templates(id) NOT NULL,
    
    -- Quest state
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'failed', 'abandoned')),
    progress JSONB DEFAULT '{}', -- Tracks objective completion
    completion_percentage INTEGER DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    
    -- Timing
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    deadline_at TIMESTAMP WITH TIME ZONE,
    next_available_at TIMESTAMP WITH TIME ZONE, -- For repeatable quests
    
    -- Dynamic quest data
    custom_objectives JSONB DEFAULT '[]', -- Quest-specific modifications
    bonus_multipliers JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- MILESTONE AND ACHIEVEMENT SYSTEM
-- =====================================================

-- Achievement categories
CREATE TABLE achievement_categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    icon TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Achievement definitions
CREATE TABLE achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    category_id UUID REFERENCES achievement_categories(id) NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    rarity TEXT DEFAULT 'common' CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')),
    
    -- Requirements
    requirements JSONB NOT NULL DEFAULT '{}', -- Conditions to unlock
    hidden_until_unlocked BOOLEAN DEFAULT FALSE,
    
    -- Rewards
    experience_reward INTEGER DEFAULT 0,
    attribute_rewards JSONB DEFAULT '{}',
    title_reward TEXT, -- Special title for character
    badge_icon TEXT,
    
    -- Achievement metadata
    is_active BOOLEAN DEFAULT TRUE,
    unlock_order INTEGER, -- For sequential achievements
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User achievement progress
CREATE TABLE character_achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    character_id UUID REFERENCES characters(id) ON DELETE CASCADE NOT NULL,
    achievement_id UUID REFERENCES achievements(id) NOT NULL,
    
    progress_data JSONB DEFAULT '{}', -- Tracks progress toward requirements
    is_unlocked BOOLEAN DEFAULT FALSE,
    unlocked_at TIMESTAMP WITH TIME ZONE,
    is_equipped BOOLEAN DEFAULT FALSE, -- For titles/badges
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(character_id, achievement_id)
);

-- =====================================================
-- METRICS AND TRACKING SYSTEM
-- =====================================================

-- Metric categories for organization
CREATE TABLE metric_categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    icon TEXT,
    color_code TEXT DEFAULT '#6B7280',
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Metric definitions (what can be tracked)
CREATE TABLE metrics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    category_id UUID REFERENCES metric_categories(id) NOT NULL,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    unit TEXT, -- e.g., "minutes", "count", "points"
    data_type TEXT DEFAULT 'integer' CHECK (data_type IN ('integer', 'decimal', 'boolean', 'text', 'duration')),
    
    -- Display settings
    is_cumulative BOOLEAN DEFAULT TRUE, -- Whether values add up over time
    show_in_dashboard BOOLEAN DEFAULT TRUE,
    chart_type TEXT DEFAULT 'line' CHECK (chart_type IN ('line', 'bar', 'pie', 'gauge')),
    
    -- Validation
    min_value DECIMAL,
    max_value DECIMAL,
    allowed_values JSONB, -- For constrained values
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User metric tracking
CREATE TABLE character_metrics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    character_id UUID REFERENCES characters(id) ON DELETE CASCADE NOT NULL,
    metric_id UUID REFERENCES metrics(id) NOT NULL,
    
    -- Current values
    current_value DECIMAL DEFAULT 0,
    total_value DECIMAL DEFAULT 0, -- All-time total
    best_value DECIMAL, -- Personal best
    
    -- Streak tracking
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_streak_date DATE,
    
    -- Timing
    last_updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    first_recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(character_id, metric_id)
);

-- Detailed metric entries (history)
CREATE TABLE metric_entries (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    character_metric_id UUID REFERENCES character_metrics(id) ON DELETE CASCADE NOT NULL,
    value DECIMAL NOT NULL,
    delta DECIMAL, -- Change from previous value
    notes TEXT,
    source TEXT, -- How this entry was created (manual, quest, etc.)
    metadata JSONB DEFAULT '{}',
    
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- REWARDS AND INVENTORY SYSTEM
-- =====================================================

-- Item categories
CREATE TABLE item_categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    icon TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Item definitions
CREATE TABLE items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    category_id UUID REFERENCES item_categories(id) NOT NULL,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    rarity TEXT DEFAULT 'common' CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')),
    
    -- Item properties
    is_consumable BOOLEAN DEFAULT FALSE,
    is_stackable BOOLEAN DEFAULT TRUE,
    max_stack_size INTEGER DEFAULT 1,
    
    -- Effects when used
    use_effects JSONB DEFAULT '{}',
    passive_effects JSONB DEFAULT '{}',
    
    -- Market data
    base_value INTEGER DEFAULT 0,
    is_tradeable BOOLEAN DEFAULT TRUE,
    
    -- Availability
    is_active BOOLEAN DEFAULT TRUE,
    drop_sources JSONB DEFAULT '[]', -- Where this item can be obtained
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User inventory
CREATE TABLE character_inventory (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    character_id UUID REFERENCES characters(id) ON DELETE CASCADE NOT NULL,
    item_id UUID REFERENCES items(id) NOT NULL,
    quantity INTEGER DEFAULT 1 CHECK (quantity > 0),
    
    -- Item instance data
    acquired_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_used_at TIMESTAMP WITH TIME ZONE,
    custom_properties JSONB DEFAULT '{}', -- For unique item instances
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(character_id, item_id)
);

-- =====================================================
-- SOCIAL FEATURES
-- =====================================================

-- Friend relationships
CREATE TABLE friendships (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    requester_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    recipient_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked')),
    
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    responded_at TIMESTAMP WITH TIME ZONE,
    
    CHECK (requester_id != recipient_id),
    UNIQUE(requester_id, recipient_id)
);

-- Activity feed for social features
CREATE TABLE activity_feed (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    activity_type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    metadata JSONB DEFAULT '{}',
    
    -- Visibility
    is_public BOOLEAN DEFAULT TRUE,
    friend_visibility BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- SYSTEM TABLES
-- =====================================================

-- App-wide settings and configuration
CREATE TABLE system_settings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    setting_key TEXT UNIQUE NOT NULL,
    setting_value JSONB NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE, -- Can clients read this setting?
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit log for important actions
CREATE TABLE audit_log (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    table_name TEXT,
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Database schema version tracking
CREATE TABLE schema_migrations (
    version TEXT PRIMARY KEY,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert initial migration record
INSERT INTO schema_migrations (version) VALUES ('001_initial_schema');