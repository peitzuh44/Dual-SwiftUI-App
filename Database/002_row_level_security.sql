-- Dual RPG Engine Database Schema
-- Migration 002: Row Level Security (RLS) Policies

-- =====================================================
-- ENABLE RLS ON ALL TABLES
-- =====================================================

-- User and character data
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE characters ENABLE ROW LEVEL SECURITY;
ALTER TABLE character_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE character_quests ENABLE ROW LEVEL SECURITY;
ALTER TABLE character_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE character_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE metric_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE character_inventory ENABLE ROW LEVEL SECURITY;

-- Social features
ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_feed ENABLE ROW LEVEL SECURITY;

-- System tables (admin only)
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- HELPER FUNCTIONS FOR RLS
-- =====================================================

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    SELECT COALESCE(
      (SELECT true FROM profiles WHERE id = auth.uid() AND id IN (
        SELECT user_id FROM user_preferences 
        WHERE preference_key = 'is_admin' 
        AND preference_value = 'true'::jsonb
      )), 
      false
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if users are friends
CREATE OR REPLACE FUNCTION are_friends(user1_id UUID, user2_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM friendships 
    WHERE ((requester_id = user1_id AND recipient_id = user2_id) 
           OR (requester_id = user2_id AND recipient_id = user1_id))
    AND status = 'accepted'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user's character ID
CREATE OR REPLACE FUNCTION get_user_character_id(user_id UUID)
RETURNS UUID AS $$
BEGIN
  RETURN (
    SELECT id FROM characters 
    WHERE characters.user_id = get_user_character_id.user_id 
    AND is_active = true 
    LIMIT 1
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- PROFILES TABLE POLICIES
-- =====================================================

-- Users can view their own profile and public profiles
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can view public profiles" ON profiles
  FOR SELECT USING (is_public = true);

-- Users can view friend profiles
CREATE POLICY "Users can view friend profiles" ON profiles
  FOR SELECT USING (are_friends(auth.uid(), id));

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile (triggered by auth signup)
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- =====================================================
-- USER PREFERENCES POLICIES
-- =====================================================

-- Users can manage their own preferences
CREATE POLICY "Users can manage own preferences" ON user_preferences
  FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- CHARACTERS TABLE POLICIES
-- =====================================================

-- Users can view their own characters
CREATE POLICY "Users can view own characters" ON characters
  FOR SELECT USING (auth.uid() = user_id);

-- Users can view public characters
CREATE POLICY "Users can view public characters" ON characters
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = characters.user_id 
      AND profiles.is_public = true
    )
  );

-- Users can view friend characters
CREATE POLICY "Users can view friend characters" ON characters
  FOR SELECT USING (are_friends(auth.uid(), user_id));

-- Users can update their own characters
CREATE POLICY "Users can update own characters" ON characters
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can create their own characters
CREATE POLICY "Users can create own characters" ON characters
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can delete their own characters
CREATE POLICY "Users can delete own characters" ON characters
  FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- CHARACTER SKILLS POLICIES
-- =====================================================

-- Users can manage skills for their own characters
CREATE POLICY "Users can manage own character skills" ON character_skills
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM characters 
      WHERE characters.id = character_skills.character_id 
      AND characters.user_id = auth.uid()
    )
  );

-- Users can view skills of public characters
CREATE POLICY "Users can view public character skills" ON character_skills
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM characters 
      JOIN profiles ON profiles.id = characters.user_id
      WHERE characters.id = character_skills.character_id 
      AND profiles.is_public = true
    )
  );

-- Users can view skills of friend characters
CREATE POLICY "Users can view friend character skills" ON character_skills
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM characters 
      WHERE characters.id = character_skills.character_id 
      AND are_friends(auth.uid(), characters.user_id)
    )
  );

-- =====================================================
-- CHARACTER QUESTS POLICIES
-- =====================================================

-- Users can manage quests for their own characters
CREATE POLICY "Users can manage own character quests" ON character_quests
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM characters 
      WHERE characters.id = character_quests.character_id 
      AND characters.user_id = auth.uid()
    )
  );

-- =====================================================
-- CHARACTER ACHIEVEMENTS POLICIES
-- =====================================================

-- Users can manage achievements for their own characters
CREATE POLICY "Users can manage own character achievements" ON character_achievements
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM characters 
      WHERE characters.id = character_achievements.character_id 
      AND characters.user_id = auth.uid()
    )
  );

-- Users can view achievements of public characters
CREATE POLICY "Users can view public character achievements" ON character_achievements
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM characters 
      JOIN profiles ON profiles.id = characters.user_id
      WHERE characters.id = character_achievements.character_id 
      AND profiles.is_public = true
    )
  );

-- Users can view achievements of friend characters
CREATE POLICY "Users can view friend character achievements" ON character_achievements
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM characters 
      WHERE characters.id = character_achievements.character_id 
      AND are_friends(auth.uid(), characters.user_id)
    )
  );

-- =====================================================
-- CHARACTER METRICS POLICIES
-- =====================================================

-- Users can manage metrics for their own characters
CREATE POLICY "Users can manage own character metrics" ON character_metrics
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM characters 
      WHERE characters.id = character_metrics.character_id 
      AND characters.user_id = auth.uid()
    )
  );

-- Users can view public character metrics (if metric is dashboard visible)
CREATE POLICY "Users can view public character metrics" ON character_metrics
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM characters 
      JOIN profiles ON profiles.id = characters.user_id
      JOIN metrics ON metrics.id = character_metrics.metric_id
      WHERE characters.id = character_metrics.character_id 
      AND profiles.is_public = true
      AND metrics.show_in_dashboard = true
    )
  );

-- Users can view friend character metrics
CREATE POLICY "Users can view friend character metrics" ON character_metrics
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM characters 
      JOIN metrics ON metrics.id = character_metrics.metric_id
      WHERE characters.id = character_metrics.character_id 
      AND are_friends(auth.uid(), characters.user_id)
      AND metrics.show_in_dashboard = true
    )
  );

-- =====================================================
-- METRIC ENTRIES POLICIES
-- =====================================================

-- Users can manage metric entries for their own characters
CREATE POLICY "Users can manage own metric entries" ON metric_entries
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM character_metrics
      JOIN characters ON characters.id = character_metrics.character_id
      WHERE character_metrics.id = metric_entries.character_metric_id
      AND characters.user_id = auth.uid()
    )
  );

-- Users can view metric entries for public characters
CREATE POLICY "Users can view public metric entries" ON metric_entries
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM character_metrics
      JOIN characters ON characters.id = character_metrics.character_id
      JOIN profiles ON profiles.id = characters.user_id
      JOIN metrics ON metrics.id = character_metrics.metric_id
      WHERE character_metrics.id = metric_entries.character_metric_id
      AND profiles.is_public = true
      AND metrics.show_in_dashboard = true
    )
  );

-- Users can view metric entries for friend characters
CREATE POLICY "Users can view friend metric entries" ON metric_entries
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM character_metrics
      JOIN characters ON characters.id = character_metrics.character_id
      JOIN metrics ON metrics.id = character_metrics.metric_id
      WHERE character_metrics.id = metric_entries.character_metric_id
      AND are_friends(auth.uid(), characters.user_id)
      AND metrics.show_in_dashboard = true
    )
  );

-- =====================================================
-- CHARACTER INVENTORY POLICIES
-- =====================================================

-- Users can manage inventory for their own characters
CREATE POLICY "Users can manage own character inventory" ON character_inventory
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM characters 
      WHERE characters.id = character_inventory.character_id 
      AND characters.user_id = auth.uid()
    )
  );

-- =====================================================
-- FRIENDSHIPS POLICIES
-- =====================================================

-- Users can view friendships they're involved in
CREATE POLICY "Users can view own friendships" ON friendships
  FOR SELECT USING (
    auth.uid() = requester_id OR auth.uid() = recipient_id
  );

-- Users can create friend requests
CREATE POLICY "Users can create friend requests" ON friendships
  FOR INSERT WITH CHECK (auth.uid() = requester_id);

-- Users can update friendships they're involved in (accept/reject)
CREATE POLICY "Users can update own friendships" ON friendships
  FOR UPDATE USING (
    auth.uid() = requester_id OR auth.uid() = recipient_id
  );

-- Users can delete friendships they're involved in
CREATE POLICY "Users can delete own friendships" ON friendships
  FOR DELETE USING (
    auth.uid() = requester_id OR auth.uid() = recipient_id
  );

-- =====================================================
-- ACTIVITY FEED POLICIES
-- =====================================================

-- Users can view their own activity
CREATE POLICY "Users can view own activity" ON activity_feed
  FOR SELECT USING (auth.uid() = user_id);

-- Users can view public activity
CREATE POLICY "Users can view public activity" ON activity_feed
  FOR SELECT USING (is_public = true);

-- Users can view friend activity
CREATE POLICY "Users can view friend activity" ON activity_feed
  FOR SELECT USING (
    friend_visibility = true AND are_friends(auth.uid(), user_id)
  );

-- Users can create their own activity
CREATE POLICY "Users can create own activity" ON activity_feed
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own activity
CREATE POLICY "Users can update own activity" ON activity_feed
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own activity
CREATE POLICY "Users can delete own activity" ON activity_feed
  FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- AUDIT LOG POLICIES (ADMIN ONLY)
-- =====================================================

-- Only admins can view audit logs
CREATE POLICY "Only admins can view audit logs" ON audit_log
  FOR SELECT USING (auth.is_admin());

-- =====================================================
-- PUBLIC READ POLICIES FOR REFERENCE TABLES
-- =====================================================

-- Everyone can read reference/lookup tables
ALTER TABLE character_classes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view character classes" ON character_classes FOR SELECT USING (true);

ALTER TABLE skill_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view skill categories" ON skill_categories FOR SELECT USING (true);

ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view skills" ON skills FOR SELECT USING (is_active = true);

ALTER TABLE quest_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view quest categories" ON quest_categories FOR SELECT USING (true);

ALTER TABLE quest_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view active quest templates" ON quest_templates FOR SELECT USING (is_active = true);

ALTER TABLE achievement_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view achievement categories" ON achievement_categories FOR SELECT USING (true);

ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view active achievements" ON achievements FOR SELECT USING (is_active = true);

ALTER TABLE metric_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view metric categories" ON metric_categories FOR SELECT USING (true);

ALTER TABLE metrics ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view active metrics" ON metrics FOR SELECT USING (is_active = true);

ALTER TABLE item_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view item categories" ON item_categories FOR SELECT USING (true);

ALTER TABLE items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view active items" ON items FOR SELECT USING (is_active = true);

-- Public system settings
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view public system settings" ON system_settings FOR SELECT USING (is_public = true);

-- Schema migrations are read-only for everyone
ALTER TABLE schema_migrations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view schema migrations" ON schema_migrations FOR SELECT USING (true);

-- Insert migration record
INSERT INTO schema_migrations (version) VALUES ('002_row_level_security');