from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from app.models import Task, TaskCreate, TaskUpdate, TasksResponse, ErrorResponse
from app.auth import get_current_user_id
from app.database import db
from datetime import datetime

router = APIRouter(prefix="/tasks", tags=["tasks"])

@router.post("/", response_model=Task, status_code=status.HTTP_201_CREATED)
async def create_task(
    task: TaskCreate,
    user_id: str = Depends(get_current_user_id)
):
    """Create a new task"""
    try:
        task_data = task.model_dump()
        task_data["scheduled_date"] = task_data["scheduled_date"].isoformat()
        
        created_task = await db.create_task(user_id, task_data)
        return created_task
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create task: {str(e)}"
        )

@router.get("/", response_model=TasksResponse)
async def get_tasks(
    user_id: str = Depends(get_current_user_id)
):
    """Get all tasks for the current user"""
    try:
        tasks = await db.get_tasks(user_id)
        return TasksResponse(tasks=tasks, total=len(tasks))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to fetch tasks: {str(e)}"
        )

@router.get("/{task_id}", response_model=Task)
async def get_task(
    task_id: str,
    user_id: str = Depends(get_current_user_id)
):
    """Get a specific task"""
    try:
        task = await db.get_task(user_id, task_id)
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        return task
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to fetch task: {str(e)}"
        )

@router.put("/{task_id}", response_model=Task)
async def update_task(
    task_id: str,
    task_update: TaskUpdate,
    user_id: str = Depends(get_current_user_id)
):
    """Update a task"""
    try:
        # Check if task exists
        existing_task = await db.get_task(user_id, task_id)
        if not existing_task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        # Prepare update data
        update_data = task_update.model_dump(exclude_unset=True)
        if "scheduled_date" in update_data and update_data["scheduled_date"]:
            update_data["scheduled_date"] = update_data["scheduled_date"].isoformat()
        update_data["updated_at"] = datetime.now().isoformat()
        
        updated_task = await db.update_task(user_id, task_id, update_data)
        return updated_task
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update task: {str(e)}"
        )

@router.patch("/{task_id}", response_model=Task)
async def patch_task(
    task_id: str,
    task_update: TaskUpdate,
    user_id: str = Depends(get_current_user_id)
):
    """Partially update a task (same as PUT for this implementation)"""
    return await update_task(task_id, task_update, user_id)

@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_task(
    task_id: str,
    user_id: str = Depends(get_current_user_id)
):
    """Delete a task"""
    try:
        # Check if task exists
        existing_task = await db.get_task(user_id, task_id)
        if not existing_task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        success = await db.delete_task(user_id, task_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to delete task"
            )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to delete task: {str(e)}"
        )

@router.patch("/{task_id}/complete", response_model=Task)
async def toggle_task_completion(
    task_id: str,
    user_id: str = Depends(get_current_user_id)
):
    """Toggle task completion status"""
    try:
        # Get current task
        task = await db.get_task(user_id, task_id)
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        # Toggle completion
        update_data = {
            "is_completed": not task.get("is_completed", False),
            "updated_at": datetime.now().isoformat()
        }
        
        updated_task = await db.update_task(user_id, task_id, update_data)
        return updated_task
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to toggle task completion: {str(e)}"
        ) 