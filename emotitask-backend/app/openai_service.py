"""
OpenAI Service for EmotiTask
Handles personality-based AI chat responses using user's MBTI type.
"""

from openai import OpenAI
from typing import List, Dict, Optional
from .config import settings

class OpenAIService:
    def __init__(self):
        if settings.OPENAI_API_KEY:
            self.client = OpenAI(api_key=settings.OPENAI_API_KEY)
            print("✅ OpenAI client initialized")
        else:
            self.client = None
            print("⚠️ OpenAI API key not configured")
    
    async def generate_chat_response(self, messages: List[Dict], user_persona: Optional[str] = None) -> str:
        """
        Generate AI chat response based on conversation history and user personality.
        
        Args:
            messages: List of message dictionaries with role, content, timestamp
            user_persona: User's MBTI personality type (e.g., "INTJ", "ENFP")
            
        Returns:
            AI response string
        """
        try:
            if not self.client:
                return "I'm here to help! (OpenAI not configured - check your API key)"
            
            # Get personality-based system prompt
            system_prompt = self._get_personality_system_prompt(user_persona)
            
            # Convert messages to OpenAI format (only role and content)
            openai_messages = [{"role": "system", "content": system_prompt}]
            
            # Add conversation history (limit to last 10 messages for context)
            recent_messages = messages[-10:] if len(messages) > 10 else messages
            
            for msg in recent_messages:
                openai_messages.append({
                    "role": msg["role"],
                    "content": msg["content"]
                })
            
            # Get chat style settings for personality type
            temperature = self._get_personality_temperature(user_persona)
            
            print(f"🤖 Generating response for {user_persona} personality (temp: {temperature})")
            
            # Call OpenAI API using the new client
            response = self.client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=openai_messages,
                temperature=temperature,
                max_tokens=500,
                presence_penalty=0.1,
                frequency_penalty=0.1
            )
            
            ai_response = response.choices[0].message.content.strip()
            print(f"✅ Generated AI response: {ai_response[:50]}...")
            
            return ai_response
            
        except Exception as e:
            print(f"❌ OpenAI API error: {e}")
            return f"I apologize, but I'm having trouble generating a response right now. Please try again. (Error: {str(e)[:50]}...)"
    
    def _get_personality_system_prompt(self, persona: Optional[str]) -> str:
        """Get system prompt based on user's MBTI personality type."""
        
        personality_prompts = {
            "INTJ": "You are an AI assistant helping an INTJ (Architect) personality. Be strategic, analytical, and focus on long-term planning. Provide structured, logical advice with clear steps. Value efficiency and competence.",
            
            "INTP": "You are an AI assistant helping an INTP (Thinker) personality. Be curious, analytical, and theoretical. Explore ideas deeply, provide multiple perspectives, and encourage intellectual exploration.",
            
            "ENTJ": "You are an AI assistant helping an ENTJ (Commander) personality. Be decisive, goal-oriented, and leadership-focused. Provide clear action plans, emphasize efficiency, and help organize projects.",
            
            "ENTP": "You are an AI assistant helping an ENTP (Debater) personality. Be enthusiastic, creative, and idea-focused. Generate multiple possibilities, encourage innovation, and explore new approaches.",
            
            "INFJ": "You are an AI assistant helping an INFJ (Advocate) personality. Be insightful, values-driven, and future-focused. Consider personal meaning, provide thoughtful guidance, and respect their need for purpose.",
            
            "INFP": "You are an AI assistant helping an INFP (Mediator) personality. Be supportive, values-focused, and flexible. Respect their personal values, provide gentle guidance, and encourage authentic self-expression.",
            
            "ENFJ": "You are an AI assistant helping an ENFJ (Protagonist) personality. Be warm, people-focused, and inspiring. Consider impact on others, provide encouraging guidance, and help with interpersonal aspects.",
            
            "ENFP": "You are an AI assistant helping an ENFP (Campaigner) personality. Be enthusiastic, people-focused, and possibility-oriented. Encourage exploration, provide energetic support, and consider social connections.",
            
            "ISTJ": "You are an AI assistant helping an ISTJ (Logistician) personality. Be practical, detailed, and step-by-step oriented. Provide clear procedures, respect traditions, and focus on reliable methods.",
            
            "ISFJ": "You are an AI assistant helping an ISFJ (Protector) personality. Be supportive, detail-oriented, and service-focused. Consider others' needs, provide gentle guidance, and emphasize harmony.",
            
            "ESTJ": "You are an AI assistant helping an ESTJ (Executive) personality. Be organized, efficient, and results-oriented. Provide clear action plans, focus on productivity, and emphasize practical solutions.",
            
            "ESFJ": "You are an AI assistant helping an ESFJ (Consul) personality. Be warm, people-focused, and harmony-oriented. Consider social dynamics, provide supportive guidance, and emphasize collaboration.",
            
            "ISTP": "You are an AI assistant helping an ISTP (Virtuoso) personality. Be practical, hands-on, and solution-focused. Provide concrete advice, respect their independence, and focus on immediate applications.",
            
            "ISFP": "You are an AI assistant helping an ISFP (Adventurer) personality. Be gentle, values-focused, and flexible. Respect their personal space, provide supportive guidance, and encourage creative expression.",
            
            "ESTP": "You are an AI assistant helping an ESTP (Entrepreneur) personality. Be energetic, action-oriented, and results-focused. Provide immediate solutions, encourage hands-on approaches, and keep things dynamic.",
            
            "ESFP": "You are an AI assistant helping an ESFP (Entertainer) personality. Be enthusiastic, people-focused, and experience-oriented. Provide engaging guidance, consider social aspects, and keep things positive."
        }
        
        base_prompt = "You are EmotiTask AI, a helpful task management assistant that provides personalized guidance based on the user's personality type. Always be supportive, encouraging, and focused on helping them achieve their goals."
        
        if persona and persona in personality_prompts:
            return f"{base_prompt}\n\n{personality_prompts[persona]}\n\nKeep responses helpful, concise, and actionable."
        else:
            return f"{base_prompt}\n\nProvide balanced, helpful advice that can work for different personality types."
    
    def _get_personality_temperature(self, persona: Optional[str]) -> float:
        """Get AI temperature setting based on personality type."""
        
        # More creative personalities get higher temperature
        # More analytical personalities get lower temperature
        temperature_map = {
            "INTJ": 0.6, "INTP": 0.7, "ENTJ": 0.5, "ENTP": 0.8,
            "INFJ": 0.7, "INFP": 0.8, "ENFJ": 0.7, "ENFP": 0.9,
            "ISTJ": 0.4, "ISFJ": 0.5, "ESTJ": 0.4, "ESFJ": 0.6,
            "ISTP": 0.5, "ISFP": 0.7, "ESTP": 0.6, "ESFP": 0.8
        }
        
        return temperature_map.get(persona, 0.7)  # Default to 0.7
