#!/usr/bin/env python3
"""
Test OpenAI API directly to verify if the key is working
"""

import os
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

def test_openai():
    api_key = os.getenv("OPENAI_API_KEY")
    
    if not api_key:
        print("❌ No OpenAI API key found")
        return False
    
    print(f"🔑 API Key: {api_key[:10]}...{api_key[-10:]}")
    
    try:
        client = OpenAI(api_key=api_key)
        
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": "Say hello!"}
            ],
            max_tokens=50,
            temperature=0.7
        )
        
        message = response.choices[0].message.content
        print(f"✅ OpenAI API working! Response: {message}")
        return True
        
    except Exception as e:
        print(f"❌ OpenAI API error: {e}")
        return False

if __name__ == "__main__":
    test_openai() 