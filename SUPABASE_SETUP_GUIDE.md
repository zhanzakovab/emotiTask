# 🚀 EmotiTask Supabase Backend Setup Guide

Complete backend integration using Supabase for your EmotiTask SwiftUI app.

## 📋 Table of Contents
1. [Supabase Project Setup](#supabase-project-setup)
2. [Database Schema](#database-schema)
3. [Swift Package Integration](#swift-package-integration)
4. [Service Implementation](#service-implementation)
5. [Authentication Setup](#authentication-setup)
6. [Testing & Deployment](#testing--deployment)

## 🎯 Supabase Project Setup

### Step 1: Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Create new project:
   - **Name**: `emotitask-backend`
   - **Database Password**: Generate strong password
   - **Region**: Choose closest to your users

### Step 2: Get Project Credentials
After project creation, go to **Settings > API**:
- **Project URL**: `https://your-project-id.supabase.co`
- **Anon Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## 🗄️ Database Schema

### SQL Schema for EmotiTask

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User profiles table
CREATE TABLE user_profiles (
    id UUID REFERENCES auth.users PRIMARY KEY,
    personality_type TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Projects table
CREATE TABLE projects (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    color TEXT DEFAULT 'blue',
    icon TEXT DEFAULT 'folder.fill',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table
CREATE TABLE tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    notes TEXT DEFAULT '',
    is_completed BOOLEAN DEFAULT FALSE,
    emotional_tag TEXT,
    scheduled_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    priority TEXT DEFAULT 'medium',
    estimated_duration INTEGER DEFAULT 30,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Goals table
CREATE TABLE goals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    target_date TIMESTAMP WITH TIME ZONE,
    progress DECIMAL(3,2) DEFAULT 0.0,
    category TEXT DEFAULT 'wellness',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Goal-Task relationships
CREATE TABLE goal_tasks (
    goal_id UUID REFERENCES goals(id) ON DELETE CASCADE,
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    PRIMARY KEY (goal_id, task_id)
);

-- Row Level Security (RLS) Policies
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_tasks ENABLE ROW LEVEL SECURITY;

-- User profiles policies
CREATE POLICY "Users can view own profile" ON user_profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can create own profile" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Projects policies
CREATE POLICY "Users can view own projects" ON projects FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own projects" ON projects FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own projects" ON projects FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own projects" ON projects FOR DELETE USING (auth.uid() = user_id);

-- Tasks policies
CREATE POLICY "Users can view own tasks" ON tasks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own tasks" ON tasks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own tasks" ON tasks FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own tasks" ON tasks FOR DELETE USING (auth.uid() = user_id);

-- Goals policies
CREATE POLICY "Users can view own goals" ON goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own goals" ON goals FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own goals" ON goals FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own goals" ON goals FOR DELETE USING (auth.uid() = user_id);

-- Goal-tasks policies
CREATE POLICY "Users can manage own goal-task relationships" ON goal_tasks 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM goals WHERE goals.id = goal_tasks.goal_id AND goals.user_id = auth.uid()
        )
    );

-- Indexes for better performance
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_scheduled_date ON tasks(scheduled_date);
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_goals_user_id ON goals(user_id);
CREATE INDEX idx_goals_target_date ON goals(target_date);
```

### Step 3: Run Schema in Supabase
1. Go to **SQL Editor** in your Supabase dashboard
2. Paste the schema above
3. Click **Run** to create all tables and policies

## 📦 Swift Package Integration

### Step 1: Add Supabase Package
In Xcode:
1. **File > Add Package Dependencies**
2. Enter: `https://github.com/supabase/supabase-swift`
3. Add to your target

### Step 2: Update Package.swift
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EmotiTask",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(name: "EmotiTask", targets: ["EmotiTask"])
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "EmotiTask",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        )
    ]
)
```

## 🔧 Service Implementation

### Create SupabaseService.swift
```swift
import Foundation
import Supabase

// MARK: - Supabase Configuration
struct SupabaseConfig {
    static let url = "YOUR_SUPABASE_URL" // Replace with your URL
    static let anonKey = "YOUR_SUPABASE_ANON_KEY" // Replace with your key
}

// MARK: - Supabase Service
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.url)!,
            supabaseKey: SupabaseConfig.anonKey
        )
        
        checkAuthStatus()
    }
    
    // MARK: - Authentication
    
    func checkAuthStatus() {
        Task {
            do {
                let user = try await client.auth.user()
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            } catch {
                await MainActor.run {
                    self.currentUser = nil
                    self.isAuthenticated = false
                }
            }
        }
    }
    
    func signUp(email: String, password: String) async throws {
        let response = try await client.auth.signUp(email: email, password: password)
        await MainActor.run {
            self.currentUser = response.user
            self.isAuthenticated = response.user != nil
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let response = try await client.auth.signIn(email: email, password: password)
        await MainActor.run {
            self.currentUser = response.user
            self.isAuthenticated = true
        }
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    // MARK: - Tasks CRUD
    
    func createTask(_ task: Task) async throws -> Task {
        guard let userId = currentUser?.id else { throw SupabaseError.notAuthenticated }
        
        let taskData: [String: Any] = [
            "user_id": userId.uuidString,
            "title": task.title,
            "notes": task.notes,
            "is_completed": task.isCompleted,
            "emotional_tag": task.emotionalTag?.rawValue as Any,
            "scheduled_date": ISO8601DateFormatter().string(from: task.scheduledDate),
            "priority": task.priority.rawValue,
            "estimated_duration": task.estimatedDuration,
            "project_id": task.projectId?.uuidString as Any
        ]
        
        let response: [SupabaseTask] = try await client.database
            .from("tasks")
            .insert(taskData)
            .select()
            .execute()
            .value
        
        guard let supabaseTask = response.first else {
            throw SupabaseError.invalidResponse
        }
        
        return supabaseTask.toTask()
    }
    
    func getTasks() async throws -> [Task] {
        guard let userId = currentUser?.id else { throw SupabaseError.notAuthenticated }
        
        let response: [SupabaseTask] = try await client.database
            .from("tasks")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("scheduled_date")
            .execute()
            .value
        
        return response.map { $0.toTask() }
    }
    
    func updateTask(_ task: Task) async throws {
        guard currentUser?.id != nil else { throw SupabaseError.notAuthenticated }
        
        let updateData: [String: Any] = [
            "title": task.title,
            "notes": task.notes,
            "is_completed": task.isCompleted,
            "emotional_tag": task.emotionalTag?.rawValue as Any,
            "scheduled_date": ISO8601DateFormatter().string(from: task.scheduledDate),
            "priority": task.priority.rawValue,
            "estimated_duration": task.estimatedDuration,
            "project_id": task.projectId?.uuidString as Any,
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await client.database
            .from("tasks")
            .update(updateData)
            .eq("id", value: task.id.uuidString)
            .execute()
    }
    
    func deleteTask(id: UUID) async throws {
        guard currentUser?.id != nil else { throw SupabaseError.notAuthenticated }
        
        try await client.database
            .from("tasks")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Projects CRUD
    
    func createProject(_ project: Project) async throws -> Project {
        guard let userId = currentUser?.id else { throw SupabaseError.notAuthenticated }
        
        let projectData: [String: Any] = [
            "user_id": userId.uuidString,
            "title": project.title,
            "description": project.description,
            "color": colorToString(project.color),
            "icon": project.icon
        ]
        
        let response: [SupabaseProject] = try await client.database
            .from("projects")
            .insert(projectData)
            .select()
            .execute()
            .value
        
        guard let supabaseProject = response.first else {
            throw SupabaseError.invalidResponse
        }
        
        return supabaseProject.toProject()
    }
    
    func getProjects() async throws -> [Project] {
        guard let userId = currentUser?.id else { throw SupabaseError.notAuthenticated }
        
        let response: [SupabaseProject] = try await client.database
            .from("projects")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at")
            .execute()
            .value
        
        return response.map { $0.toProject() }
    }
    
    // MARK: - Helper Methods
    
    private func colorToString(_ color: Color) -> String {
        // Simple color mapping - you can expand this
        switch color {
        case .blue: return "blue"
        case .red: return "red"
        case .green: return "green"
        case .purple: return "purple"
        case .orange: return "orange"
        case .pink: return "pink"
        case .yellow: return "yellow"
        default: return "blue"
        }
    }
    
    private func stringToColor(_ string: String) -> Color {
        switch string {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "yellow": return .yellow
        default: return .blue
        }
    }
}

// MARK: - Supabase Models

struct SupabaseTask: Codable {
    let id: String
    let userId: String
    let projectId: String?
    let title: String
    let notes: String
    let isCompleted: Bool
    let emotionalTag: String?
    let scheduledDate: String
    let priority: String
    let estimatedDuration: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, notes, priority
        case userId = "user_id"
        case projectId = "project_id"
        case isCompleted = "is_completed"
        case emotionalTag = "emotional_tag"
        case scheduledDate = "scheduled_date"
        case estimatedDuration = "estimated_duration"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    func toTask() -> Task {
        let dateFormatter = ISO8601DateFormatter()
        let scheduledDate = dateFormatter.date(from: self.scheduledDate) ?? Date()
        
        return Task(
            title: title,
            isCompleted: isCompleted,
            emotionalTag: emotionalTag.flatMap { EmotionalTag(rawValue: $0) },
            scheduledDate: scheduledDate,
            notes: notes,
            priority: TaskPriority(rawValue: priority) ?? .medium,
            estimatedDuration: estimatedDuration,
            projectId: projectId.flatMap { UUID(uuidString: $0) }
        )
    }
}

struct SupabaseProject: Codable {
    let id: String
    let userId: String
    let title: String
    let description: String
    let color: String
    let icon: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, color, icon
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    func toProject() -> Project {
        return Project(
            title: title,
            description: description,
            color: stringToColor(color),
            icon: icon
        )
    }
    
    private func stringToColor(_ string: String) -> Color {
        switch string {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "yellow": return .yellow
        default: return .blue
        }
    }
}

// MARK: - Errors

enum SupabaseError: LocalizedError {
    case notAuthenticated
    case invalidResponse
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User not authenticated"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
```

## 🔐 Authentication Setup

### Update WelcomeView.swift
```swift
import SwiftUI

struct WelcomeView: View {
    @StateObject private var supabaseService = SupabaseService.shared
    @State private var showingAuth = false
    
    var body: some View {
        if supabaseService.isAuthenticated {
            MainTabView()
        } else {
            // Your existing welcome view with updated buttons
            VStack {
                // ... existing UI ...
                
                Button("Sign In") {
                    showingAuth = true
                }
                
                Button("Sign Up") {
                    showingAuth = true
                }
            }
            .sheet(isPresented: $showingAuth) {
                AuthView()
            }
        }
    }
}
```

### Create AuthView.swift
```swift
import SwiftUI

struct AuthView: View {
    @StateObject private var supabaseService = SupabaseService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(isSignUp ? "Create Account" : "Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: authenticate) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                Button(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                    isSignUp.toggle()
                    errorMessage = ""
                }
                .foregroundColor(.blue)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func authenticate() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                if isSignUp {
                    try await supabaseService.signUp(email: email, password: password)
                } else {
                    try await supabaseService.signIn(email: email, password: password)
                }
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
```

## 🔄 Update ToDoSessionData

### Replace TaskService with SupabaseService
```swift
// In ToDoModels.swift, update ToDoSessionData class:

class ToDoSessionData: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var projects: [Project] = []
    @Published var goals: [Goal] = []
    @Published var isLoading = false
    @Published var lastError: String?
    
    private let supabaseService = SupabaseService.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        Task {
            await loadTasks()
            await loadProjects()
            await loadGoals()
        }
    }
    
    func addTask(_ task: Task) {
        // Optimistic update
        tasks.append(task)
        
        // Sync with Supabase
        Task {
            do {
                let createdTask = try await supabaseService.createTask(task)
                await MainActor.run {
                    // Update with server response if needed
                    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                        tasks[index] = createdTask
                    }
                }
            } catch {
                await MainActor.run {
                    // Remove from local state if server sync failed
                    tasks.removeAll { $0.id == task.id }
                    lastError = error.localizedDescription
                }
            }
        }
    }
    
    func completeTask(_ taskId: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        
        // Optimistic update
        tasks[index].isCompleted.toggle()
        
        // Sync with Supabase
        Task {
            do {
                try await supabaseService.updateTask(tasks[index])
            } catch {
                await MainActor.run {
                    // Revert if server sync failed
                    tasks[index].isCompleted.toggle()
                    lastError = error.localizedDescription
                }
            }
        }
    }
    
    func deleteTask(_ taskId: UUID) {
        guard let task = tasks.first(where: { $0.id == taskId }) else { return }
        
        // Optimistic update
        tasks.removeAll { $0.id == taskId }
        
        // Sync with Supabase
        Task {
            do {
                try await supabaseService.deleteTask(id: taskId)
            } catch {
                await MainActor.run {
                    // Restore if server sync failed
                    tasks.append(task)
                    lastError = error.localizedDescription
                }
            }
        }
    }
    
    private func loadTasks() async {
        await MainActor.run { isLoading = true }
        
        do {
            let fetchedTasks = try await supabaseService.getTasks()
            await MainActor.run {
                tasks = fetchedTasks
                isLoading = false
            }
        } catch {
            await MainActor.run {
                lastError = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func loadProjects() async {
        do {
            let fetchedProjects = try await supabaseService.getProjects()
            await MainActor.run {
                projects = fetchedProjects
            }
        } catch {
            await MainActor.run {
                lastError = error.localizedDescription
            }
        }
    }
    
    private func loadGoals() async {
        // Implement when you add goals to SupabaseService
    }
    
    // ... rest of your existing methods ...
}
```

## 🧪 Testing & Deployment

### Step 1: Add Your Credentials
1. Replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` in `SupabaseConfig`
2. Test authentication in simulator

### Step 2: Test CRUD Operations
```swift
// Test in your app or create a simple test
func testSupabaseIntegration() async {
    let service = SupabaseService.shared
    
    do {
        // Test sign up
        try await service.signUp(email: "test@example.com", password: "testpassword")
        
        // Test task creation
        let task = Task(title: "Test Task", emotionalTag: .focus)
        let createdTask = try await service.createTask(task)
        print("Created task: \(createdTask.title)")
        
        // Test task retrieval
        let tasks = try await service.getTasks()
        print("Retrieved \(tasks.count) tasks")
        
    } catch {
        print("Test failed: \(error)")
    }
}
```

### Step 3: Production Setup
1. **Environment Variables**: Use environment-specific configs
2. **Error Handling**: Add comprehensive error handling
3. **Offline Support**: Implement local caching with Core Data
4. **Push Notifications**: Set up with Supabase Realtime

## 🚀 Next Steps

1. **Real-time Updates**: Use Supabase Realtime for live task updates
2. **File Storage**: Use Supabase Storage for profile pictures
3. **Analytics**: Track user behavior with Supabase Analytics
4. **Edge Functions**: Add AI features with Supabase Edge Functions

## 📚 Resources

- [Supabase Swift Docs](https://supabase.com/docs/reference/swift)
- [Supabase Dashboard](https://app.supabase.com)
- [SwiftUI + Supabase Tutorial](https://supabase.com/docs/guides/getting-started/tutorials/with-swift)

---

**🎉 Your EmotiTask app is now powered by Supabase!** 

This setup gives you:
- ✅ User authentication
- ✅ Real-time database
- ✅ Row-level security
- ✅ Automatic API generation
- ✅ Scalable backend infrastructure 