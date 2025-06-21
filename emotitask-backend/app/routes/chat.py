from fastapi import APIRouter, Depends, HTTPException, status
from app.models import ChatMessage, ChatResponse
from app.auth import get_current_user_id
from app.database import db
from app.config import settings
import openai
from typing import List, Dict, Any

router = APIRouter(prefix="/chat", tags=["chat"])

# Initialize OpenAI client if API key is available
if settings.OPENAI_API_KEY:
    openai.api_key = settings.OPENAI_API_KEY

@router.post("/message", response_model=ChatResponse)
async def send_chat_message(
    message: ChatMessage,
    user_id: str = Depends(get_current_user_id)
):
    """Send a message to the AI chat assistant"""
    try:
        # Get user profile for personalization
        profile = await db.get_user_profile(user_id)
        personality_type = profile.get("personality_type", "Balanced") if profile else "Balanced"
        
        # Get user's recent tasks for context
        tasks = await db.get_tasks(user_id)
        today_tasks = [task for task in tasks if not task.get("is_completed", False)]
        
        # Build context
        context = {
            "personality_type": personality_type,
            "active_tasks": len(today_tasks),
            "completed_today": len([t for t in tasks if t.get("is_completed", False)]),
            "user_context": message.context or {}
        }
        
        # Generate AI response
        if settings.OPENAI_API_KEY:
            ai_response = await generate_openai_response(message.message, context, today_tasks)
        else:
            ai_response = generate_dummy_response(message.message, context)
        
        # Generate task suggestions based on message
        suggestions = await generate_task_suggestions(message.message, today_tasks, personality_type)
        
        return ChatResponse(
            response=ai_response,
            suggestions=suggestions
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to process chat message: {str(e)}"
        )

async def generate_openai_response(message: str, context: Dict[str, Any], tasks: List[Dict]) -> str:
    """Generate response using OpenAI GPT"""
    try:
        # Build system prompt
        system_prompt = f"""
        You are EmotiTask, an emotionally intelligent task management assistant. 
        
        User Profile:
        - Personality Type: {context['personality_type']}
        - Active Tasks: {context['active_tasks']}
        - Completed Today: {context['completed_today']}
        
        Your role is to:
        1. Provide emotional support and encouragement
        2. Help with task management and productivity
        3. Adapt your communication style to the user's personality
        4. Be warm, understanding, and helpful
        5. Keep responses concise but meaningful
        
        Respond naturally and empathetically to the user's message.
        """
        
        # Create chat completion
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": message}
            ],
            max_tokens=150,
            temperature=0.7
        )
        
        return response.choices[0].message.content.strip()
        
    except Exception as e:
        print(f"OpenAI API error: {e}")
        return generate_dummy_response(message, context)

def generate_dummy_response(message: str, context: Dict[str, Any]) -> str:
    """Generate a dummy response when OpenAI is not available"""
    message_lower = message.lower()
    
    responses = {
        "overwhelmed": f"I understand you're feeling overwhelmed. With {context['active_tasks']} active tasks, that's completely normal. Let's break things down into smaller, manageable steps.",
        "stressed": "Stress can be challenging. Remember that you've already completed {context['completed_today']} tasks today - that's progress! What's the most important thing you need to focus on right now?",
        "tired": "It sounds like you might need a break. Your well-being is just as important as your productivity. Have you considered scheduling some self-care time?",
        "motivated": f"I love your energy! With {context['active_tasks']} tasks ahead, your motivation will serve you well. What would you like to tackle first?",
        "help": f"I'm here to help! Based on your {context['personality_type']} personality type, I can suggest the best approach for your current tasks."
    }
    
    # Find matching response
    for keyword, response in responses.items():
        if keyword in message_lower:
            return response.format(**context)
    
    # Default response
    return f"Thank you for sharing that with me. As someone with a {context['personality_type']} personality type, you have unique strengths. How can I help you make progress on your goals today?"

async def generate_task_suggestions(message: str, tasks: List[Dict], personality_type: str) -> List[Dict[str, Any]]:
    """Generate task-related suggestions based on the message"""
    suggestions = []
    message_lower = message.lower()
    
    # Analyze message for emotional context
    if any(word in message_lower for word in ["overwhelmed", "stressed", "too much"]):
        # Suggest rescheduling or breaking down tasks
        urgent_tasks = [t for t in tasks if t.get("priority") in ["High", "Urgent"]]
        if urgent_tasks:
            suggestions.append({
                "type": "reschedule",
                "message": "Would you like me to help reschedule some lower-priority tasks to reduce your workload?",
                "task_id": urgent_tasks[0].get("id"),
                "action": "reschedule_low_priority"
            })
        
        suggestions.append({
            "type": "self_care",
            "message": "How about adding a 10-minute mindfulness break to your schedule?",
            "action": "add_break"
        })
    
    elif any(word in message_lower for word in ["tired", "exhausted", "energy"]):
        # Suggest energy-appropriate tasks
        low_energy_tasks = [t for t in tasks if t.get("emotional_tag") == "low energy"]
        if low_energy_tasks:
            suggestions.append({
                "type": "prioritize",
                "message": "I can prioritize your low-energy tasks for now. Would that help?",
                "task_id": low_energy_tasks[0].get("id"),
                "action": "prioritize_low_energy"
            })
    
    elif any(word in message_lower for word in ["focus", "concentrate", "important"]):
        # Suggest focus tasks
        focus_tasks = [t for t in tasks if t.get("emotional_tag") == "focus"]
        if focus_tasks:
            suggestions.append({
                "type": "focus",
                "message": "I see you have some focus-intensive tasks. Should we tackle those while you're in the zone?",
                "task_id": focus_tasks[0].get("id"),
                "action": "prioritize_focus"
            })
    
    return suggestions[:2]  # Limit to 2 suggestions

@router.get("/suggestions")
async def get_task_suggestions(user_id: str = Depends(get_current_user_id)):
    """Get general task suggestions for the user"""
    try:
        tasks = await db.get_tasks(user_id)
        profile = await db.get_user_profile(user_id)
        personality_type = profile.get("personality_type", "Balanced") if profile else "Balanced"
        
        # Generate contextual suggestions
        suggestions = await generate_contextual_suggestions(tasks, personality_type)
        
        return {"suggestions": suggestions}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to generate suggestions: {str(e)}"
        )

async def generate_contextual_suggestions(tasks: List[Dict], personality_type: str) -> List[Dict[str, Any]]:
    """Generate contextual suggestions based on current tasks and personality"""
    suggestions = []
    
    incomplete_tasks = [t for t in tasks if not t.get("is_completed", False)]
    
    if len(incomplete_tasks) > 10:
        suggestions.append({
            "type": "organization",
            "message": f"You have {len(incomplete_tasks)} active tasks. Would you like help organizing them by priority?",
            "action": "organize_by_priority"
        })
    
    # Personality-based suggestions
    if personality_type == "Explorer":
        suggestions.append({
            "type": "variety",
            "message": "As an Explorer, you might enjoy mixing different types of tasks. Want me to suggest a varied schedule?",
            "action": "create_varied_schedule"
        })
    elif personality_type == "Analyst":
        suggestions.append({
            "type": "planning",
            "message": "Would you like me to help create a detailed plan for your upcoming tasks?",
            "action": "create_detailed_plan"
        })
    
    return suggestions 