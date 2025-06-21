# Backend Integration Guide

## Overview

EmotiTask now supports integration with a Python backend service for task synchronization. The app works in both online and offline modes.

## 🔧 Configuration

### Backend URL Setup

1. Open `Sources/EmotiTask/TaskServiceConfig.swift`
2. Update the `baseURL` to match your Python backend:

```swift
static let baseURL = "http://your-backend-url:8000"  // Change this
```

### Enable/Disable Backend

To disable backend integration (local-only mode):

```swift
static let isBackendEnabled = false  // Set to false for local-only
```

## 🚀 Backend API Requirements

Your Python backend should expose these endpoints:

### POST /tasks
Create a new task
```json
{
  "title": "Task title",
  "notes": "Optional notes",
  "scheduledDate": "2024-01-15T10:30:00Z",
  "priority": "medium",
  "emotionalTag": "focus",
  "estimatedDuration": 60,
  "projectId": "uuid-string",
  "isCompleted": false
}
```

**Response (201):**
```json
{
  "id": "uuid-string",
  "title": "Task title",
  "notes": "Optional notes",
  "scheduledDate": "2024-01-15T10:30:00Z",
  "priority": "medium",
  "emotionalTag": "focus",
  "estimatedDuration": 60,
  "projectId": "uuid-string",
  "isCompleted": false,
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

### GET /tasks
Get all tasks

**Response (200):**
```json
[
  {
    "id": "uuid-string",
    "title": "Task title",
    // ... same structure as POST response
  }
]
```

### PATCH /tasks/{task_id}
Update task completion status
```json
{
  "isCompleted": true
}
```

**Response (200):** Updated task object

### DELETE /tasks/{task_id}
Delete a task

**Response (204):** No content

## 🏗️ How It Works

### Optimistic Updates
- **UI Responsiveness**: All task operations update the local state immediately
- **Background Sync**: API calls happen in the background
- **Rollback**: If backend fails, local changes are reverted (for updates/deletes)
- **Offline Support**: Tasks remain functional when backend is unavailable

### Error Handling
- Network errors are logged and displayed to users
- Failed operations don't block the UI
- Tasks created offline will sync when backend becomes available (future enhancement)

### Synchronous API
All task operations are synchronous from the UI perspective:
```swift
// Simple, synchronous calls
sessionData.addTask(newTask)
sessionData.completeTask(taskId)
sessionData.deleteTask(taskId)
```

Backend integration happens transparently in the background.

## 🛠️ Development

### Testing Without Backend
Set `isBackendEnabled = false` in `TaskServiceConfig.swift` to test local-only functionality.

### Debug Logging
Enable detailed logging:
```swift
static let isDebugEnabled = true
```

### Request Timeout
Adjust timeout for slow networks:
```swift
static let requestTimeout: TimeInterval = 60.0  // 60 seconds
```

## 📱 Usage Examples

```swift
// Create a task (syncs to backend automatically)
let task = Task(title: "New Task", ...)
sessionData.addTask(task)

// Complete a task (updates backend automatically)
sessionData.completeTask(taskId)

// Delete a task (removes from backend automatically)
sessionData.deleteTask(taskId)

// Load tasks from backend (called on app launch)
await sessionData.loadTasks()
```

## 🔍 Troubleshooting

### Common Issues

1. **Connection Refused**: Check if your Python backend is running on the correct port
2. **Timeout Errors**: Increase `requestTimeout` in config
3. **JSON Parsing Errors**: Ensure your backend returns the expected JSON structure
4. **CORS Issues**: Configure your Python backend to allow requests from iOS simulator

### Debugging

Enable debug logging and check the Xcode console for detailed error messages:
- ✅ Success messages show successful operations
- ❌ Error messages show what went wrong
- ℹ️ Info messages show when backend is disabled

## 🚀 Future Enhancements

- **Offline Queue**: Queue operations when offline and sync when online
- **Conflict Resolution**: Handle conflicts when same task is modified on multiple devices
- **Real-time Sync**: WebSocket support for real-time updates
- **Authentication**: User authentication and authorization 