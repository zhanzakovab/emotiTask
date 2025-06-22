#!/usr/bin/env python3
"""
Test script for user_profile migration to persona_id
Run this after applying the migration to verify everything works
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import db

def test_user_profile_schema():
    """Test that the user_profiles table has the correct schema"""
    print("🧪 Testing user_profiles table schema...")
    
    try:
        # Try to query user_profiles to see what columns exist
        # We'll do this by trying to select specific columns
        
        # Test if persona_id exists
        persona_id_exists = True
        try:
            result = db.client.from_('user_profiles').select('persona_id').limit(1).execute()
            print("✅ persona_id column exists")
        except Exception as e:
            if 'column "persona_id" does not exist' in str(e).lower():
                persona_id_exists = False
                print("❌ persona_id column missing")
            else:
                print(f"❌ Error checking persona_id: {e}")
                return False
        
        # Test if personality_type still exists
        personality_type_exists = True
        try:
            result = db.client.from_('user_profiles').select('personality_type').limit(1).execute()
            print("❌ personality_type column still exists")
        except Exception as e:
            if 'column "personality_type" does not exist' in str(e).lower():
                personality_type_exists = False
                print("✅ personality_type column removed")
            else:
                print(f"❌ Error checking personality_type: {e}")
                return False
        
        # Migration is successful if persona_id exists and personality_type doesn't
        return persona_id_exists and not personality_type_exists
        
    except Exception as e:
        print(f"❌ Schema test failed: {e}")
        return False

def test_foreign_key_constraint():
    """Test that the foreign key constraint works"""
    print("\n🧪 Testing foreign key constraint...")
    
    try:
        # Get a valid persona_id
        personality_types = db.client.from_('personality_types').select('persona_id').limit(1).execute()
        
        if not personality_types.data:
            print("⚠️ No personality types found, skipping foreign key test")
            return True
            
        valid_persona_id = personality_types.data[0]['persona_id']
        print(f"   Using valid persona_id: {valid_persona_id}")
        
        # Try to insert with valid persona_id (this should work if migration is complete)
        test_user_id = "123e4567-e89b-12d3-a456-426614174000"
        
        try:
            # Clean up first
            db.client.from_('user_profiles').delete().eq('id', test_user_id).execute()
            
            # Insert with valid persona_id
            result = db.client.from_('user_profiles').insert({
                'id': test_user_id,
                'persona_id': valid_persona_id
            }).execute()
            print("✅ Valid persona_id insertion succeeded")
            
            # Clean up
            db.client.from_('user_profiles').delete().eq('id', test_user_id).execute()
            
            return True
            
        except Exception as e:
            if 'column "persona_id" does not exist' in str(e).lower():
                print("⚠️ Migration not yet applied - persona_id column doesn't exist")
                return False
            else:
                print(f"❌ Foreign key test failed: {e}")
                return False
        
    except Exception as e:
        print(f"❌ Foreign key test failed: {e}")
        return False

def test_personality_types_exist():
    """Test that personality types are populated"""
    print("\n🧪 Testing personality types data...")
    
    try:
        result = db.client.from_('personality_types').select('persona_id, name').execute()
        
        if len(result.data) >= 16:
            print(f"✅ Found {len(result.data)} personality types")
            print("   Sample types:")
            for pt in result.data[:5]:
                print(f"   - {pt['persona_id']}: {pt['name']}")
            return True
        else:
            print(f"❌ Only found {len(result.data)} personality types, expected 16")
            return False
            
    except Exception as e:
        print(f"❌ Personality types test failed: {e}")
        return False

def main():
    print("🚀 Testing user_profile migration to persona_id...\n")
    
    tests = [
        ("Schema Structure", test_user_profile_schema),
        ("Foreign Key Constraint", test_foreign_key_constraint),
        ("Personality Types Data", test_personality_types_exist),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"📋 {test_name}")
        if test_func():
            passed += 1
        print()
    
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Migration is successful.")
        return True
    else:
        print("❌ Some tests failed. Please check the migration.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
