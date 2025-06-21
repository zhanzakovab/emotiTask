from supabase import create_client, Client
from app.config import settings
import asyncio
from typing import Optional, Dict, Any, List

class SupabaseClient:
    def __init__(self):
        # Always try to connect to Supabase if credentials are available
        if settings.SUPABASE_URL and settings.SUPABASE_SERVICE_ROLE_KEY:
            self.client: Client = create_client(
                settings.SUPABASE_URL,
                settings.SUPABASE_SERVICE_ROLE_KEY  # Using service role for backend operations
            )
            self.configured = True
            if settings.DEBUG:
                print("🔧 Development mode: Using Supabase with auth bypass")
            else:
                print("🚀 Production mode: Using Supabase with full auth")
        else:
            self.client = None
            self.configured = False
            print("🔧 Supabase not configured - using dummy data for development")
        
        # In-memory storage for development fallback
        self.dev_tasks = []
        self.dev_projects = []
        self.dev_goals = []
        self.dev_profiles = {}
    
    def _check_configured(self):
        if not self.configured:
            raise Exception("Supabase not configured. Please set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in your .env file")
    
    async def _ensure_user_profile_exists(self, user_id: str):
        """Ensure a user profile exists for the development user"""
        try:
            # Check if user profile already exists
            response = self.client.table("user_profiles").select("id").eq("id", user_id).execute()
            if response.data:
                return  # Profile already exists
            
            # Create a user profile (this might work even without auth.users entry)
            profile_data = {
                "id": user_id,
                "personality_type": "Balanced",
                "created_at": "2025-06-21T23:00:00.000Z",
                "updated_at": "2025-06-21T23:00:00.000Z"
            }
            
            # Try to insert the profile
            self.client.table("user_profiles").insert(profile_data).execute()
            print(f"✅ Created development user profile: {user_id}")
            
        except Exception as e:
            print(f"⚠️ Could not create user profile: {e}")
            # This will also fail due to foreign key constraint
    
    async def get_user_by_token(self, token: str) -> Optional[Dict[str, Any]]:
        """Get user from JWT token"""
        if not self.configured:
            # Return dummy user for development
            return {"id": "dummy-user-id", "email": "test@example.com"}
        
        try:
            response = self.client.auth.get_user(token)
            return response.user.__dict__ if response.user else None
        except Exception as e:
            print(f"Error getting user: {e}")
            return None
    
    # Task operations
    async def create_task(self, user_id: str, task_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new task"""
        if not self.configured:
            # Use in-memory storage for development
            import uuid
            from datetime import datetime
            
            new_task = {
                "id": str(uuid.uuid4()),
                "user_id": user_id,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat(),
                **task_data
            }
            
            self.dev_tasks.append(new_task)
            print(f"✅ Created task in development storage: {new_task['title']}")
            return new_task
        
        # For development mode, try to create a user profile if it doesn't exist
        if settings.DEBUG and user_id == "12345678-1234-1234-1234-123456789012":
            await self._ensure_user_profile_exists(user_id)
        
        self._check_configured()
        task_data["user_id"] = user_id
        
        try:
            response = self.client.table("tasks").insert(task_data).execute()
            created_task = response.data[0] if response.data else {}
            print(f"✅ Created task in Supabase: {created_task.get('title', 'Unknown')}")
            return created_task
        except Exception as e:
            print(f"❌ Failed to create task in Supabase: {e}")
            # Fallback to in-memory storage
            import uuid
            from datetime import datetime
            
            new_task = {
                "id": str(uuid.uuid4()),
                "user_id": user_id,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat(),
                **task_data
            }
            
            self.dev_tasks.append(new_task)
            print(f"✅ Created task in fallback storage: {new_task['title']}")
            return new_task
    
    async def get_tasks(self, user_id: str) -> List[Dict[str, Any]]:
        """Get all tasks for a user"""
        if not self.configured:
            # Return tasks from in-memory storage for development
            user_tasks = [task for task in self.dev_tasks if task["user_id"] == user_id]
            print(f"📋 Retrieved {len(user_tasks)} tasks from development storage")
            return user_tasks
        
        try:
            response = self.client.table("tasks").select("*").eq("user_id", user_id).order("scheduled_date").execute()
            tasks = response.data or []
            print(f"📋 Retrieved {len(tasks)} tasks from Supabase")
            return tasks
        except Exception as e:
            print(f"❌ Failed to get tasks from Supabase: {e}")
            # Fallback to in-memory storage
            user_tasks = [task for task in self.dev_tasks if task["user_id"] == user_id]
            print(f"📋 Retrieved {len(user_tasks)} tasks from fallback storage")
            return user_tasks
    
    async def get_task(self, user_id: str, task_id: str) -> Optional[Dict[str, Any]]:
        """Get a specific task"""
        if not self.configured:
            # Return dummy task if it matches
            if task_id == "dummy-task-1":
                from datetime import datetime
                return {
                    "id": task_id,
                    "user_id": user_id,
                    "title": "Sample Task",
                    "notes": "This is a sample task",
                    "is_completed": False,
                    "emotional_tag": "focus",
                    "scheduled_date": datetime.now().isoformat(),
                    "priority": "Medium",
                    "estimated_duration": 30,
                    "project_id": None,
                    "created_at": datetime.now().isoformat(),
                    "updated_at": datetime.now().isoformat()
                }
            return None
        
        self._check_configured()
        response = self.client.table("tasks").select("*").eq("user_id", user_id).eq("id", task_id).execute()
        return response.data[0] if response.data else None
    
    async def update_task(self, user_id: str, task_id: str, task_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update a task"""
        if not self.configured:
            # Return dummy updated task
            from datetime import datetime
            return {
                "id": task_id,
                "user_id": user_id,
                "updated_at": datetime.now().isoformat(),
                **task_data
            }
        
        self._check_configured()
        response = self.client.table("tasks").update(task_data).eq("user_id", user_id).eq("id", task_id).execute()
        return response.data[0] if response.data else {}
    
    async def delete_task(self, user_id: str, task_id: str) -> bool:
        """Delete a task"""
        if not self.configured:
            return True  # Always succeed in development mode
        
        self._check_configured()
        response = self.client.table("tasks").delete().eq("user_id", user_id).eq("id", task_id).execute()
        return len(response.data) > 0
    
    # Project operations
    async def create_project(self, user_id: str, project_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new project"""
        if not self.configured:
            import uuid
            from datetime import datetime
            return {
                "id": str(uuid.uuid4()),
                "user_id": user_id,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat(),
                **project_data
            }
        
        self._check_configured()
        project_data["user_id"] = user_id
        response = self.client.table("projects").insert(project_data).execute()
        return response.data[0] if response.data else {}
    
    async def get_projects(self, user_id: str) -> List[Dict[str, Any]]:
        """Get all projects for a user"""
        if not self.configured:
            from datetime import datetime
            return [
                {
                    "id": "dummy-project-1",
                    "user_id": user_id,
                    "title": "Sample Project",
                    "description": "This is a sample project",
                    "color": "blue",
                    "icon": "folder.fill",
                    "created_at": datetime.now().isoformat(),
                    "updated_at": datetime.now().isoformat()
                }
            ]
        
        self._check_configured()
        response = self.client.table("projects").select("*").eq("user_id", user_id).order("created_at").execute()
        return response.data or []
    
    async def get_project(self, user_id: str, project_id: str) -> Optional[Dict[str, Any]]:
        """Get a specific project"""
        if not self.configured:
            if project_id == "dummy-project-1":
                from datetime import datetime
                return {
                    "id": project_id,
                    "user_id": user_id,
                    "title": "Sample Project",
                    "description": "This is a sample project",
                    "color": "blue",
                    "icon": "folder.fill",
                    "created_at": datetime.now().isoformat(),
                    "updated_at": datetime.now().isoformat()
                }
            return None
        
        self._check_configured()
        response = self.client.table("projects").select("*").eq("user_id", user_id).eq("id", project_id).execute()
        return response.data[0] if response.data else None
    
    async def update_project(self, user_id: str, project_id: str, project_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update a project"""
        if not self.configured:
            from datetime import datetime
            return {
                "id": project_id,
                "user_id": user_id,
                "updated_at": datetime.now().isoformat(),
                **project_data
            }
        
        self._check_configured()
        response = self.client.table("projects").update(project_data).eq("user_id", user_id).eq("id", project_id).execute()
        return response.data[0] if response.data else {}
    
    async def delete_project(self, user_id: str, project_id: str) -> bool:
        """Delete a project"""
        if not self.configured:
            return True
        
        self._check_configured()
        response = self.client.table("projects").delete().eq("user_id", user_id).eq("id", project_id).execute()
        return len(response.data) > 0
    
    # Goal operations
    async def create_goal(self, user_id: str, goal_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new goal"""
        if not self.configured:
            import uuid
            from datetime import datetime
            return {
                "id": str(uuid.uuid4()),
                "user_id": user_id,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat(),
                **goal_data
            }
        
        self._check_configured()
        goal_data["user_id"] = user_id
        response = self.client.table("goals").insert(goal_data).execute()
        return response.data[0] if response.data else {}
    
    async def get_goals(self, user_id: str) -> List[Dict[str, Any]]:
        """Get all goals for a user"""
        if not self.configured:
            from datetime import datetime, timedelta
            return [
                {
                    "id": "dummy-goal-1",
                    "user_id": user_id,
                    "title": "Sample Goal",
                    "description": "This is a sample goal",
                    "target_date": (datetime.now() + timedelta(days=30)).isoformat(),
                    "progress": 0.5,
                    "category": "Wellness",
                    "created_at": datetime.now().isoformat(),
                    "updated_at": datetime.now().isoformat()
                }
            ]
        
        self._check_configured()
        response = self.client.table("goals").select("*").eq("user_id", user_id).order("target_date").execute()
        return response.data or []
    
    async def get_goal(self, user_id: str, goal_id: str) -> Optional[Dict[str, Any]]:
        """Get a specific goal"""
        if not self.configured:
            if goal_id == "dummy-goal-1":
                from datetime import datetime, timedelta
                return {
                    "id": goal_id,
                    "user_id": user_id,
                    "title": "Sample Goal",
                    "description": "This is a sample goal",
                    "target_date": (datetime.now() + timedelta(days=30)).isoformat(),
                    "progress": 0.5,
                    "category": "Wellness",
                    "created_at": datetime.now().isoformat(),
                    "updated_at": datetime.now().isoformat()
                }
            return None
        
        self._check_configured()
        response = self.client.table("goals").select("*").eq("user_id", user_id).eq("id", goal_id).execute()
        return response.data[0] if response.data else None
    
    async def update_goal(self, user_id: str, goal_id: str, goal_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update a goal"""
        if not self.configured:
            from datetime import datetime
            return {
                "id": goal_id,
                "user_id": user_id,
                "updated_at": datetime.now().isoformat(),
                **goal_data
            }
        
        self._check_configured()
        response = self.client.table("goals").update(goal_data).eq("user_id", user_id).eq("id", goal_id).execute()
        return response.data[0] if response.data else {}
    
    async def delete_goal(self, user_id: str, goal_id: str) -> bool:
        """Delete a goal"""
        if not self.configured:
            return True
        
        self._check_configured()
        response = self.client.table("goals").delete().eq("user_id", user_id).eq("id", goal_id).execute()
        return len(response.data) > 0
    
    # User profile operations
    async def get_user_profile(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user profile"""
        if not self.configured:
            from datetime import datetime
            return {
                "id": user_id,
                "personality_type": "Balanced",
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
        
        self._check_configured()
        response = self.client.table("user_profiles").select("*").eq("id", user_id).execute()
        return response.data[0] if response.data else None
    
    async def create_user_profile(self, user_id: str, profile_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create user profile"""
        if not self.configured:
            from datetime import datetime
            return {
                "id": user_id,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat(),
                **profile_data
            }
        
        self._check_configured()
        profile_data["id"] = user_id
        response = self.client.table("user_profiles").insert(profile_data).execute()
        return response.data[0] if response.data else {}
    
    async def update_user_profile(self, user_id: str, profile_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update user profile"""
        if not self.configured:
            from datetime import datetime
            return {
                "id": user_id,
                "updated_at": datetime.now().isoformat(),
                **profile_data
            }
        
        self._check_configured()
        response = self.client.table("user_profiles").update(profile_data).eq("id", user_id).execute()
        return response.data[0] if response.data else {}

# Global database instance
db = SupabaseClient() 