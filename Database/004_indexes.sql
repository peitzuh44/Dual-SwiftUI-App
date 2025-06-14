-- Dual RPG Engine Database Schema
-- Migration 004: Performance Indexes

-- =====================================================
-- PRIMARY LOOKUP INDEXES
-- =====================================================

-- Profile lookups
CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_profiles_display_name ON profiles(display_name) WHERE display_name IS NOT NULL;
CREATE INDEX idx_profiles_last_active ON profiles(last_active_at DESC);
CREATE INDEX idx_profiles_public ON profiles(id) WHERE is_public = true;

-- User preferences lookups
CREATE INDEX idx_user_preferences_key ON user_preferences(user_id, preference_key);

-- =====================================================
-- CHARACTER SYSTEM INDEXES
-- =====================================================

-- Character lookups
CREATE INDEX idx_characters_user_id ON characters(user_id);
CREATE INDEX idx_characters_class_id ON characters(class_id);
CREATE INDEX idx_characters_level ON characters(level DESC);
CREATE INDEX idx_characters_active ON characters(user_id) WHERE is_active = true;
CREATE INDEX idx_characters_alive ON characters(id) WHERE is_alive = true;
CREATE INDEX idx_characters_name_search ON characters USING gin(name gin_trgm_ops);

-- Character classes
CREATE INDEX idx_character_classes_starter ON character_classes(id) WHERE is_starter_class = true;
CREATE INDEX idx_character_classes_sort ON character_classes(sort_order, name);

-- =====================================================
-- SKILLS SYSTEM INDEXES
-- =====================================================

-- Skill categories
CREATE INDEX idx_skill_categories_sort ON skill_categories(sort_order, name);

-- Skills
CREATE INDEX idx_skills_category ON skills(category_id);
CREATE INDEX idx_skills_active ON skills(id) WHERE is_active = true;
CREATE INDEX idx_skills_sort ON skills(category_id, sort_order, name);
CREATE INDEX idx_skills_name_search ON skills USING gin(name gin_trgm_ops);

-- Character skills
CREATE INDEX idx_character_skills_character ON character_skills(character_id);
CREATE INDEX idx_character_skills_skill ON character_skills(skill_id);
CREATE INDEX idx_character_skills_level ON character_skills(character_id, current_level DESC);
CREATE INDEX idx_character_skills_recent ON character_skills(character_id, last_used_at DESC NULLS LAST);
CREATE INDEX idx_character_skills_unlocked ON character_skills(character_id, unlocked_at DESC);

-- =====================================================
-- QUEST SYSTEM INDEXES
-- =====================================================

-- Quest categories
CREATE INDEX idx_quest_categories_sort ON quest_categories(sort_order, name);

-- Quest templates
CREATE INDEX idx_quest_templates_category ON quest_templates(category_id);
CREATE INDEX idx_quest_templates_active ON quest_templates(id) WHERE is_active = true;
CREATE INDEX idx_quest_templates_difficulty ON quest_templates(difficulty_level);
CREATE INDEX idx_quest_templates_level_req ON quest_templates(level_requirement);
CREATE INDEX idx_quest_templates_repeatable ON quest_templates(id) WHERE is_repeatable = true;
CREATE INDEX idx_quest_templates_search ON quest_templates USING gin(title gin_trgm_ops);

-- Character quests
CREATE INDEX idx_character_quests_character ON character_quests(character_id);
CREATE INDEX idx_character_quests_template ON character_quests(template_id);
CREATE INDEX idx_character_quests_status ON character_quests(character_id, status);
CREATE INDEX idx_character_quests_active ON character_quests(character_id) WHERE status = 'active';
CREATE INDEX idx_character_quests_completed ON character_quests(character_id, completed_at DESC) WHERE status = 'completed';
CREATE INDEX idx_character_quests_deadline ON character_quests(deadline_at) WHERE deadline_at IS NOT NULL AND status = 'active';
CREATE INDEX idx_character_quests_available ON character_quests(character_id, next_available_at) WHERE next_available_at IS NOT NULL;

-- =====================================================
-- ACHIEVEMENT SYSTEM INDEXES
-- =====================================================

-- Achievement categories
CREATE INDEX idx_achievement_categories_sort ON achievement_categories(sort_order, name);

-- Achievements
CREATE INDEX idx_achievements_category ON achievements(category_id);
CREATE INDEX idx_achievements_active ON achievements(id) WHERE is_active = true;
CREATE INDEX idx_achievements_rarity ON achievements(rarity, title);
CREATE INDEX idx_achievements_order ON achievements(unlock_order) WHERE unlock_order IS NOT NULL;
CREATE INDEX idx_achievements_hidden ON achievements(id) WHERE hidden_until_unlocked = false;

-- Character achievements
CREATE INDEX idx_character_achievements_character ON character_achievements(character_id);
CREATE INDEX idx_character_achievements_achievement ON character_achievements(achievement_id);
CREATE INDEX idx_character_achievements_unlocked ON character_achievements(character_id, unlocked_at DESC) WHERE is_unlocked = true;
CREATE INDEX idx_character_achievements_equipped ON character_achievements(character_id) WHERE is_equipped = true;
CREATE INDEX idx_character_achievements_progress ON character_achievements(character_id) WHERE is_unlocked = false;

-- =====================================================
-- METRICS SYSTEM INDEXES
-- =====================================================

-- Metric categories
CREATE INDEX idx_metric_categories_sort ON metric_categories(sort_order, name);

-- Metrics
CREATE INDEX idx_metrics_category ON metrics(category_id);
CREATE INDEX idx_metrics_active ON metrics(id) WHERE is_active = true;
CREATE INDEX idx_metrics_dashboard ON metrics(id) WHERE show_in_dashboard = true;
CREATE INDEX idx_metrics_type ON metrics(data_type);
CREATE INDEX idx_metrics_cumulative ON metrics(id) WHERE is_cumulative = true;

-- Character metrics
CREATE INDEX idx_character_metrics_character ON character_metrics(character_id);
CREATE INDEX idx_character_metrics_metric ON character_metrics(metric_id);
CREATE INDEX idx_character_metrics_updated ON character_metrics(character_id, last_updated_at DESC);
CREATE INDEX idx_character_metrics_best ON character_metrics(metric_id, best_value DESC NULLS LAST);
CREATE INDEX idx_character_metrics_streak ON character_metrics(character_id, current_streak DESC);
CREATE INDEX idx_character_metrics_longest_streak ON character_metrics(metric_id, longest_streak DESC);

-- Metric entries
CREATE INDEX idx_metric_entries_character_metric ON metric_entries(character_metric_id);
CREATE INDEX idx_metric_entries_recorded ON metric_entries(character_metric_id, recorded_at DESC);
CREATE INDEX idx_metric_entries_value ON metric_entries(character_metric_id, value DESC);
CREATE INDEX idx_metric_entries_recent ON metric_entries(recorded_at DESC);
CREATE INDEX idx_metric_entries_source ON metric_entries(source) WHERE source IS NOT NULL;

-- Time-based partitioning support (for large metric datasets)
CREATE INDEX idx_metric_entries_daily ON metric_entries(date_trunc('day', recorded_at), character_metric_id);
CREATE INDEX idx_metric_entries_weekly ON metric_entries(date_trunc('week', recorded_at), character_metric_id);
CREATE INDEX idx_metric_entries_monthly ON metric_entries(date_trunc('month', recorded_at), character_metric_id);

-- =====================================================
-- INVENTORY SYSTEM INDEXES
-- =====================================================

-- Item categories
CREATE INDEX idx_item_categories_sort ON item_categories(sort_order, name);

-- Items
CREATE INDEX idx_items_category ON items(category_id);
CREATE INDEX idx_items_active ON items(id) WHERE is_active = true;
CREATE INDEX idx_items_rarity ON items(rarity, name);
CREATE INDEX idx_items_consumable ON items(id) WHERE is_consumable = true;
CREATE INDEX idx_items_tradeable ON items(id) WHERE is_tradeable = true;
CREATE INDEX idx_items_value ON items(base_value DESC);
CREATE INDEX idx_items_search ON items USING gin(name gin_trgm_ops);

-- Character inventory
CREATE INDEX idx_character_inventory_character ON character_inventory(character_id);
CREATE INDEX idx_character_inventory_item ON character_inventory(item_id);
CREATE INDEX idx_character_inventory_quantity ON character_inventory(character_id, quantity DESC);
CREATE INDEX idx_character_inventory_acquired ON character_inventory(character_id, acquired_at DESC);
CREATE INDEX idx_character_inventory_used ON character_inventory(character_id, last_used_at DESC NULLS LAST);

-- =====================================================
-- SOCIAL FEATURES INDEXES
-- =====================================================

-- Friendships
CREATE INDEX idx_friendships_requester ON friendships(requester_id);
CREATE INDEX idx_friendships_recipient ON friendships(recipient_id);
CREATE INDEX idx_friendships_status ON friendships(status);
CREATE INDEX idx_friendships_pending ON friendships(recipient_id) WHERE status = 'pending';
CREATE INDEX idx_friendships_accepted ON friendships(requester_id, recipient_id) WHERE status = 'accepted';
CREATE INDEX idx_friendships_requested ON friendships(requested_at DESC);

-- Activity feed
CREATE INDEX idx_activity_feed_user ON activity_feed(user_id);
CREATE INDEX idx_activity_feed_type ON activity_feed(activity_type);
CREATE INDEX idx_activity_feed_created ON activity_feed(created_at DESC);
CREATE INDEX idx_activity_feed_public ON activity_feed(created_at DESC) WHERE is_public = true;
CREATE INDEX idx_activity_feed_friends ON activity_feed(user_id, created_at DESC) WHERE friend_visibility = true;

-- =====================================================
-- SYSTEM INDEXES
-- =====================================================

-- System settings
CREATE INDEX idx_system_settings_key ON system_settings(setting_key);
CREATE INDEX idx_system_settings_public ON system_settings(setting_key) WHERE is_public = true;

-- Audit log
CREATE INDEX idx_audit_log_user ON audit_log(user_id);
CREATE INDEX idx_audit_log_action ON audit_log(action);
CREATE INDEX idx_audit_log_table ON audit_log(table_name);
CREATE INDEX idx_audit_log_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_created ON audit_log(created_at DESC);

-- =====================================================
-- COMPOSITE INDEXES FOR COMMON QUERIES
-- =====================================================

-- Character dashboard queries
CREATE INDEX idx_character_dashboard ON characters(user_id, is_active, level DESC, experience_points DESC);

-- Active character with skills
CREATE INDEX idx_active_character_skills ON character_skills(character_id, current_level DESC, experience_points DESC);

-- Quest progress tracking
CREATE INDEX idx_quest_progress ON character_quests(character_id, status, completion_percentage DESC, updated_at DESC);

-- Recent activity for user
CREATE INDEX idx_user_recent_activity ON activity_feed(user_id, created_at DESC) WHERE is_public = true OR friend_visibility = true;

-- Leaderboard queries
CREATE INDEX idx_character_leaderboard_level ON characters(level DESC, experience_points DESC) WHERE is_alive = true;
CREATE INDEX idx_skill_leaderboard ON character_skills(skill_id, current_level DESC, experience_points DESC);
CREATE INDEX idx_metric_leaderboard ON character_metrics(metric_id, best_value DESC) WHERE best_value IS NOT NULL;

-- Friend character data
CREATE INDEX idx_friend_characters ON characters(user_id, is_active) WHERE is_alive = true;

-- Achievement progress
CREATE INDEX idx_achievement_progress ON character_achievements(character_id, is_unlocked, unlocked_at DESC);

-- Recent metric entries for charts
CREATE INDEX idx_recent_metrics ON metric_entries(character_metric_id, recorded_at DESC) WHERE recorded_at >= NOW() - INTERVAL '30 days';

-- =====================================================
-- PARTIAL INDEXES FOR EFFICIENCY
-- =====================================================

-- Only index active/relevant records
CREATE INDEX idx_active_quests_only ON character_quests(character_id, updated_at DESC) WHERE status IN ('active', 'completed');
CREATE INDEX idx_living_characters_only ON characters(user_id, level DESC) WHERE is_alive = true AND is_active = true;
CREATE INDEX idx_public_profiles_only ON profiles(display_name, last_active_at DESC) WHERE is_public = true;
CREATE INDEX idx_unlocked_achievements_only ON character_achievements(character_id, unlocked_at DESC) WHERE is_unlocked = true;

-- Recent data only (for performance on large tables)
CREATE INDEX idx_recent_activity_only ON activity_feed(user_id, created_at DESC) WHERE created_at >= NOW() - INTERVAL '90 days';
CREATE INDEX idx_recent_metrics_only ON metric_entries(character_metric_id, recorded_at DESC) WHERE recorded_at >= NOW() - INTERVAL '365 days';

-- =====================================================
-- STATISTICS UPDATE
-- =====================================================

-- Update table statistics for query planner
ANALYZE profiles;
ANALYZE characters;
ANALYZE character_skills;
ANALYZE character_quests;
ANALYZE character_achievements;
ANALYZE character_metrics;
ANALYZE metric_entries;
ANALYZE character_inventory;
ANALYZE friendships;
ANALYZE activity_feed;

-- Insert migration record
INSERT INTO schema_migrations (version) VALUES ('004_indexes');