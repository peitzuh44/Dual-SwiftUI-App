# Dual RPG Engine Database Schema

This directory contains the complete database schema for the Dual RPG engine, a gamified life tracking application that turns real-world activities into RPG-style progression.

## 📋 Migration Files

Run these SQL files in order to set up the database:

1. **`001_initial_schema.sql`** - Core table structure
2. **`002_row_level_security.sql`** - Security policies and access control
3. **`003_functions_and_triggers.sql`** - Game mechanics and automation
4. **`004_indexes.sql`** - Performance optimization
5. **`005_sample_data.sql`** - Reference data and examples
6. **`setup_database.sql`** - Verification and setup helper

## 🎮 Core Systems

### User Management
- **`profiles`** - User account information (extends Supabase auth)
- **`user_preferences`** - User settings and preferences

### Character System
- **`character_classes`** - Available character archetypes (Warrior, Mage, Rogue, etc.)
- **`characters`** - User's RPG avatar with attributes and stats
- **`character_skills`** - Individual skill progression
- **`character_achievements`** - Unlocked achievements and milestones

### Quest System
- **`quest_categories`** - Quest organization (Daily Habits, Fitness, Learning, etc.)
- **`quest_templates`** - Reusable quest definitions
- **`character_quests`** - Active and completed quest instances

### Metrics Tracking
- **`metric_categories`** - Metric organization (Health, Fitness, Productivity, etc.)
- **`metrics`** - Available metrics to track
- **`character_metrics`** - User's current metric values and streaks
- **`metric_entries`** - Historical metric data points

### Rewards & Inventory
- **`item_categories`** - Item organization (Consumables, Equipment, Tools, etc.)
- **`items`** - Available items and their effects
- **`character_inventory`** - User's collected items

### Social Features
- **`friendships`** - Friend connections between users
- **`activity_feed`** - Social activity sharing

### Reference Tables
- **`skills`** - Available skills and their properties
- **`skill_categories`** - Skill organization
- **`achievements`** - Achievement definitions
- **`achievement_categories`** - Achievement organization

## 🛡️ Security Features

### Row Level Security (RLS)
All user data tables have RLS enabled with policies that ensure:
- Users can only access their own data
- Public profiles are visible to all users
- Friends can see each other's data based on privacy settings
- Admin users have elevated access for management

### Key Security Policies
- **Profile Privacy**: Users control visibility of their profiles
- **Data Isolation**: Character data is isolated per user
- **Friend Visibility**: Metrics and achievements visible to friends only if enabled
- **Admin Access**: Audit logs and system settings require admin privileges

## ⚡ Performance Optimizations

### Indexes
- **Primary Lookups**: Fast user and character data access
- **Leaderboards**: Optimized queries for rankings and competitions
- **Time-based Queries**: Efficient metric history and streak calculations
- **Search**: Full-text search on names and descriptions
- **Composite Indexes**: Multi-column indexes for complex queries

### Query Optimization
- Partial indexes for frequently filtered data
- Covering indexes for read-heavy operations
- Statistics updates for optimal query planning

## 🔧 Game Mechanics

### Automatic Systems
- **Level Calculation**: Characters auto-level based on experience
- **Skill Progression**: Skills level up automatically from experience
- **Achievement Checking**: Achievements unlock when requirements are met
- **Streak Tracking**: Automatic streak calculation for metrics
- **Quest Completion**: Auto-completion when objectives are met

### Triggers and Functions
- **Experience Rewards**: Automatic XP distribution for completed activities
- **Stat Updates**: Derived stats update when base attributes change
- **Activity Logging**: Important events logged to activity feed
- **Audit Trail**: All important changes logged for security

## 📊 Data Types and Validation

### Attribute Ranges
- Character attributes: 1-100 (capped at maximum)
- Character level: 1-100
- Skill levels: 0 to skill-specific maximum
- Health/Mana: 0 to character-specific maximum

### JSON Data Structures
- **Quest Objectives**: Flexible objective definitions
- **Skill Requirements**: Complex prerequisite systems
- **Item Effects**: Configurable item behaviors
- **Achievement Requirements**: Complex unlock conditions

## 🚀 Getting Started

### Prerequisites
- PostgreSQL 12+ or Supabase project
- `uuid-ossp` extension enabled
- `pg_trgm` extension enabled (for search)

### Installation Steps

1. **Create Database Extensions**:
   ```sql
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   CREATE EXTENSION IF NOT EXISTS "pg_trgm";
   ```

2. **Run Migrations**:
   Execute the migration files in order:
   ```bash
   # Run these in your database client
   psql -f 001_initial_schema.sql
   psql -f 002_row_level_security.sql
   psql -f 003_functions_and_triggers.sql
   psql -f 004_indexes.sql
   psql -f 005_sample_data.sql
   ```

3. **Verify Setup**:
   ```sql
   -- Check migrations
   SELECT * FROM schema_migrations;
   
   -- Verify sample data
   SELECT COUNT(*) FROM character_classes;
   SELECT COUNT(*) FROM skills;
   SELECT COUNT(*) FROM quest_templates;
   ```

4. **Configure Supabase (if using)**:
   - Enable real-time subscriptions for key tables
   - Configure API settings
   - Set up authentication policies

### Environment Variables

For your Swift app, you'll need:
```swift
// SupabaseClient.swift
let supabaseURL = "https://your-project.supabase.co"
let supabaseKey = "your-anon-key"
```

## 📱 iOS Integration

### Key Tables for Mobile App
- **`profiles`** - User account data
- **`characters`** - Character stats and progression
- **`character_quests`** - Active quests and progress
- **`character_metrics`** - Tracked metrics and streaks
- **`activity_feed`** - Social features and notifications

### Real-time Features
Enable real-time subscriptions for:
- Quest completion notifications
- Achievement unlocks
- Friend activity updates
- Metric streak updates

## 🔄 Data Flow

### User Journey
1. **Registration**: Profile created automatically via Supabase Auth
2. **Character Creation**: User chooses class and creates character
3. **Quest Assignment**: Daily/weekly quests auto-assigned
4. **Metric Tracking**: User logs activities and metrics
5. **Progression**: Experience gained, levels increased, achievements unlocked
6. **Social Interaction**: Friends added, activity shared

### Key Relationships
- User → Character (1:1 active character)
- Character → Skills (1:many progression)
- Character → Quests (1:many active/completed)
- Character → Metrics (1:many tracked values)
- User → Friends (many:many relationships)

## 🛠️ Customization

### Adding New Content
- **Skills**: Insert into `skills` table with category and requirements
- **Quests**: Create templates in `quest_templates` with objectives
- **Achievements**: Define in `achievements` with unlock requirements
- **Items**: Add to `items` with effects and properties

### Modifying Game Balance
- **Experience Curves**: Adjust functions `calculate_exp_for_level()`
- **Skill Costs**: Modify `base_experience_cost` and `experience_scaling_factor`
- **Attribute Caps**: Change CHECK constraints on character attributes
- **Reward Values**: Update `experience_reward` in quest templates

## 📈 Analytics and Reporting

### Built-in Analytics
- User engagement tracking via `activity_feed`
- Quest completion rates in `character_quests`
- Skill progression patterns in `character_skills`
- Metric trend analysis in `metric_entries`

### Custom Queries
The schema supports complex analytics queries for:
- User retention analysis
- Feature usage patterns
- Game balance evaluation
- Social interaction metrics

## 🎯 Future Enhancements

### Planned Features
- **Guilds/Teams**: Social groups for collaborative goals
- **Events**: Time-limited challenges and competitions
- **Trading**: Item exchange between users
- **Crafting**: Combining items to create new ones
- **PvP**: Competitive elements and leaderboards

### Scaling Considerations
- **Partitioning**: `metric_entries` table for large datasets
- **Caching**: Redis integration for frequently accessed data
- **Archiving**: Historical data management strategies
- **Sharding**: Multi-database support for large user bases

## 🔍 Troubleshooting

### Common Issues
- **Migration Errors**: Check PostgreSQL version compatibility
- **Permission Denied**: Verify RLS policies and user permissions
- **Performance Issues**: Review query plans and index usage
- **Data Consistency**: Check trigger execution and constraint violations

### Debugging Queries
```sql
-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'your_table';

-- View active connections
SELECT * FROM pg_stat_activity;

-- Check index usage
EXPLAIN ANALYZE SELECT * FROM your_query;
```

## 📄 License

This database schema is part of the Dual RPG Engine project. See the main project repository for license information.

---

*For questions or support, refer to the main project documentation or create an issue in the project repository.*