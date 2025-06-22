from fastapi import APIRouter, HTTPException, Depends
from typing import List
import json
import uuid
from datetime import datetime
from ..database import db
from ..models import (
    QuestionsResponse, PersonalityTypesResponse, AnswersResponse, ChatStylesResponse,
    Question, Answer, PersonalityType, ChatStyle, QuestionWithAnswers,
    PersonalityTypeWithChatStyle, AssessmentSubmission, AssessmentResult,
    AssessmentSubmissionWithUser, UserProfile, UserCreationData
)
from ..mbti_calculator import MBTICalculator

router = APIRouter(prefix="/mbti", tags=["MBTI"])

@router.get("/questions", response_model=QuestionsResponse)
async def get_questions():
    """Get all MBTI assessment questions with their answers."""
    try:
        if not db.configured:
            # Return mock data for development
            from datetime import datetime
            now = datetime.now().isoformat()
            
            mock_questions = [
                QuestionWithAnswers(
                    id=1,
                    question="When making decisions, do you prefer to rely on logic and objective analysis, or do you consider personal values and how decisions affect people?",
                    created_at=now,
                    updated_at=now,
                    answers=[
                        Answer(id=1, question_id=1, answer="I rely primarily on logic and objective analysis, setting aside personal feelings", created_at=now, updated_at=now),
                        Answer(id=2, question_id=1, answer="I consider both logic and personal values, but logic usually wins", created_at=now, updated_at=now),
                        Answer(id=3, question_id=1, answer="I consider both logic and personal values, but personal impact usually wins", created_at=now, updated_at=now),
                        Answer(id=4, question_id=1, answer="I prioritize personal values and how decisions affect people over pure logic", created_at=now, updated_at=now)
                    ]
                ),
                QuestionWithAnswers(
                    id=2,
                    question="Do you prefer to focus on the big picture and future possibilities, or do you prefer to focus on concrete details and present realities?",
                    created_at=now,
                    updated_at=now,
                    answers=[
                        Answer(id=5, question_id=2, answer="I focus almost entirely on future possibilities and big picture thinking", created_at=now, updated_at=now),
                        Answer(id=6, question_id=2, answer="I prefer big picture but also pay attention to important details", created_at=now, updated_at=now),
                        Answer(id=7, question_id=2, answer="I prefer concrete details but also consider future implications", created_at=now, updated_at=now),
                        Answer(id=8, question_id=2, answer="I focus primarily on concrete details and present realities", created_at=now, updated_at=now)
                    ]
                ),
                QuestionWithAnswers(
                    id=3,
                    question="When working on projects, do you prefer to have a clear plan and stick to it, or do you prefer to keep your options open and adapt as you go?",
                    created_at=now,
                    updated_at=now,
                    answers=[
                        Answer(id=9, question_id=3, answer="I strongly prefer having a clear plan and sticking to it", created_at=now, updated_at=now),
                        Answer(id=10, question_id=3, answer="I like having a plan but am comfortable with minor adjustments", created_at=now, updated_at=now),
                        Answer(id=11, question_id=3, answer="I prefer flexibility but appreciate having some structure", created_at=now, updated_at=now),
                        Answer(id=12, question_id=3, answer="I strongly prefer keeping options open and adapting as I go", created_at=now, updated_at=now)
                    ]
                )
            ]
            
            return QuestionsResponse(
                questions=mock_questions,
                total=len(mock_questions)
            )
        
        # Get all questions from Supabase
        questions_response = db.client.table("questions").select("*").order("id").execute()
        questions_data = questions_response.data or []
        
        questions_with_answers = []
        
        for question_data in questions_data:
            # Get answers for each question
            answers_response = db.client.table("answers").select("*").eq("question_id", question_data["id"]).order("id").execute()
            answers_data = answers_response.data or []
            
            answers = [
                Answer(
                    id=answer_data["id"],
                    question_id=answer_data["question_id"],
                    answer=answer_data["answer"],
                    created_at=answer_data["created_at"],
                    updated_at=answer_data["updated_at"]
                )
                for answer_data in answers_data
            ]
            
            question_with_answers = QuestionWithAnswers(
                id=question_data["id"],
                question=question_data["question"],
                created_at=question_data["created_at"],
                updated_at=question_data["updated_at"],
                answers=answers
            )
            questions_with_answers.append(question_with_answers)
        
        return QuestionsResponse(
            questions=questions_with_answers,
            total=len(questions_with_answers)
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch questions: {str(e)}")

@router.get("/personality-types", response_model=PersonalityTypesResponse)
async def get_personality_types():
    """Get all MBTI personality types with their chat styles."""
    try:
        if not db.configured:
            # Return mock data for development
            from datetime import datetime
            now = datetime.now().isoformat()
            
            mock_types = [
                PersonalityTypeWithChatStyle(
                    id=1,
                    persona_id="INTJ",
                    name="The Architect",
                    description="Strategic and imaginative, you prefer to work independently and think several steps ahead.",
                    created_at=now,
                    updated_at=now,
                    chat_styles=[
                        ChatStyle(id=1, personality_type_id=1, keywords="strategic,analytical,independent,systematic", temperature=0.7, created_at=now, updated_at=now)
                    ]
                ),
                PersonalityTypeWithChatStyle(
                    id=2,
                    persona_id="ENFP",
                    name="The Campaigner",
                    description="Enthusiastic and creative, you thrive in dynamic environments with lots of possibilities.",
                    created_at=now,
                    updated_at=now,
                    chat_styles=[
                        ChatStyle(id=2, personality_type_id=2, keywords="enthusiastic,creative,collaborative,inspiring", temperature=0.9, created_at=now, updated_at=now)
                    ]
                )
            ]
            
            return PersonalityTypesResponse(
                personality_types=mock_types,
                total=len(mock_types)
            )
        
        # Get all personality types from Supabase
        types_response = db.client.table("personality_types").select("*").order("persona_id").execute()
        types_data = types_response.data or []
        
        types_with_chat_styles = []
        
        for type_data in types_data:
            # Get chat styles for each personality type
            chat_styles_response = db.client.table("chat_styles").select("*").eq("personality_type_id", type_data["id"]).execute()
            chat_styles_data = chat_styles_response.data or []
            
            chat_styles = [
                ChatStyle(
                    id=style_data["id"],
                    personality_type_id=style_data["personality_type_id"],
                    keywords=style_data.get("keywords"),
                    temperature=float(style_data["temperature"]),
                    created_at=style_data["created_at"],
                    updated_at=style_data["updated_at"]
                )
                for style_data in chat_styles_data
            ]
            
            type_with_chat_style = PersonalityTypeWithChatStyle(
                id=type_data["id"],
                persona_id=type_data["persona_id"],
                name=type_data["name"],
                description=type_data.get("description"),
                created_at=type_data["created_at"],
                updated_at=type_data["updated_at"],
                chat_styles=chat_styles
            )
            types_with_chat_styles.append(type_with_chat_style)
        
        return PersonalityTypesResponse(
            personality_types=types_with_chat_styles,
            total=len(types_with_chat_styles)
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch personality types: {str(e)}")

@router.post("/assess", response_model=AssessmentResult)
async def assess_personality(assessment: AssessmentSubmission):
    """Assess personality type based on answers."""
    try:
        if not db.configured:
            # Return mock assessment result for development
            from datetime import datetime
            now = datetime.now().isoformat()
            
            mock_result = AssessmentResult(
                personality_type=PersonalityType(
                    id=1,
                    persona_id="INTJ",
                    name="The Architect",
                    description="Strategic and imaginative, you prefer to work independently and think several steps ahead.",
                    created_at=now,
                    updated_at=now
                ),
                chat_style=ChatStyle(
                    id=1,
                    personality_type_id=1,
                    keywords="strategic,analytical,independent,systematic",
                    temperature=0.7,
                    created_at=now,
                    updated_at=now
                ),
                confidence_score=0.85
            )
            
            return mock_result

        # Use the sophisticated MBTI calculator
        personality_code, confidence_score = MBTICalculator.calculate_personality_type(assessment.answers)
        
        print(f"🧠 Calculated personality type: {personality_code} (confidence: {confidence_score:.2f})")
        
        # Get the personality type from database
        type_response = db.client.table("personality_types").select("*").eq("persona_id", personality_code).execute()
        type_data = type_response.data
        
        if not type_data:
            # Fallback to a default type if calculation result not found
            print(f"⚠️ Personality type {personality_code} not found, falling back to INTJ")
            personality_code = "INTJ"
            type_response = db.client.table("personality_types").select("*").eq("persona_id", personality_code).execute()
            type_data = type_response.data
        
        if not type_data:
            raise HTTPException(status_code=500, detail="No personality types found in database")
        
        type_info = type_data[0]
        
        # Get chat style
        chat_style_response = db.client.table("chat_styles").select("*").eq("personality_type_id", type_info["id"]).execute()
        chat_style_data = chat_style_response.data
        
        if not chat_style_data:
            raise HTTPException(status_code=500, detail="No chat style found for personality type")
        
        chat_style_info = chat_style_data[0]
        
        return AssessmentResult(
            personality_type=PersonalityType(
                id=type_info["id"],
                persona_id=type_info["persona_id"],
                name=type_info["name"],
                description=type_info.get("description"),
                created_at=type_info["created_at"],
                updated_at=type_info["updated_at"]
            ),
            chat_style=ChatStyle(
                id=chat_style_info["id"],
                personality_type_id=chat_style_info["personality_type_id"],
                keywords=chat_style_info.get("keywords"),
                temperature=float(chat_style_info["temperature"]),
                created_at=chat_style_info["created_at"],
                updated_at=chat_style_info["updated_at"]
            ),
            confidence_score=confidence_score
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to assess personality: {str(e)}")

@router.post("/assess-and-create-user", response_model=AssessmentResult)
async def assess_and_create_user_profile(assessment: AssessmentSubmissionWithUser):
    """
    Assess personality type and create user profile with persona_id connection.
    This is the main endpoint for the onboarding flow.
    """
    try:
        if not db.configured:
            # Return mock result for development
            now = datetime.now().isoformat()
            mock_user_id = str(uuid.uuid4())
            
            mock_result = AssessmentResult(
                personality_type=PersonalityType(
                    id=1,
                    persona_id="INTJ",
                    name="The Architect",
                    description="Strategic and imaginative, you prefer to work independently and think several steps ahead.",
                    created_at=now,
                    updated_at=now
                ),
                chat_style=ChatStyle(
                    id=1,
                    personality_type_id=1,
                    keywords="strategic,analytical,independent,systematic",
                    temperature=0.7,
                    created_at=now,
                    updated_at=now
                ),
                confidence_score=0.85,
                user_profile=UserProfile(
                    id=mock_user_id,
                    persona_id="INTJ",
                    created_at=now,
                    updated_at=now
                )
            )
            
            return mock_result

        # Step 1: Calculate personality type using sophisticated algorithm
        personality_code, confidence_score = MBTICalculator.calculate_personality_type(assessment.answers)
        
        print(f"🧠 Calculated personality type: {personality_code} (confidence: {confidence_score:.2f})")
        
        # Step 2: Get personality type details from database
        type_response = db.client.table("personality_types").select("*").eq("persona_id", personality_code).execute()
        type_data = type_response.data
        
        if not type_data:
            # Fallback to INTJ if calculated type not found
            print(f"⚠️ Personality type {personality_code} not found, falling back to INTJ")
            personality_code = "INTJ"
            type_response = db.client.table("personality_types").select("*").eq("persona_id", personality_code).execute()
            type_data = type_response.data
        
        if not type_data:
            raise HTTPException(status_code=500, detail="No personality types found in database")
        
        type_info = type_data[0]
        
        # Step 3: Get chat style for the personality type
        chat_style_response = db.client.table("chat_styles").select("*").eq("personality_type_id", type_info["id"]).execute()
        chat_style_data = chat_style_response.data
        
        if not chat_style_data:
            raise HTTPException(status_code=500, detail="No chat style found for personality type")
        
        chat_style_info = chat_style_data[0]
        
        # Step 4: Create or update user profile
        user_profile = None
        
        if assessment.user_id:
            # Update existing user profile
            try:
                update_response = db.client.table("user_profiles").update({
                    "persona_id": personality_code,
                    "updated_at": datetime.now().isoformat()
                }).eq("id", assessment.user_id).execute()
                
                if update_response.data:
                    profile_data = update_response.data[0]
                    user_profile = UserProfile(
                        id=profile_data["id"],
                        persona_id=profile_data["persona_id"],
                        created_at=profile_data["created_at"],
                        updated_at=profile_data["updated_at"]
                    )
                    print(f"✅ Updated user profile {assessment.user_id} with persona_id: {personality_code}")
                
            except Exception as e:
                print(f"⚠️ Failed to update user profile: {e}")
        
        elif assessment.user_data:
            # Create new user profile
            try:
                new_user_id = str(uuid.uuid4())
                
                insert_response = db.client.table("user_profiles").insert({
                    "id": new_user_id,
                    "persona_id": personality_code,
                    "created_at": datetime.now().isoformat(),
                    "updated_at": datetime.now().isoformat()
                }).execute()
                
                if insert_response.data:
                    profile_data = insert_response.data[0]
                    user_profile = UserProfile(
                        id=profile_data["id"],
                        persona_id=profile_data["persona_id"],
                        created_at=profile_data["created_at"],
                        updated_at=profile_data["updated_at"]
                    )
                    print(f"✅ Created new user profile {new_user_id} with persona_id: {personality_code}")
                
            except Exception as e:
                print(f"⚠️ Failed to create user profile: {e}")
        
        # Step 5: Return complete assessment result
        return AssessmentResult(
            personality_type=PersonalityType(
                id=type_info["id"],
                persona_id=type_info["persona_id"],
                name=type_info["name"],
                description=type_info.get("description"),
                created_at=type_info["created_at"],
                updated_at=type_info["updated_at"]
            ),
            chat_style=ChatStyle(
                id=chat_style_info["id"],
                personality_type_id=chat_style_info["personality_type_id"],
                keywords=chat_style_info.get("keywords"),
                temperature=float(chat_style_info["temperature"]),
                created_at=chat_style_info["created_at"],
                updated_at=chat_style_info["updated_at"]
            ),
            confidence_score=confidence_score,
            user_profile=user_profile
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to assess and create user: {str(e)}")

# Simplified endpoints for basic functionality
@router.get("/personality-types/{persona_id}")
async def get_personality_type_by_id(persona_id: str):
    """Get a specific MBTI personality type by persona_id (e.g., 'INTJ')."""
    try:
        if not db.configured:
            from datetime import datetime
            now = datetime.now().isoformat()
            
            return {
                "id": 1,
                "persona_id": persona_id,
                "name": f"The {persona_id} Type",
                "description": f"Mock description for {persona_id}",
                "created_at": now,
                "updated_at": now
            }
        
        type_response = db.client.table("personality_types").select("*").eq("persona_id", persona_id).execute()
        type_data = type_response.data
        
        if not type_data:
            raise HTTPException(status_code=404, detail=f"Personality type '{persona_id}' not found")
        
        return type_data[0]
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch personality type: {str(e)}")

@router.get("/answers/question/{question_id}")
async def get_answers_by_question(question_id: int):
    """Get all answers for a specific question."""
    try:
        if not db.configured:
            from datetime import datetime
            now = datetime.now().isoformat()
            
            mock_answers = [
                {"id": i, "question_id": question_id, "answer": f"Mock answer {i}", "created_at": now, "updated_at": now}
                for i in range(1, 5)
            ]
            
            return {"answers": mock_answers, "total": len(mock_answers)}
        
        answers_response = db.client.table("answers").select("*").eq("question_id", question_id).order("id").execute()
        answers_data = answers_response.data or []
        
        return {"answers": answers_data, "total": len(answers_data)}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch answers: {str(e)}")

@router.get("/chat-styles")
async def get_all_chat_styles():
    """Get all chat styles."""
    try:
        if not db.configured:
            from datetime import datetime
            now = datetime.now().isoformat()
            
            mock_styles = [
                {"id": 1, "personality_type_id": 1, "keywords": "strategic,analytical", "temperature": 0.7, "created_at": now, "updated_at": now},
                {"id": 2, "personality_type_id": 2, "keywords": "enthusiastic,creative", "temperature": 0.9, "created_at": now, "updated_at": now}
            ]
            
            return {"chat_styles": mock_styles, "total": len(mock_styles)}
        
        styles_response = db.client.table("chat_styles").select("*").execute()
        styles_data = styles_response.data or []
        
        return {"chat_styles": styles_data, "total": len(styles_data)}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch chat styles: {str(e)}") 