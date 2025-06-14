-- Dual RPG Engine Database Schema
-- Migration 003: Functions and Triggers for Game Mechanics

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

-- Function to calculate experience needed for next level
CREATE OR REPLACE FUNCTION calculate_exp_for_level(target_level INTEGER)
RETURNS BIGINT AS $$
BEGIN
  -- Using a common RPG formula: level^2 * 100
  RETURN (target_level * target_level * 100)::BIGINT;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to calculate level from experience points
CREATE OR REPLACE FUNCTION calculate_level_from_exp(exp_points BIGINT)
RETURNS INTEGER AS $$
DECLARE
  level INTEGER := 1;
BEGIN
  WHILE calculate_exp_for_level(level + 1) <= exp_points LOOP
    level := level + 1;
    -- Cap at level 100
    EXIT WHEN level >= 100;
  END LOOP;
  
  RETURN level;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to calculate skill experience needed for next level
CREATE OR REPLACE FUNCTION calculate_skill_exp_for_level(
  skill_id UUID, 
  target_level INTEGER
)
RETURNS BIGINT AS $$
DECLARE
  base_cost INTEGER;
  scaling_factor DECIMAL(3,2);
BEGIN
  SELECT base_experience_cost, experience_scaling_factor 
  INTO base_cost, scaling_factor
  FROM skills 
  WHERE id = skill_id;
  
  -- Formula: base_cost * (scaling_factor ^ (level - 1))
  RETURN (base_cost * POWER(scaling_factor, target_level - 1))::BIGINT;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to calculate skill level from experience
CREATE OR REPLACE FUNCTION calculate_skill_level_from_exp(
  skill_id UUID, 
  exp_points BIGINT
)
RETURNS INTEGER AS $$
DECLARE
  level INTEGER := 1;
  max_level INTEGER;
BEGIN
  SELECT skills.max_level INTO max_level FROM skills WHERE id = skill_id;
  
  WHILE calculate_skill_exp_for_level(skill_id, level + 1) <= exp_points LOOP
    level := level + 1;
    EXIT WHEN level >= max_level;
  END LOOP;
  
  RETURN LEAST(level, max_level);
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- CHARACTER MANAGEMENT FUNCTIONS
-- =====================================================

-- Function to update character level based on experience
CREATE OR REPLACE FUNCTION update_character_level()
RETURNS TRIGGER AS $$
DECLARE
  new_level INTEGER;
BEGIN
  new_level := calculate_level_from_exp(NEW.experience_points);
  
  IF new_level != NEW.level THEN
    NEW.level := new_level;
    -- Award attribute points for leveling up (1 point per level)
    IF new_level > OLD.level THEN
      -- Could add automatic attribute increases here
      -- For now, just log the level up
      INSERT INTO activity_feed (user_id, activity_type, title, description, metadata)
      VALUES (
        (SELECT user_id FROM characters WHERE id = NEW.id),
        'level_up',
        'Level Up!',
        'Reached level ' || new_level::TEXT,
        jsonb_build_object('new_level', new_level, 'old_level', OLD.level)
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update character level
CREATE TRIGGER update_character_level_trigger
  BEFORE UPDATE ON characters
  FOR EACH ROW
  WHEN (OLD.experience_points != NEW.experience_points)
  EXECUTE FUNCTION update_character_level();

-- Function to update skill level based on experience
CREATE OR REPLACE FUNCTION update_skill_level()
RETURNS TRIGGER AS $$
DECLARE
  new_level INTEGER;
BEGIN
  new_level := calculate_skill_level_from_exp(NEW.skill_id, NEW.experience_points);
  
  IF new_level != NEW.current_level THEN
    NEW.current_level := new_level;
    
    -- Log skill level up
    IF new_level > OLD.current_level THEN
      INSERT INTO activity_feed (
        user_id, 
        activity_type, 
        title, 
        description, 
        metadata
      )
      SELECT 
        c.user_id,
        'skill_level_up',
        'Skill Mastery!',
        s.name || ' reached level ' || new_level::TEXT,
        jsonb_build_object(
          'skill_id', NEW.skill_id,
          'skill_name', s.name,
          'new_level', new_level,
          'old_level', OLD.current_level
        )
      FROM characters c
      JOIN skills s ON s.id = NEW.skill_id
      WHERE c.id = NEW.character_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update skill level
CREATE TRIGGER update_skill_level_trigger
  BEFORE UPDATE ON character_skills
  FOR EACH ROW
  WHEN (OLD.experience_points != NEW.experience_points)
  EXECUTE FUNCTION update_skill_level();

-- Function to update character derived stats
CREATE OR REPLACE FUNCTION update_derived_stats()
RETURNS TRIGGER AS $$
BEGIN
  -- Update max health based on constitution and level
  NEW.max_health_points := 100 + (NEW.constitution * 2) + (NEW.level * 10);
  
  -- Update max mana based on intelligence and wisdom
  NEW.max_mana_points := 50 + ((NEW.intelligence + NEW.wisdom) * 2);
  
  -- Ensure current HP/MP don't exceed maximums
  NEW.health_points := LEAST(NEW.health_points, NEW.max_health_points);
  NEW.mana_points := LEAST(NEW.mana_points, NEW.max_mana_points);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update derived stats
CREATE TRIGGER update_derived_stats_trigger
  BEFORE INSERT OR UPDATE ON characters
  FOR EACH ROW
  EXECUTE FUNCTION update_derived_stats();

-- =====================================================
-- QUEST MANAGEMENT FUNCTIONS
-- =====================================================

-- Function to check and update quest completion
CREATE OR REPLACE FUNCTION check_quest_completion(quest_id UUID)
RETURNS VOID AS $$
DECLARE
  quest_record RECORD;
  objective JSONB;
  all_complete BOOLEAN := TRUE;
  completion_pct INTEGER := 0;
  completed_count INTEGER := 0;
  total_count INTEGER := 0;
BEGIN
  SELECT * INTO quest_record FROM character_quests WHERE id = quest_id;
  
  IF NOT FOUND THEN
    RETURN;
  END IF;
  
  -- Get objectives from template
  FOR objective IN 
    SELECT jsonb_array_elements(objectives) 
    FROM quest_templates 
    WHERE id = quest_record.template_id
  LOOP
    total_count := total_count + 1;
    
    -- Check if this objective is complete
    -- This is simplified - in reality you'd have complex objective checking logic
    IF (quest_record.progress->>(objective->>'id'))::INTEGER >= (objective->>'target')::INTEGER THEN
      completed_count := completed_count + 1;
    ELSE
      all_complete := FALSE;
    END IF;
  END LOOP;
  
  -- Calculate completion percentage
  IF total_count > 0 THEN
    completion_pct := (completed_count * 100) / total_count;
  END IF;
  
  -- Update quest status
  UPDATE character_quests 
  SET 
    completion_percentage = completion_pct,
    status = CASE 
      WHEN all_complete THEN 'completed'
      ELSE status 
    END,
    completed_at = CASE 
      WHEN all_complete AND status != 'completed' THEN NOW()
      ELSE completed_at 
    END,
    updated_at = NOW()
  WHERE id = quest_id;
  
  -- Award rewards if just completed
  IF all_complete AND quest_record.status != 'completed' THEN
    PERFORM award_quest_rewards(quest_id);
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to award quest rewards
CREATE OR REPLACE FUNCTION award_quest_rewards(quest_id UUID)
RETURNS VOID AS $$
DECLARE
  quest_record RECORD;
  template_record RECORD;
  char_id UUID;
  skill_reward JSONB;
  attr_reward TEXT;
  attr_value INTEGER;
BEGIN
  SELECT cq.*, c.id as character_id, c.user_id
  INTO quest_record
  FROM character_quests cq
  JOIN characters c ON c.id = cq.character_id
  WHERE cq.id = quest_id;
  
  SELECT * INTO template_record 
  FROM quest_templates 
  WHERE id = quest_record.template_id;
  
  char_id := quest_record.character_id;
  
  -- Award base experience
  IF template_record.experience_reward > 0 THEN
    UPDATE characters 
    SET experience_points = experience_points + template_record.experience_reward
    WHERE id = char_id;
  END IF;
  
  -- Award skill experience
  FOR skill_reward IN 
    SELECT jsonb_each(template_record.skill_experience_rewards)
  LOOP
    INSERT INTO character_skills (character_id, skill_id, experience_points)
    VALUES (
      char_id, 
      (skill_reward->>'key')::UUID, 
      (skill_reward->>'value')::INTEGER
    )
    ON CONFLICT (character_id, skill_id) 
    DO UPDATE SET 
      experience_points = character_skills.experience_points + (skill_reward->>'value')::INTEGER;
  END LOOP;
  
  -- Award attribute bonuses
  FOR attr_reward IN 
    SELECT jsonb_object_keys(template_record.attribute_rewards)
  LOOP
    attr_value := (template_record.attribute_rewards->>attr_reward)::INTEGER;
    
    CASE attr_reward
      WHEN 'strength' THEN
        UPDATE characters SET strength = LEAST(strength + attr_value, 100) WHERE id = char_id;
      WHEN 'intelligence' THEN
        UPDATE characters SET intelligence = LEAST(intelligence + attr_value, 100) WHERE id = char_id;
      WHEN 'wisdom' THEN
        UPDATE characters SET wisdom = LEAST(wisdom + attr_value, 100) WHERE id = char_id;
      WHEN 'charisma' THEN
        UPDATE characters SET charisma = LEAST(charisma + attr_value, 100) WHERE id = char_id;
      WHEN 'constitution' THEN
        UPDATE characters SET constitution = LEAST(constitution + attr_value, 100) WHERE id = char_id;
      WHEN 'dexterity' THEN
        UPDATE characters SET dexterity = LEAST(dexterity + attr_value, 100) WHERE id = char_id;
    END CASE;
  END LOOP;
  
  -- Log quest completion
  INSERT INTO activity_feed (user_id, activity_type, title, description, metadata)
  VALUES (
    quest_record.user_id,
    'quest_completed',
    'Quest Completed!',
    template_record.title || ' has been completed',
    jsonb_build_object(
      'quest_id', quest_id,
      'template_id', quest_record.template_id,
      'rewards', jsonb_build_object(
        'experience', template_record.experience_reward,
        'skill_experience', template_record.skill_experience_rewards,
        'attributes', template_record.attribute_rewards
      )
    )
  );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ACHIEVEMENT FUNCTIONS
-- =====================================================

-- Function to check achievement requirements
CREATE OR REPLACE FUNCTION check_achievements(char_id UUID)
RETURNS VOID AS $$
DECLARE
  achievement RECORD;
  char_record RECORD;
  requirement_met BOOLEAN;
BEGIN
  SELECT * INTO char_record FROM characters WHERE id = char_id;
  
  -- Check all achievements that aren't already unlocked
  FOR achievement IN 
    SELECT a.* FROM achievements a
    WHERE a.is_active = TRUE
    AND NOT EXISTS (
      SELECT 1 FROM character_achievements ca 
      WHERE ca.character_id = char_id 
      AND ca.achievement_id = a.id 
      AND ca.is_unlocked = TRUE
    )
  LOOP
    requirement_met := TRUE;
    
    -- This is a simplified check - in reality you'd have complex requirement logic
    -- For now, just check level requirements as an example
    IF achievement.requirements ? 'min_level' THEN
      IF char_record.level < (achievement.requirements->>'min_level')::INTEGER THEN
        requirement_met := FALSE;
      END IF;
    END IF;
    
    -- If requirements are met, unlock the achievement
    IF requirement_met THEN
      INSERT INTO character_achievements (character_id, achievement_id, is_unlocked, unlocked_at)
      VALUES (char_id, achievement.id, TRUE, NOW())
      ON CONFLICT (character_id, achievement_id) 
      DO UPDATE SET 
        is_unlocked = TRUE,
        unlocked_at = NOW();
        
      -- Award achievement rewards
      PERFORM award_achievement_rewards(char_id, achievement.id);
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to award achievement rewards
CREATE OR REPLACE FUNCTION award_achievement_rewards(char_id UUID, achievement_id UUID)
RETURNS VOID AS $$
DECLARE
  achievement_record RECORD;
  attr_reward TEXT;
  attr_value INTEGER;
BEGIN
  SELECT a.*, c.user_id
  INTO achievement_record
  FROM achievements a
  JOIN characters c ON c.id = char_id
  WHERE a.id = achievement_id;
  
  -- Award experience
  IF achievement_record.experience_reward > 0 THEN
    UPDATE characters 
    SET experience_points = experience_points + achievement_record.experience_reward
    WHERE id = char_id;
  END IF;
  
  -- Award attribute bonuses
  FOR attr_reward IN 
    SELECT jsonb_object_keys(achievement_record.attribute_rewards)
  LOOP
    attr_value := (achievement_record.attribute_rewards->>attr_reward)::INTEGER;
    
    CASE attr_reward
      WHEN 'strength' THEN
        UPDATE characters SET strength = LEAST(strength + attr_value, 100) WHERE id = char_id;
      WHEN 'intelligence' THEN
        UPDATE characters SET intelligence = LEAST(intelligence + attr_value, 100) WHERE id = char_id;
      WHEN 'wisdom' THEN
        UPDATE characters SET wisdom = LEAST(wisdom + attr_value, 100) WHERE id = char_id;
      WHEN 'charisma' THEN
        UPDATE characters SET charisma = LEAST(charisma + attr_value, 100) WHERE id = char_id;
      WHEN 'constitution' THEN
        UPDATE characters SET constitution = LEAST(constitution + attr_value, 100) WHERE id = char_id;
      WHEN 'dexterity' THEN
        UPDATE characters SET dexterity = LEAST(dexterity + attr_value, 100) WHERE id = char_id;
    END CASE;
  END LOOP;
  
  -- Log achievement unlock
  INSERT INTO activity_feed (user_id, activity_type, title, description, metadata)
  VALUES (
    achievement_record.user_id,
    'achievement_unlocked',
    'Achievement Unlocked!',
    achievement_record.title,
    jsonb_build_object(
      'achievement_id', achievement_id,
      'rarity', achievement_record.rarity,
      'rewards', jsonb_build_object(
        'experience', achievement_record.experience_reward,
        'attributes', achievement_record.attribute_rewards,
        'title', achievement_record.title_reward
      )
    )
  );
END;
$$ LANGUAGE plpgsql;

-- Trigger to check achievements when character stats change
CREATE OR REPLACE FUNCTION trigger_achievement_check()
RETURNS TRIGGER AS $$
BEGIN
  -- Run achievement check asynchronously to avoid blocking updates
  PERFORM pg_notify('check_achievements', NEW.id::TEXT);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_achievements_on_character_update
  AFTER UPDATE ON characters
  FOR EACH ROW
  EXECUTE FUNCTION trigger_achievement_check();

-- =====================================================
-- METRIC TRACKING FUNCTIONS
-- =====================================================

-- Function to update metric streaks
CREATE OR REPLACE FUNCTION update_metric_streaks()
RETURNS TRIGGER AS $$
DECLARE
  today DATE := CURRENT_DATE;
  yesterday DATE := CURRENT_DATE - INTERVAL '1 day';
BEGIN
  -- If this is the first entry today, check streak logic
  IF NOT EXISTS (
    SELECT 1 FROM metric_entries me2
    WHERE me2.character_metric_id = NEW.character_metric_id
    AND me2.recorded_at::DATE = today
    AND me2.id != NEW.id
  ) THEN
    -- Check if there was an entry yesterday
    IF EXISTS (
      SELECT 1 FROM metric_entries me3
      WHERE me3.character_metric_id = NEW.character_metric_id
      AND me3.recorded_at::DATE = yesterday
    ) THEN
      -- Continue streak
      UPDATE character_metrics 
      SET 
        current_streak = current_streak + 1,
        longest_streak = GREATEST(longest_streak, current_streak + 1),
        last_streak_date = today
      WHERE id = NEW.character_metric_id;
    ELSE
      -- Start new streak
      UPDATE character_metrics 
      SET 
        current_streak = 1,
        longest_streak = GREATEST(longest_streak, 1),
        last_streak_date = today
      WHERE id = NEW.character_metric_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update streaks when new metric entries are added
CREATE TRIGGER update_metric_streaks_trigger
  AFTER INSERT ON metric_entries
  FOR EACH ROW
  EXECUTE FUNCTION update_metric_streaks();

-- Function to update metric totals and best values
CREATE OR REPLACE FUNCTION update_metric_totals()
RETURNS TRIGGER AS $$
DECLARE
  metric_record RECORD;
BEGIN
  SELECT * INTO metric_record FROM metrics m
  JOIN character_metrics cm ON cm.metric_id = m.id
  WHERE cm.id = NEW.character_metric_id;
  
  -- Update current value
  NEW.current_value := NEW.value;
  
  -- Update totals and best values in character_metrics
  IF metric_record.is_cumulative THEN
    -- For cumulative metrics, add to total
    UPDATE character_metrics 
    SET 
      total_value = total_value + NEW.value,
      best_value = GREATEST(COALESCE(best_value, 0), NEW.value),
      last_updated_at = NEW.recorded_at
    WHERE id = NEW.character_metric_id;
  ELSE
    -- For non-cumulative metrics, current value is latest entry
    UPDATE character_metrics 
    SET 
      current_value = NEW.value,
      best_value = GREATEST(COALESCE(best_value, NEW.value), NEW.value),
      last_updated_at = NEW.recorded_at
    WHERE id = NEW.character_metric_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update metric totals
CREATE TRIGGER update_metric_totals_trigger
  BEFORE INSERT ON metric_entries
  FOR EACH ROW
  EXECUTE FUNCTION update_metric_totals();

-- =====================================================
-- AUDIT LOGGING FUNCTIONS
-- =====================================================

-- Generic audit logging function
CREATE OR REPLACE FUNCTION audit_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO audit_log (user_id, action, table_name, record_id, old_values)
    VALUES (
      auth.uid(),
      'DELETE',
      TG_TABLE_NAME,
      OLD.id,
      to_jsonb(OLD)
    );
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_log (user_id, action, table_name, record_id, old_values, new_values)
    VALUES (
      auth.uid(),
      'UPDATE',
      TG_TABLE_NAME,
      NEW.id,
      to_jsonb(OLD),
      to_jsonb(NEW)
    );
    RETURN NEW;
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO audit_log (user_id, action, table_name, record_id, new_values)
    VALUES (
      auth.uid(),
      'INSERT',
      TG_TABLE_NAME,
      NEW.id,
      to_jsonb(NEW)
    );
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Add audit triggers to important tables
CREATE TRIGGER audit_characters_trigger
  AFTER INSERT OR UPDATE OR DELETE ON characters
  FOR EACH ROW EXECUTE FUNCTION audit_changes();

CREATE TRIGGER audit_character_quests_trigger
  AFTER INSERT OR UPDATE OR DELETE ON character_quests
  FOR EACH ROW EXECUTE FUNCTION audit_changes();

CREATE TRIGGER audit_character_achievements_trigger
  AFTER INSERT OR UPDATE OR DELETE ON character_achievements
  FOR EACH ROW EXECUTE FUNCTION audit_changes();

-- =====================================================
-- UPDATED_AT TIMESTAMP FUNCTIONS
-- =====================================================

-- Generic function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers to relevant tables
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at
  BEFORE UPDATE ON user_preferences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_characters_updated_at
  BEFORE UPDATE ON characters
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_character_skills_updated_at
  BEFORE UPDATE ON character_skills
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_character_quests_updated_at
  BEFORE UPDATE ON character_quests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_character_achievements_updated_at
  BEFORE UPDATE ON character_achievements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_character_inventory_updated_at
  BEFORE UPDATE ON character_inventory
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quest_templates_updated_at
  BEFORE UPDATE ON quest_templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_settings_updated_at
  BEFORE UPDATE ON system_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert migration record
INSERT INTO schema_migrations (version) VALUES ('003_functions_and_triggers');