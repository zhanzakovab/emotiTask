from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from app.models import Goal, GoalCreate, GoalUpdate, GoalsResponse
from app.auth import get_current_user_id
from app.database import db
from datetime import datetime

router = APIRouter(prefix="/goals", tags=["goals"])

@router.post("/", response_model=Goal, status_code=status.HTTP_201_CREATED)
async def create_goal(
    goal: GoalCreate,
    user_id: str = Depends(get_current_user_id)
):
    """Create a new goal"""
    try:
        goal_data = goal.model_dump()
        goal_data["target_date"] = goal_data["target_date"].isoformat()
        
        created_goal = await db.create_goal(user_id, goal_data)
        return created_goal
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create goal: {str(e)}"
        )

@router.get("/", response_model=GoalsResponse)
async def get_goals(
    user_id: str = Depends(get_current_user_id)
):
    """Get all goals for the current user"""
    try:
        goals = await db.get_goals(user_id)
        return GoalsResponse(goals=goals, total=len(goals))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to fetch goals: {str(e)}"
        )

@router.get("/{goal_id}", response_model=Goal)
async def get_goal(
    goal_id: str,
    user_id: str = Depends(get_current_user_id)
):
    """Get a specific goal"""
    try:
        goal = await db.get_goal(user_id, goal_id)
        if not goal:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Goal not found"
            )
        return goal
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to fetch goal: {str(e)}"
        )

@router.put("/{goal_id}", response_model=Goal)
async def update_goal(
    goal_id: str,
    goal_update: GoalUpdate,
    user_id: str = Depends(get_current_user_id)
):
    """Update a goal"""
    try:
        # Check if goal exists
        existing_goal = await db.get_goal(user_id, goal_id)
        if not existing_goal:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Goal not found"
            )
        
        # Prepare update data
        update_data = goal_update.model_dump(exclude_unset=True)
        if "target_date" in update_data and update_data["target_date"]:
            update_data["target_date"] = update_data["target_date"].isoformat()
        update_data["updated_at"] = datetime.now().isoformat()
        
        updated_goal = await db.update_goal(user_id, goal_id, update_data)
        return updated_goal
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update goal: {str(e)}"
        )

@router.delete("/{goal_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_goal(
    goal_id: str,
    user_id: str = Depends(get_current_user_id)
):
    """Delete a goal"""
    try:
        # Check if goal exists
        existing_goal = await db.get_goal(user_id, goal_id)
        if not existing_goal:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Goal not found"
            )
        
        success = await db.delete_goal(user_id, goal_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to delete goal"
            )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to delete goal: {str(e)}"
        )

@router.patch("/{goal_id}/progress", response_model=Goal)
async def update_goal_progress(
    goal_id: str,
    progress: float,
    user_id: str = Depends(get_current_user_id)
):
    """Update goal progress"""
    try:
        # Validate progress value
        if not 0.0 <= progress <= 1.0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Progress must be between 0.0 and 1.0"
            )
        
        # Check if goal exists
        existing_goal = await db.get_goal(user_id, goal_id)
        if not existing_goal:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Goal not found"
            )
        
        # Update progress
        update_data = {
            "progress": progress,
            "updated_at": datetime.now().isoformat()
        }
        
        updated_goal = await db.update_goal(user_id, goal_id, update_data)
        return updated_goal
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update goal progress: {str(e)}"
        ) 