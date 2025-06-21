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
    personality_type: Optional[str] = None
    created_at: datetime
    updated_at: datetime

class UserProfileUpdate(BaseModel):
    personality_type: Optional[str] = None

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
    message: str
    context: Optional[dict] = None

class ChatResponse(BaseModel):
    response: str
    suggestions: Optional[List[dict]] = None

# Error Models
class ErrorResponse(BaseModel):
    detail: str
    error_code: Optional[str] = None 