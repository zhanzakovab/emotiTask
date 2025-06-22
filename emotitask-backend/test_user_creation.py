import requests
import json

# Test the new assess-and-create-user endpoint
base_url = "http://localhost:8000/api/v1/mbti"

# Sample assessment answers (10 questions, 4 answers each)
test_answers = [
    {"question_id": 1, "answer_id": 1},   # Rally friends (E)
    {"question_id": 2, "answer_id": 2},   # Small group (mild E)
    {"question_id": 3, "answer_id": 3},   # Polished thought (mild N)
    {"question_id": 4, "answer_id": 4},   # Future possibilities (N)
    {"question_id": 5, "answer_id": 3},   # Hidden symbols (N)
    {"question_id": 6, "answer_id": 1},   # Followed playbook (T)
    {"question_id": 7, "answer_id": 1},   # Cold facts (T)
    {"question_id": 8, "answer_id": 2},   # Stress-test ideas (mild T)
    {"question_id": 9, "answer_id": 1},   # Color-coded timeline (J)
    {"question_id": 10, "answer_id": 2},  # Knock out errands (mild J)
]

# Test data
test_payload = {
    "answers": test_answers,
    "user_data": {
        "email": "test@example.com",
        "name": "Test User"
    }
}

print("🚀 Testing assess-and-create-user endpoint...")
print(f"📍 URL: {base_url}/assess-and-create-user")
print(f"📝 Submitting {len(test_answers)} answers")

try:
    response = requests.post(
        f"{base_url}/assess-and-create-user",
        json=test_payload,
        headers={"Content-Type": "application/json"}
    )
    
    print(f"📊 Status Code: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        
        print("✅ Assessment and user creation successful!")
        print(f"🧠 Personality Type: {result['personality_type']['persona_id']}")
        print(f"📝 Name: {result['personality_type']['name']}")
        print(f"📊 Confidence: {result['confidence_score']:.2f}")
        
        if 'user_profile' in result and result['user_profile']:
            user_profile = result['user_profile']
            print(f"👤 User Profile Created:")
            print(f"   ID: {user_profile['id']}")
            print(f"   Persona ID: {user_profile.get('persona_id', 'N/A')}")
            print(f"   Created: {user_profile['created_at']}")
        else:
            print("⚠️ No user profile in response")
            
        print(f"🎨 Chat Style: {result['chat_style']['keywords']}")
        print(f"🌡️ Temperature: {result['chat_style']['temperature']}")
        
    else:
        print(f"❌ Error: {response.status_code}")
        print(f"Response: {response.text}")
        
except Exception as e:
    print(f"❌ Request failed: {e}")

print("\n🔍 Testing without user data (should still work)...")

test_payload_no_user = {
    "answers": test_answers
}

try:
    response = requests.post(
        f"{base_url}/assess-and-create-user",
        json=test_payload_no_user,
        headers={"Content-Type": "application/json"}
    )
    
    print(f"📊 Status Code: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        print("✅ Assessment without user data successful!")
        print(f"🧠 Personality Type: {result['personality_type']['persona_id']}")
        
        if 'user_profile' in result and result['user_profile']:
            print("👤 User profile still created (unexpected)")
        else:
            print("✅ No user profile created (expected)")
    else:
        print(f"❌ Error: {response.status_code}")
        print(f"Response: {response.text}")
        
except Exception as e:
    print(f"❌ Request failed: {e}")
