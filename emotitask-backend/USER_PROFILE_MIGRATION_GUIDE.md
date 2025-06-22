# User Profile Migration Guide

## Overview
This migration updates the `user_profiles` table to:
- Rename `personality_type` column to `persona_id`
- Add foreign key relationship to `personality_types.persona_id`
- Ensure data integrity and proper relationships

## Prerequisites
- Supabase project with existing `user_profiles` and `personality_types` tables
- Admin access to Supabase SQL Editor
- Backup of existing data (recommended)

## Migration Steps

### Step 1: Run the Migration SQL
Copy and paste the contents of `supabase_user_profile_migration.sql` into your Supabase SQL Editor and execute.

### Step 2: Verify the Migration
Run the test script to ensure everything worked correctly:

```bash
cd emotitask-backend
python test_user_profile_migration.py
```

### Step 3: Update Application Code
The backend models have already been updated in `app/models.py`.

## What Changed

### Database Schema
- **Before**: `user_profiles.personality_type TEXT`
- **After**: `user_profiles.persona_id VARCHAR(10) REFERENCES personality_types(persona_id)`

### Benefits
1. **Data Integrity**: Foreign key constraint ensures only valid personality types
2. **Performance**: Index on `persona_id` for faster queries
3. **Consistency**: Direct reference to `personality_types` table
4. **Normalization**: Proper relational database design

### Valid Values
The `persona_id` field accepts these 16 MBTI personality types:
- **Analysts**: INTJ, INTP, ENTJ, ENTP
- **Diplomats**: INFJ, INFP, ENFJ, ENFP
- **Sentinels**: ISTJ, ISFJ, ESTJ, ESFJ
- **Explorers**: ISTP, ISFP, ESTP, ESFP

## Example Usage

### Creating a User Profile
```sql
INSERT INTO user_profiles (id, persona_id) 
VALUES ('user-uuid-here', 'INTJ');
```

### Querying with Personality Type Details
```sql
SELECT 
    up.id,
    up.persona_id,
    pt.name as personality_name,
    pt.description as personality_description
FROM user_profiles up
LEFT JOIN personality_types pt ON up.persona_id = pt.persona_id
WHERE up.id = 'user-uuid-here';
```
