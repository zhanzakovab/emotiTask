from pydantic import BaseModel, Field, EmailStr
from typing import Optional, List
from datetime import datetime
from enum import Enum
import uuid

# Enums matching SwiftUI
class EmotionalTag(str, Enum):
    LOW_ENERGY = "low energy"
    FOCUS = "focus"
    TIME_SENSITIVE = "time sensitive"
    CREATIVE = "creative"
    SOCIAL = "social"
    SELF_CARE = "self care"
    ROUTINE = "routine"
    CHALLENGING = "challenging"

class TaskPriority(str, Enum):
    LOW = "Low"
    MEDIUM = "Medium"
    HIGH = "High"
    URGENT = "Urgent"

class GoalCategory(str, Enum):
    WELLNESS = "Wellness"
    CAREER = "Career"
    RELATIONSHIPS = "Relationships"
    LEARNING = "Learning"
    FITNESS = "Fitness"
    CREATIVITY = "Creativity"
    FINANCE = "Finance"
    HOME = "Home"

# Base Models
class BaseResponse(BaseModel):
    id: str
    created_at: datetime
    updated_at: datetime

# User Models
class UserProfile(BaseModel):
    id: str
    persona_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime

class UserProfileUpdate(BaseModel):
    persona_id: Optional[str] = None

# Task Models
class TaskBase(BaseModel):
    title: str
    notes: Optional[str] = ""
    is_completed: bool = False
    emotional_tag: Optional[EmotionalTag] = None
    scheduled_date: datetime
    priority: TaskPriority = TaskPriority.MEDIUM
    estimated_duration: int = 30
    project_id: Optional[str] = None

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    notes: Optional[str] = None
    is_completed: Optional[bool] = None
    emotional_tag: Optional[EmotionalTag] = None
    scheduled_date: Optional[datetime] = None
    priority: Optional[TaskPriority] = None
    estimated_duration: Optional[int] = None
    project_id: Optional[str] = None

class Task(TaskBase, BaseResponse):
    user_id: str

# Project Models
class ProjectBase(BaseModel):
    title: str
    description: Optional[str] = ""
    color: str = "blue"
    icon: str = "folder.fill"

class ProjectCreate(ProjectBase):
    pass

class ProjectUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    color: Optional[str] = None
    icon: Optional[str] = None

class Project(ProjectBase, BaseResponse):
    user_id: str

# Goal Models
class GoalBase(BaseModel):
    title: str
    description: Optional[str] = ""
    target_date: datetime
    progress: float = 0.0
    category: GoalCategory = GoalCategory.WELLNESS

class GoalCreate(GoalBase):
    pass

class GoalUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    target_date: Optional[datetime] = None
    progress: Optional[float] = None
    category: Optional[GoalCategory] = None

class Goal(GoalBase, BaseResponse):
    user_id: str

# Auth Models
class UserSignUp(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)

class UserSignIn(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int
    user: dict

# Response Models
class TasksResponse(BaseModel):
    tasks: List[Task]
    total: int

class ProjectsResponse(BaseModel):
    projects: List[Project]
    total: int

class GoalsResponse(BaseModel):
    goals: List[Goal]
    total: int

# AI Chat Models
class ChatMessage(BaseModel):
    role: str = Field(..., pattern="^(user|assistant|system)$")
    content: str
    timestamp: str

class ChatData(BaseModel):
    id: str
    user_id: str
    messages: List[ChatMessage]
    created_at: str
    updated_at: str

class ChatRequest(BaseModel):
    user_id: str
    message: str

class ChatResponse(BaseModel):
    message: str
    chat_data: ChatData

class ChatHistoryResponse(BaseModel):
    chat_data: Optional[ChatData] = None
    exists: bool = False

# MBTI Personality Models

# Base Models for MBTI system
class BaseIntResponse(BaseModel):
    id: int
    created_at: datetime
    updated_at: datetime

# Question Models
class QuestionBase(BaseModel):
    question: str

class QuestionCreate(QuestionBase):
    pass

class Question(QuestionBase, BaseIntResponse):
    pass

# Answer Models
class AnswerBase(BaseModel):
    question_id: int
    answer: str

class AnswerCreate(AnswerBase):
    pass

class Answer(AnswerBase, BaseIntResponse):
    pass

# Personality Type Models
class PersonalityTypeBase(BaseModel):
    persona_id: str = Field(..., max_length=10)  # e.g., "INTJ", "ENFP"
    name: str = Field(..., max_length=255)
    description: Optional[str] = None

class PersonalityTypeCreate(PersonalityTypeBase):
    pass

class PersonalityType(PersonalityTypeBase, BaseIntResponse):
    pass

# Chat Style Models
class ChatStyleBase(BaseModel):
    personality_type_id: int
    keywords: Optional[str] = None  # JSON string of keywords
    temperature: float = Field(default=0.7, ge=0.0, le=2.0)  # 0-2 range

class ChatStyleCreate(ChatStyleBase):
    pass

class ChatStyle(ChatStyleBase, BaseIntResponse):
    pass

# Extended models with relationships
class QuestionWithAnswers(Question):
    answers: List[Answer] = []

class PersonalityTypeWithChatStyle(PersonalityType):
    chat_styles: List[ChatStyle] = []

# Response Models for MBTI system
class QuestionsResponse(BaseModel):
    questions: List[QuestionWithAnswers]
    total: int

class PersonalityTypesResponse(BaseModel):
    personality_types: List[PersonalityTypeWithChatStyle]
    total: int

class AnswersResponse(BaseModel):
    answers: List[Answer]
    total: int

class ChatStylesResponse(BaseModel):
    chat_styles: List[ChatStyle]
    total: int

# MBTI Assessment Models with User Creation

class AssessmentAnswer(BaseModel):
    question_id: int
    answer_id: int

class UserCreationData(BaseModel):
    email: Optional[str] = None
    name: Optional[str] = None
    # Add other user fields as needed

class AssessmentSubmissionWithUser(BaseModel):
    answers: List[AssessmentAnswer]
    user_data: Optional[UserCreationData] = None
    user_id: Optional[str] = None  # If user already exists

class AssessmentSubmission(BaseModel):
    answers: List[AssessmentAnswer]

class AssessmentResult(BaseModel):
    personality_type: PersonalityType
    chat_style: ChatStyle
    confidence_score: float = Field(..., ge=0.0, le=1.0)
    user_profile: Optional[UserProfile] = None  # Include created user profile

# Error Response Model
class ErrorResponse(BaseModel):
    detail: str
    error_code: Optional[str] = None 