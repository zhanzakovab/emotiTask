from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from app.models import Project, ProjectCreate, ProjectUpdate, ProjectsResponse
from app.auth import get_current_user_id
from app.database import db
from datetime import datetime

router = APIRouter(prefix="/projects", tags=["projects"])

@router.post("/", response_model=Project, status_code=status.HTTP_201_CREATED)
async def create_project(
    project: ProjectCreate,
    user_id: str = Depends(get_current_user_id)
):
    """Create a new project"""
    try:
        project_data = project.model_dump()
        created_project = await db.create_project(user_id, project_data)
        return created_project
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create project: {str(e)}"
        )

@router.get("/", response_model=ProjectsResponse)
async def get_projects(
    user_id: str = Depends(get_current_user_id)
):
    """Get all projects for the current user"""
    try:
        projects = await db.get_projects(user_id)
        return ProjectsResponse(projects=projects, total=len(projects))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to fetch projects: {str(e)}"
        )

@router.get("/{project_id}", response_model=Project)
async def get_project(
    project_id: str,
    user_id: str = Depends(get_current_user_id)
):
    """Get a specific project"""
    try:
        project = await db.get_project(user_id, project_id)
        if not project:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found"
            )
        return project
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to fetch project: {str(e)}"
        )

@router.put("/{project_id}", response_model=Project)
async def update_project(
    project_id: str,
    project_update: ProjectUpdate,
    user_id: str = Depends(get_current_user_id)
):
    """Update a project"""
    try:
        # Check if project exists
        existing_project = await db.get_project(user_id, project_id)
        if not existing_project:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found"
            )
        
        # Prepare update data
        update_data = project_update.model_dump(exclude_unset=True)
        update_data["updated_at"] = datetime.now().isoformat()
        
        updated_project = await db.update_project(user_id, project_id, update_data)
        return updated_project
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update project: {str(e)}"
        )

@router.delete("/{project_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_project(
    project_id: str,
    user_id: str = Depends(get_current_user_id)
):
    """Delete a project"""
    try:
        # Check if project exists
        existing_project = await db.get_project(user_id, project_id)
        if not existing_project:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found"
            )
        
        success = await db.delete_project(user_id, project_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to delete project"
            )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to delete project: {str(e)}"
        )

@router.get("/{project_id}/tasks")
async def get_project_tasks(
    project_id: str,
    user_id: str = Depends(get_current_user_id)
):
    """Get all tasks for a specific project"""
    try:
        # Check if project exists
        project = await db.get_project(user_id, project_id)
        if not project:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found"
            )
        
        # Get all tasks and filter by project_id
        all_tasks = await db.get_tasks(user_id)
        project_tasks = [task for task in all_tasks if task.get("project_id") == project_id]
        
        return {"tasks": project_tasks, "total": len(project_tasks)}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to fetch project tasks: {str(e)}"
        ) 