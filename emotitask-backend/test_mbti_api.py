#!/usr/bin/env python3
"""
Test script for MBTI API endpoints.
This script tests all the MBTI-related endpoints to ensure they work correctly.

Run this after setting up the MBTI tables and starting the API server.
"""

import requests
import json
import sys
from typing import Dict, Any

# API Configuration
BASE_URL = "http://localhost:8000/api/v1"
MBTI_BASE_URL = f"{BASE_URL}/mbti"

def test_endpoint(endpoint: str, method: str = "GET", data: Dict[Any, Any] = None) -> bool:
    """Test a single API endpoint."""
    try:
        url = f"{MBTI_BASE_URL}{endpoint}"
        print(f"🧪 Testing {method} {url}")
        
        if method == "GET":
            response = requests.get(url)
        elif method == "POST":
            response = requests.post(url, json=data)
        else:
            print(f"❌ Unsupported method: {method}")
            return False
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Success: {response.status_code}")
            
            # Print some details about the response
            if isinstance(result, dict):
                if 'total' in result:
                    print(f"   📊 Total items: {result['total']}")
                if 'questions' in result:
                    print(f"   ❓ Questions found: {len(result['questions'])}")
                if 'personality_types' in result:
                    print(f"   🧠 Personality types found: {len(result['personality_types'])}")
                if 'answers' in result:
                    print(f"   💬 Answers found: {len(result['answers'])}")
                if 'chat_styles' in result:
                    print(f"   🎨 Chat styles found: {len(result['chat_styles'])}")
            
            return True
        else:
            print(f"❌ Failed: {response.status_code}")
            print(f"   Error: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print(f"❌ Connection error: Is the API server running on {BASE_URL}?")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    """Run all MBTI API tests."""
    print("🚀 Testing MBTI API endpoints...")
    print(f"📍 Base URL: {MBTI_BASE_URL}")
    print()
    
    # Test results
    results = []
    
    # Test 1: Get all questions
    print("1️⃣ Testing Questions Endpoint")
    results.append(test_endpoint("/questions"))
    print()
    
    # Test 2: Get all personality types
    print("2️⃣ Testing Personality Types Endpoint")
    results.append(test_endpoint("/personality-types"))
    print()
    
    # Test 3: Get specific personality type
    print("3️⃣ Testing Specific Personality Type Endpoint")
    results.append(test_endpoint("/personality-types/INTJ"))
    print()
    
    # Test 4: Get answers for a specific question
    print("4️⃣ Testing Question Answers Endpoint")
    results.append(test_endpoint("/answers/question/1"))
    print()
    
    # Test 5: Get all chat styles
    print("5️⃣ Testing Chat Styles Endpoint")
    results.append(test_endpoint("/chat-styles"))
    print()
    
    # Test 6: Test personality assessment
    print("6️⃣ Testing Personality Assessment Endpoint")
    sample_assessment = {
        "answers": [
            {"question_id": 1, "answer_id": 1},
            {"question_id": 2, "answer_id": 2},
            {"question_id": 3, "answer_id": 3},
            {"question_id": 4, "answer_id": 4},
            {"question_id": 5, "answer_id": 5},
            {"question_id": 6, "answer_id": 6},
            {"question_id": 7, "answer_id": 7},
            {"question_id": 8, "answer_id": 8},
            {"question_id": 9, "answer_id": 9},
            {"question_id": 10, "answer_id": 10}
        ]
    }
    results.append(test_endpoint("/assess", method="POST", data=sample_assessment))
    print()
    
    # Summary
    passed = sum(results)
    total = len(results)
    
    print("📊 Test Summary:")
    print(f"   ✅ Passed: {passed}/{total}")
    print(f"   ❌ Failed: {total - passed}/{total}")
    
    if passed == total:
        print("\n🎉 All MBTI API tests passed!")
        print("\n📋 Your MBTI system is ready to use!")
        print("\n🔗 API Documentation available at: http://localhost:8000/docs")
        return True
    else:
        print(f"\n⚠️  {total - passed} test(s) failed. Please check the API server and database setup.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1) 