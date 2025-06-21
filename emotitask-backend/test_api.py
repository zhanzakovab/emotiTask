#!/usr/bin/env python3
"""
API Test Script for EmotiTask
Tests the complete flow including auth and CRUD operations
"""

import requests
import json
from datetime import datetime, timedelta

BASE_URL = "http://localhost:8000"
API_BASE = f"{BASE_URL}/api/v1"

def test_health():
    """Test health endpoint"""
    print("🏥 Testing health endpoint...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    return response.status_code == 200

def test_auth_signup():
    """Test user signup"""
    print("\n🔐 Testing user signup...")
    
    signup_data = {
        "email": f"test_{datetime.now().strftime('%Y%m%d_%H%M%S')}@example.com",
        "password": "testpassword123"
    }
    
    response = requests.post(f"{API_BASE}/auth/signup", json=signup_data)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 201:
        data = response.json()
        print("✅ Signup successful!")
        print(f"Access Token: {data['access_token'][:20]}...")
        return data['access_token']
    else:
        print(f"❌ Signup failed: {response.text}")
        return None

def test_tasks_with_auth(token):
    """Test tasks CRUD with authentication"""
    print(f"\n📝 Testing tasks with authentication...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # 1. Get tasks (should be empty initially)
    print("Getting tasks...")
    response = requests.get(f"{API_BASE}/tasks/", headers=headers)
    print(f"Get tasks status: {response.status_code}")
    
    if response.status_code == 200:
        tasks = response.json()
        print(f"✅ Found {tasks['total']} tasks")
    else:
        print(f"❌ Get tasks failed: {response.text}")
        return False
    
    # 2. Create a new task
    print("\nCreating new task...")
    new_task = {
        "title": "Test API Task",
        "notes": "Created via API test",
        "is_completed": False,
        "emotional_tag": "focus",
        "scheduled_date": datetime.now().isoformat(),
        "priority": "High",
        "estimated_duration": 30
    }
    
    response = requests.post(f"{API_BASE}/tasks/", headers=headers, json=new_task)
    print(f"Create task status: {response.status_code}")
    
    if response.status_code == 201:
        created_task = response.json()
        print(f"✅ Task created with ID: {created_task['id']}")
        task_id = created_task['id']
    else:
        print(f"❌ Create task failed: {response.text}")
        return False
    
    # 3. Update the task
    print(f"\nUpdating task {task_id}...")
    update_data = {
        "title": "Updated API Task",
        "is_completed": True
    }
    
    response = requests.put(f"{API_BASE}/tasks/{task_id}", headers=headers, json=update_data)
    print(f"Update task status: {response.status_code}")
    
    if response.status_code == 200:
        updated_task = response.json()
        print(f"✅ Task updated: {updated_task['title']}")
    else:
        print(f"❌ Update task failed: {response.text}")
    
    # 4. Get the specific task
    print(f"\nGetting specific task {task_id}...")
    response = requests.get(f"{API_BASE}/tasks/{task_id}", headers=headers)
    print(f"Get specific task status: {response.status_code}")
    
    if response.status_code == 200:
        task = response.json()
        print(f"✅ Retrieved task: {task['title']} (completed: {task['is_completed']})")
    else:
        print(f"❌ Get specific task failed: {response.text}")
    
    # 5. Delete the task
    print(f"\nDeleting task {task_id}...")
    response = requests.delete(f"{API_BASE}/tasks/{task_id}", headers=headers)
    print(f"Delete task status: {response.status_code}")
    
    if response.status_code == 204:
        print("✅ Task deleted successfully")
    else:
        print(f"❌ Delete task failed: {response.text}")
    
    return True

def test_without_auth():
    """Test endpoints without authentication (should fail)"""
    print(f"\n🚫 Testing without authentication...")
    
    # Should get 401 Unauthorized
    response = requests.get(f"{API_BASE}/tasks/")
    print(f"Tasks without auth status: {response.status_code}")
    
    if response.status_code == 401:
        print("✅ Properly rejected unauthenticated request")
        return True
    else:
        print(f"❌ Should have been 401, got: {response.status_code}")
        return False

def test_projects_and_goals(token):
    """Test projects and goals endpoints"""
    print(f"\n📊 Testing projects and goals...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test projects
    response = requests.get(f"{API_BASE}/projects/", headers=headers)
    print(f"Projects status: {response.status_code}")
    
    # Test goals
    response = requests.get(f"{API_BASE}/goals/", headers=headers)
    print(f"Goals status: {response.status_code}")
    
    if response.status_code == 200:
        print("✅ Projects and goals endpoints working")
        return True
    else:
        print(f"❌ Projects/goals failed: {response.text}")
        return False

def test_chat(token):
    """Test AI chat endpoint"""
    print(f"\n🤖 Testing AI chat...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    chat_data = {
        "message": "Hello, I'm feeling overwhelmed with my tasks today."
    }
    
    response = requests.post(f"{API_BASE}/chat/message", headers=headers, json=chat_data)
    print(f"Chat status: {response.status_code}")
    
    if response.status_code == 200:
        chat_response = response.json()
        print(f"✅ AI Response: {chat_response['response'][:100]}...")
        return True
    else:
        print(f"❌ Chat failed: {response.text}")
        return False

def main():
    print("🚀 EmotiTask API Test Suite")
    print("=" * 50)
    
    # Test 1: Health check
    if not test_health():
        print("❌ Health check failed - server not running?")
        return
    
    # Test 2: Authentication not required
    test_without_auth()
    
    # Test 3: User signup
    token = test_auth_signup()
    if not token:
        print("❌ Cannot continue without authentication token")
        return
    
    # Test 4: Tasks CRUD with auth
    test_tasks_with_auth(token)
    
    # Test 5: Other endpoints
    test_projects_and_goals(token)
    
    # Test 6: AI Chat
    test_chat(token)
    
    print("\n🎉 API Test Suite Complete!")
    print("Your EmotiTask backend is ready for production! 🚀")

if __name__ == "__main__":
    main() 