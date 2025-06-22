import Foundation
import SwiftUI

// MARK: - Emotional Tags

enum EmotionalTag: String, CaseIterable {
    case lowEnergy = "low energy"
    case focus = "focus"
    case timeSensitive = "time sensitive"
    case creative = "creative"
    case social = "social"
    case selfCare = "self care"
    case routine = "routine"
    case challenging = "challenging"
    
    var color: Color {
        switch self {
        case .lowEnergy: return .blue
        case .focus: return .red
        case .timeSensitive: return .orange
        case .creative: return .purple
        case .social: return .green
        case .selfCare: return .pink
        case .routine: return .gray
        case .challenging: return .yellow
        }
    }
}

// MARK: - Project Models

struct Project: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var color: Color
    var icon: String
    var createdDate: Date
    var tasks: [TodoTask]
    
    init(title: String, description: String = "", color: Color = .blue, icon: String = "folder.fill", tasks: [TodoTask] = []) {
        self.title = title
        self.description = description
        self.color = color
        self.icon = icon
        self.createdDate = Date()
        self.tasks = tasks
    }
    
    var completedTasksCount: Int {
        return tasks.filter { $0.isCompleted }.count
    }
    
    var totalTasksCount: Int {
        return tasks.count
    }
    
    var progress: Double {
        guard totalTasksCount > 0 else { return 0.0 }
        return Double(completedTasksCount) / Double(totalTasksCount)
    }
}

// MARK: - View Mode Enums

enum TaskViewMode: String, CaseIterable {
    case list = "List"
    case upcoming = "Upcoming"
    case completed = "Completed"
    
    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .upcoming: return "calendar"
        case .completed: return "checkmark.circle"
        }
    }
}

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case today = "Today"
    case thisWeek = "This Week"
    case highPriority = "High Priority"
    case byProject = "By Project"
    
    var icon: String {
        switch self {
        case .all: return "tray.full"
        case .today: return "sun.max"
        case .thisWeek: return "calendar.badge.clock"
        case .highPriority: return "exclamationmark.triangle"
        case .byProject: return "folder"
        }
    }
}

// MARK: - Task Models

struct TodoTask: Identifiable {
    let id: String
    var title: String
    var isCompleted: Bool
    var emotionalTag: EmotionalTag?
    var scheduledDate: Date
    var notes: String
    var priority: TaskPriority
    var estimatedDuration: Int // in minutes
    var projectId: UUID? // Optional project association
    
    init(id: String = UUID().uuidString, title: String, notes: String = "", isCompleted: Bool = false, emotionalTag: EmotionalTag? = nil, scheduledDate: Date = Date(), priority: TaskPriority = .medium, estimatedDuration: Int = 30, projectId: UUID? = nil) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.emotionalTag = emotionalTag
        self.scheduledDate = scheduledDate
        self.priority = priority
        self.estimatedDuration = estimatedDuration
        self.projectId = projectId
    }
    
    static func sample() -> TodoTask {
        return TodoTask(
            title: "Sample Task",
            notes: "This is a sample task",
            emotionalTag: .routine,
            priority: .medium,
            estimatedDuration: 30
        )
    }
}

enum TaskPriority: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

// MARK: - Goal Models

struct Goal: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var targetDate: Date
    var progress: Double // 0.0 to 1.0
    var category: GoalCategory
    var relatedTasks: [String] // Task IDs
    
    var progressPercentage: Int {
        return Int(progress * 100)
    }
    
    var isCompleted: Bool {
        return progress >= 1.0
    }
}

enum GoalCategory: String, CaseIterable {
    case wellness = "Wellness"
    case career = "Career"
    case relationships = "Relationships"
    case learning = "Learning"
    case fitness = "Fitness"
    case creativity = "Creativity"
    case finance = "Finance"
    case home = "Home"
    
    var color: Color {
        switch self {
        case .wellness: return .green
        case .career: return .blue
        case .relationships: return .pink
        case .learning: return .purple
        case .fitness: return .orange
        case .creativity: return .yellow
        case .finance: return .teal
        case .home: return .brown
        }
    }
}

// MARK: - Adaptive Suggestions

struct AdaptiveSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let priority: TaskPriority
    let emotionalContext: String
    let suggestedAction: SuggestionAction?
    let taskId: UUID?
    
    init(title: String, description: String, icon: String, priority: TaskPriority, emotionalContext: String, suggestedAction: SuggestionAction? = nil, taskId: UUID? = nil) {
        self.title = title
        self.description = description
        self.icon = icon
        self.priority = priority
        self.emotionalContext = emotionalContext
        self.suggestedAction = suggestedAction
        self.taskId = taskId
    }
}

enum SuggestionAction {
    case reschedule(to: Date)
    case swap(with: UUID)
    case breakDown(into: [String])
    case postpone
    case prioritize
    case addSelfCare
}

// MARK: - To-Do Session Data

class ToDoSessionData: ObservableObject {
    @Published var tasks: [TodoTask] = []
    @Published var projects: [Project] = []
    @Published var goals: [Goal] = []
    @Published var currentDate: Date
    @Published var weekDates: [Date]
    @Published var suggestions: [AdaptiveSuggestion] = []
    @Published var userEmotionalState: String = ""
    @Published var selectedViewMode: TaskViewMode = .list
    @Published var selectedFilter: TaskFilter = .all
    @Published var isLoading: Bool = false
    @Published var lastError: String?
    
    private let taskService = TaskService.shared
    private var userId: String? {
        // First try to get the user ID from UserDefaults (from MBTI onboarding)
        if let storedUserId = UserDefaults.standard.string(forKey: "userId"), !storedUserId.isEmpty {
            return storedUserId
        }
        
        // Fallback to a development user ID that exists in the database
        return "bc5c3ff4-6011-4c9d-b057-b7989552114d"
    }
    
    init() {
        self.currentDate = Date()
        self.weekDates = Self.generateWeekDates(from: Date())
        
        // Load tasks from backend if user is logged in
        if userId != nil {
            Task {
                await loadTasksFromBackend()
            }
        } else {
            // Use dummy data if no user is logged in
            loadDummyData()
        }
    }
    
    // MARK: - Backend Integration
    
    @MainActor
    private func loadTasksFromBackend() async {
        guard let _ = userId else {
            print("⚠️ No user ID found - using dummy data")
            loadDummyData()
            return
        }
        
        isLoading = true
        lastError = nil
        
        // Use TaskService to load tasks
        taskService.loadTasks()
        
        // Observe TaskService changes
        tasks = taskService.tasks
        isLoading = taskService.isLoading
        lastError = taskService.error
        
        print("✅ Loaded \(tasks.count) tasks from backend")
    }
    
    private func loadDummyData() {
        // Load the existing dummy data for users without accounts
        let dummySession = ToDoSessionData.createDummyDataInternal()
        self.tasks = dummySession.tasks
        self.projects = dummySession.projects
        self.goals = dummySession.goals
        self.suggestions = dummySession.suggestions
        self.userEmotionalState = dummySession.userEmotionalState
        
        print("📱 Using dummy data (no user logged in)")
    }
    
    // MARK: - Task Management with Backend Sync
    
    func addTask(_ task: TodoTask) {
        // Add to local array immediately (optimistic update)
        tasks.append(task)
        
        // Sync with backend if user is logged in
        if userId != nil {
            taskService.addTask(task)
            print("✅ Task added and synced to backend: \(task.title)")
        } else {
            print("📱 Task added locally only: \(task.title)")
        }
        
        updateGoalProgress(for: task.id)
    }
    
    func updateTask(_ task: TodoTask) {
        // Update local array immediately (optimistic update)
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
        
        // Sync with backend if user is logged in
        if userId != nil {
            taskService.updateTask(task)
            print("✅ Task updated and synced to backend: \(task.title)")
        } else {
            print("📱 Task updated locally only: \(task.title)")
        }
        
        updateGoalProgress(for: task.id)
    }
    
    func deleteTask(_ task: TodoTask) {
        // Remove from local array immediately (optimistic update)
        tasks.removeAll { $0.id == task.id }
        
        // Sync with backend if user is logged in
        if userId != nil {
            taskService.deleteTask(task)
            print("✅ Task deleted and synced to backend: \(task.title)")
        } else {
            print("📱 Task deleted locally only: \(task.title)")
        }
        
        updateGoalProgress(for: task.id)
    }
    
    func toggleTaskCompletion(_ task: TodoTask) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updateTask(updatedTask)
    }
    
    func rescheduleTask(_ taskId: String, to newDate: Date) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].scheduledDate = newDate
            updateTask(tasks[index])
        }
    }
    
    // MARK: - Standalone Tasks (not in projects)
    var standaloneTasks: [TodoTask] {
        return tasks.filter { $0.projectId == nil }
    }
    
    // MARK: - Filtered Tasks
    func filteredTasks(for mode: TaskViewMode, filter: TaskFilter) -> [TodoTask] {
        var filteredTasks: [TodoTask] = []
        
        // First apply view mode filter
        switch mode {
        case .list:
            filteredTasks = tasks
        case .upcoming:
            let calendar = Calendar.current
            let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
            filteredTasks = tasks.filter { 
                !$0.isCompleted && $0.scheduledDate <= nextWeek 
            }.sorted { $0.scheduledDate < $1.scheduledDate }
        case .completed:
            filteredTasks = tasks.filter { $0.isCompleted }
                .sorted { $0.scheduledDate > $1.scheduledDate }
        }
        
        // Then apply additional filter
        switch filter {
        case .all:
            break // No additional filtering
        case .today:
            let calendar = Calendar.current
            filteredTasks = filteredTasks.filter { 
                calendar.isDate($0.scheduledDate, inSameDayAs: currentDate) 
            }
        case .thisWeek:
            filteredTasks = filteredTasks.filter { $0.scheduledDate.isThisWeek }
        case .highPriority:
            filteredTasks = filteredTasks.filter { 
                $0.priority == .high || $0.priority == .urgent 
            }
        case .byProject:
            // Group by project - this will be handled in the UI
            break
        }
        
        return filteredTasks
    }
    
    var todayTasks: [TodoTask] {
        let calendar = Calendar.current
        return tasks.filter { calendar.isDate($0.scheduledDate, inSameDayAs: currentDate) }
            .sorted { task1, task2 in
                if task1.isCompleted != task2.isCompleted {
                    return !task1.isCompleted // Incomplete tasks first
                }
                return task1.priority.rawValue > task2.priority.rawValue
            }
    }
    
    var completedTasksToday: Int {
        return todayTasks.filter { $0.isCompleted }.count
    }
    
    var totalTasksToday: Int {
        return todayTasks.count
    }
    
    // MARK: - Project Methods
    func addProject(_ project: Project) {
        projects.append(project)
    }
    
    func deleteProject(_ projectId: UUID) {
        // Move tasks from project back to standalone
        for index in tasks.indices {
            if tasks[index].projectId == projectId {
                tasks[index].projectId = nil
            }
        }
        projects.removeAll { $0.id == projectId }
    }
    
    func tasksForProject(_ projectId: UUID) -> [TodoTask] {
        return tasks.filter { $0.projectId == projectId }
    }
    
    // MARK: - Goal Methods
    private func updateGoalProgress(for taskId: String) {
        for goalIndex in goals.indices {
            let relatedTasksArray = goals[goalIndex].relatedTasks
            if relatedTasksArray.contains(taskId) {
                let totalTasks = relatedTasksArray.count
                let completedTasks = relatedTasksArray.filter { relatedTaskId in
                    tasks.first(where: { $0.id == relatedTaskId })?.isCompleted ?? false
                }.count
                goals[goalIndex].progress = Double(completedTasks) / Double(totalTasks)
            }
        }
    }
    
    private static func generateWeekDates(from date: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    func tasksForDate(_ date: Date) -> [TodoTask] {
        let calendar = Calendar.current
        return tasks.filter { calendar.isDate($0.scheduledDate, inSameDayAs: date) }
    }
}

// MARK: - Dummy Data

extension ToDoSessionData {
    static func createDummyData() -> ToDoSessionData {
        return ToDoSessionData()
    }
    
    private static func createDummyDataInternal() -> ToDoSessionData {
        let session = ToDoSessionData()
        
        // Sample projects
        let workProject = Project(
            title: "Work Project Alpha",
            description: "Q1 product launch preparation",
            color: .blue,
            icon: "briefcase.fill"
        )
        
        let personalProject = Project(
            title: "Home Renovation",
            description: "Kitchen and living room updates",
            color: .green,
            icon: "house.fill"
        )
        
        let learningProject = Project(
            title: "iOS Development",
            description: "Master SwiftUI and iOS development",
            color: .purple,
            icon: "swift"
        )
        
        session.projects = [workProject, personalProject, learningProject]
        
        // Sample goals
        session.goals = [
            Goal(
                title: "Improve Work-Life Balance",
                description: "Create better boundaries between work and personal time",
                targetDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
                progress: 0.4,
                category: .wellness,
                relatedTasks: []
            ),
            Goal(
                title: "Learn SwiftUI",
                description: "Master SwiftUI for iOS development",
                targetDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date(),
                progress: 0.7,
                category: .learning,
                relatedTasks: []
            ),
            Goal(
                title: "Daily Meditation",
                description: "Establish a consistent meditation practice",
                targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                progress: 0.6,
                category: .wellness,
                relatedTasks: []
            )
        ]
        
        // Sample tasks for today and this week
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
        let dayAfter = Calendar.current.date(byAdding: .day, value: 2, to: today) ?? today
        
        session.tasks = [
            // Today's tasks - mix of standalone and project tasks
            TodoTask(title: "Review project proposal", emotionalTag: .focus, scheduledDate: today, priority: .high, estimatedDuration: 60, projectId: workProject.id),
            TodoTask(title: "10-minute meditation", emotionalTag: .selfCare, scheduledDate: today, priority: .medium, estimatedDuration: 10), // Standalone
            TodoTask(title: "Call mom", emotionalTag: .social, scheduledDate: today, priority: .medium, estimatedDuration: 30), // Standalone
            TodoTask(title: "Grocery shopping", emotionalTag: .routine, scheduledDate: today, priority: .low, estimatedDuration: 45), // Standalone
            TodoTask(title: "Measure kitchen counters", emotionalTag: .routine, scheduledDate: today, priority: .medium, estimatedDuration: 20, projectId: personalProject.id),
            
            // Tomorrow's tasks
            TodoTask(title: "Team meeting", emotionalTag: .social, scheduledDate: tomorrow, priority: .high, estimatedDuration: 90, projectId: workProject.id),
            TodoTask(title: "SwiftUI tutorial", emotionalTag: .creative, scheduledDate: tomorrow, priority: .medium, estimatedDuration: 120, projectId: learningProject.id),
            TodoTask(title: "Workout", emotionalTag: .challenging, scheduledDate: tomorrow, priority: .medium, estimatedDuration: 45), // Standalone
            TodoTask(title: "Research cabinet styles", emotionalTag: .creative, scheduledDate: tomorrow, priority: .low, estimatedDuration: 30, projectId: personalProject.id),
            
            // Day after tomorrow
            TodoTask(title: "Write blog post", emotionalTag: .creative, scheduledDate: dayAfter, priority: .medium, estimatedDuration: 90), // Standalone
            TodoTask(title: "Doctor appointment", emotionalTag: .timeSensitive, scheduledDate: dayAfter, priority: .high, estimatedDuration: 60), // Standalone
            TodoTask(title: "Code review session", emotionalTag: .focus, scheduledDate: dayAfter, priority: .high, estimatedDuration: 45, projectId: workProject.id),
            TodoTask(title: "Build practice app", emotionalTag: .challenging, scheduledDate: dayAfter, priority: .medium, estimatedDuration: 180, projectId: learningProject.id)
        ]
        
        // Sample suggestions based on emotional state
        let suggestionsList: [AdaptiveSuggestion] = [
            AdaptiveSuggestion(
                title: "You mentioned feeling drained today. Want to swap 'Review project proposal' with something lighter?",
                description: "Swap 'Review project proposal' with '10-minute meditation'",
                icon: "swap",
                priority: .medium,
                emotionalContext: "feeling drained",
                suggestedAction: .swap(with: UUID()),
                taskId: nil
            ),
            AdaptiveSuggestion(
                title: "Since you're working on work-life balance, how about scheduling some self-care time?",
                description: "Add 10-minute meditation to your schedule",
                icon: "add.circle",
                priority: .medium,
                emotionalContext: "work-life balance goal",
                suggestedAction: .addSelfCare,
                taskId: nil
            )
        ]
        session.suggestions = suggestionsList
        
        session.userEmotionalState = "feeling a bit overwhelmed"
        
        return session
    }
}

// MARK: - Date Extensions

extension Date {
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }
    
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
} 