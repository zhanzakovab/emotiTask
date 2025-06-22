from fastapi import APIRouter, Depends, HTTPException, status
from app.models import ChatMessage, ChatResponse, ChatRequest, ChatData, ChatHistoryResponse
from app.auth import get_current_user_id
from app.database import db
from app.config import settings
from typing import List, Dict, Any, Optional
import json
import uuid
from datetime import datetime
from app.openai_service import OpenAIService

router = APIRouter(prefix="/chat", tags=["chat"])

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
    """Generate response using OpenAI GPT - DEPRECATED: Use OpenAI service instead"""
    # This function is deprecated - the OpenAI service handles responses now
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

@router.get("/history/{user_id}", response_model=ChatHistoryResponse)
async def get_chat_history(user_id: str):
    """Get chat history for a user."""
    try:
        if not db.configured:
            return ChatHistoryResponse(exists=False)
        
        # Get existing chat data for user
        response = db.client.table("chat_data").select("*").eq("user_id", user_id).execute()
        
        if response.data:
            chat_record = response.data[0]
            
            # Parse messages from JSONB
            messages = []
            for msg_data in chat_record.get("messages", []):
                messages.append(ChatMessage(
                    role=msg_data["role"],
                    content=msg_data["content"],
                    timestamp=msg_data["timestamp"]
                ))
            
            chat_data = ChatData(
                id=chat_record["id"],
                user_id=chat_record["user_id"],
                messages=messages,
                created_at=chat_record["created_at"],
                updated_at=chat_record["updated_at"]
            )
            
            return ChatHistoryResponse(chat_data=chat_data, exists=True)
        else:
            return ChatHistoryResponse(exists=False)
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get chat history: {str(e)}")

@router.post("/send", response_model=ChatResponse)
async def send_chat_message(request: ChatRequest):
    """Send a chat message and get AI response."""
    try:
        if not db.configured:
            # Mock response for development
            mock_response = "I'm here to help! (Development mode - database not configured)"
            mock_chat_data = ChatData(
                id=str(uuid.uuid4()),
                user_id=request.user_id,
                messages=[
                    ChatMessage(role="user", content=request.message, timestamp=datetime.now().isoformat()),
                    ChatMessage(role="assistant", content=mock_response, timestamp=datetime.now().isoformat())
                ],
                created_at=datetime.now().isoformat(),
                updated_at=datetime.now().isoformat()
            )
            return ChatResponse(message=mock_response, chat_data=mock_chat_data)
        
        # Get or create chat data for user
        chat_response = db.client.table("chat_data").select("*").eq("user_id", request.user_id).execute()
        
        current_messages = []
        chat_id = None
        
        if chat_response.data:
            # Existing chat found
            chat_record = chat_response.data[0]
            chat_id = chat_record["id"]
            current_messages = chat_record.get("messages", [])
            print(f"📱 Found existing chat for user {request.user_id} with {len(current_messages)} messages")
        else:
            # Create new chat
            chat_id = str(uuid.uuid4())
            print(f"🆕 Creating new chat for user {request.user_id}")
        
        # Add user message to conversation
        user_message = {
            "role": "user",
            "content": request.message,
            "timestamp": datetime.now().isoformat()
        }
        current_messages.append(user_message)
        
        # Get user's personality type for personalized AI response
        user_persona = await get_user_personality(request.user_id)
        
        # Generate AI response using OpenAI
        openai_service = OpenAIService()
        ai_response = await openai_service.generate_chat_response(
            messages=current_messages,
            user_persona=user_persona
        )
        
        # Add AI response to conversation
        ai_message = {
            "role": "assistant", 
            "content": ai_response,
            "timestamp": datetime.now().isoformat()
        }
        current_messages.append(ai_message)
        
        # Save updated chat data to database
        if chat_response.data:
            # Update existing chat
            update_result = db.client.table("chat_data").update({
                "messages": current_messages,
                "updated_at": datetime.now().isoformat()
            }).eq("user_id", request.user_id).execute()
            
            if update_result.data:
                updated_record = update_result.data[0]
                print(f"✅ Updated chat for user {request.user_id}")
            else:
                raise Exception("Failed to update chat data")
        else:
            # Create new chat
            insert_result = db.client.table("chat_data").insert({
                "id": chat_id,
                "user_id": request.user_id,
                "messages": current_messages,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }).execute()
            
            if insert_result.data:
                updated_record = insert_result.data[0]
                print(f"✅ Created new chat for user {request.user_id}")
            else:
                raise Exception("Failed to create chat data")
        
        # Convert messages to ChatMessage objects
        messages_objects = []
        for msg in current_messages:
            messages_objects.append(ChatMessage(
                role=msg["role"],
                content=msg["content"],
                timestamp=msg["timestamp"]
            ))
        
        # Return response with updated chat data
        chat_data = ChatData(
            id=updated_record["id"],
            user_id=updated_record["user_id"],
            messages=messages_objects,
            created_at=updated_record["created_at"],
            updated_at=updated_record["updated_at"]
        )
        
        return ChatResponse(message=ai_response, chat_data=chat_data)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send chat message: {str(e)}")

async def get_user_personality(user_id: str) -> Optional[str]:
    """Get user's personality type for personalized AI responses."""
    try:
        if not db.configured:
            return "INTJ"  # Default for development
        
        user_response = db.client.table("user_profiles").select("persona_id").eq("id", user_id).execute()
        
        if user_response.data:
            return user_response.data[0].get("persona_id", "INTJ")
        else:
            return "INTJ"  # Default fallback
            
    except Exception as e:
        print(f"⚠️ Failed to get user personality: {e}")
        return "INTJ"  # Default fallback

@router.delete("/clear/{user_id}")
async def clear_chat_history(user_id: str):
    """Clear chat history for a user."""
    try:
        if not db.configured:
            return {"message": "Chat cleared (development mode)"}
        
        # Delete chat data for user
        result = db.client.table("chat_data").delete().eq("user_id", user_id).execute()
        
        return {"message": "Chat history cleared successfully"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to clear chat history: {str(e)}") 