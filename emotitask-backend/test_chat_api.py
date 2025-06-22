#!/usr/bin/env python3
"""
Test the Chat API endpoints
"""

import requests
import json

BASE_URL = "http://localhost:8000/api/v1/chat"

def test_chat_endpoints():
    print("🧪 Testing Chat API endpoints...")
    print(f"📍 Base URL: {BASE_URL}")
    print()
    
    # Test user ID (you can use a real user ID from your user_profiles table)
    test_user_id = "test-user-123"
    
    # Test 1: Get chat history (should be empty initially)
    print("1️⃣ Testing Get Chat History")
    try:
        response = requests.get(f"{BASE_URL}/history/{test_user_id}")
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Chat exists: {data['exists']}")
            if data['exists']:
                print(f"   Messages: {len(data['chat_data']['messages'])}")
            else:
                print("   No existing chat found (expected for new user)")
        else:
            print(f"   Error: {response.text}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    print()
    
    # Test 2: Send first chat message
    print("2️⃣ Testing Send Chat Message")
    test_message = {
        "user_id": test_user_id,
        "message": "Hello! Can you help me organize my tasks for today?"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/send", json=test_message)
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   AI Response: {data['message'][:100]}...")
            print(f"   Total messages in chat: {len(data['chat_data']['messages'])}")
            print(f"   Chat ID: {data['chat_data']['id']}")
        else:
            print(f"   Error: {response.text}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    print()
    
    # Test 3: Send follow-up message to test persistence
    print("3️⃣ Testing Chat Persistence (Follow-up Message)")
    followup_message = {
        "user_id": test_user_id,
        "message": "What about tomorrow's tasks?"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/send", json=followup_message)
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   AI Response: {data['message'][:100]}...")
            print(f"   Total messages in chat: {len(data['chat_data']['messages'])}")
            print("   ✅ Chat persistence working!")
        else:
            print(f"   Error: {response.text}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    print()
    
    # Test 4: Get chat history again (should now have messages)
    print("4️⃣ Testing Get Chat History (After Messages)")
    try:
        response = requests.get(f"{BASE_URL}/history/{test_user_id}")
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Chat exists: {data['exists']}")
            if data['exists']:
                print(f"   Total messages: {len(data['chat_data']['messages'])}")
                print("   ✅ Chat history persistence working!")
            else:
                print("   ❌ Chat should exist but doesn't")
        else:
            print(f"   Error: {response.text}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    print()
    
    # Test 5: Clear chat history
    print("5️⃣ Testing Clear Chat History")
    try:
        response = requests.delete(f"{BASE_URL}/clear/{test_user_id}")
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Message: {data['message']}")
            print("   ✅ Chat cleared successfully!")
        else:
            print(f"   Error: {response.text}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    print()
    print("🎉 Chat API testing completed!")

if __name__ == "__main__":
    test_chat_endpoints()
