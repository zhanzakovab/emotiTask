#!/usr/bin/env python3
"""
Test script to verify task integration with Supabase
Simulates what the iOS app would do
"""

import requests
import json
from datetime import datetime, timedelta

BASE_URL = "http://localhost:8000/api/v1"

def test_task_integration():
    print("🧪 Testing Task Integration with Supabase")
    print("=" * 50)
    
    # Test 1: Create a task
    print("\n1. Creating a task...")
    task_data = {
        "title": "Complete project documentation",
        "notes": "Write comprehensive documentation for the new feature",
        "is_completed": False,
        "emotional_tag": "focus",
        "scheduled_date": (datetime.now() + timedelta(hours=2)).isoformat() + "Z",
        "priority": "High",
        "estimated_duration": 120
    }
    
    response = requests.post(f"{BASE_URL}/tasks/", json=task_data)
    if response.status_code == 201:
        created_task = response.json()
        task_id = created_task["id"]
        print(f"✅ Task created successfully: {created_task['title']}")
        print(f"   Task ID: {task_id}")
        print(f"   User ID: {created_task['user_id']}")
    else:
        print(f"❌ Failed to create task: {response.status_code} - {response.text}")
        return
    
    # Test 2: Get all tasks
    print("\n2. Retrieving all tasks...")
    response = requests.get(f"{BASE_URL}/tasks/")
    if response.status_code == 200:
        tasks_response = response.json()
        print(f"✅ Retrieved {tasks_response['total']} tasks")
        for task in tasks_response['tasks']:
            print(f"   - {task['title']} (Priority: {task['priority']})")
    else:
        print(f"❌ Failed to get tasks: {response.status_code} - {response.text}")
    
    # Test 3: Update the task
    print("\n3. Updating the task...")
    update_data = {
        "title": "Complete project documentation (Updated)",
        "notes": "Write comprehensive documentation for the new feature - UPDATED",
        "priority": "Medium"
    }
    
    response = requests.put(f"{BASE_URL}/tasks/{task_id}", json=update_data)
    if response.status_code == 200:
        updated_task = response.json()
        print(f"✅ Task updated successfully: {updated_task['title']}")
        print(f"   New priority: {updated_task['priority']}")
    else:
        print(f"❌ Failed to update task: {response.status_code} - {response.text}")
    
    # Test 4: Toggle completion
    print("\n4. Toggling task completion...")
    response = requests.patch(f"{BASE_URL}/tasks/{task_id}/complete")
    if response.status_code == 200:
        completed_task = response.json()
        print(f"✅ Task completion toggled: {completed_task['is_completed']}")
    else:
        print(f"❌ Failed to toggle completion: {response.status_code} - {response.text}")
    
    # Test 5: Get specific task
    print("\n5. Getting specific task...")
    response = requests.get(f"{BASE_URL}/tasks/{task_id}")
    if response.status_code == 200:
        task = response.json()
        print(f"✅ Retrieved task: {task['title']}")
        print(f"   Completed: {task['is_completed']}")
        print(f"   Emotional tag: {task['emotional_tag']}")
    else:
        print(f"❌ Failed to get specific task: {response.status_code} - {response.text}")
    
    # Test 6: Delete the task
    print("\n6. Deleting the task...")
    response = requests.delete(f"{BASE_URL}/tasks/{task_id}")
    if response.status_code == 204:
        print("✅ Task deleted successfully")
    else:
        print(f"❌ Failed to delete task: {response.status_code} - {response.text}")
    
    # Test 7: Verify deletion
    print("\n7. Verifying deletion...")
    response = requests.get(f"{BASE_URL}/tasks/{task_id}")
    if response.status_code == 404:
        print("✅ Task deletion verified (404 not found)")
    else:
        print(f"❌ Task still exists: {response.status_code}")
    
    print("\n" + "=" * 50)
    print("🎉 Task integration test completed!")

if __name__ == "__main__":
    test_task_integration() 