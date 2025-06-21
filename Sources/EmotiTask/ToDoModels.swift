import Foundation
import SwiftUI

// MARK: - Emotional Tags

enum EmotionalTag: String, CaseIterable {
    case lowEnergy = "🧘‍♀️ low energy"
    case focus = "🔥 focus"
    case timeSensitive = "⏳ time sensitive"
    case creative = "🎨 creative"
    case social = "👥 social"
    case selfCare = "💚 self care"
    case routine = "📋 routine"
    case challenging = "💪 challenging"
    
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

// MARK: - Task Models

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
    var emotionalTag: EmotionalTag?
    var scheduledDate: Date
    var notes: String
    var priority: TaskPriority
    var estimatedDuration: Int // in minutes
    
    init(title: String, isCompleted: Bool = false, emotionalTag: EmotionalTag? = nil, scheduledDate: Date = Date(), notes: String = "", priority: TaskPriority = .medium, estimatedDuration: Int = 30) {
        self.title = title
        self.isCompleted = isCompleted
        self.emotionalTag = emotionalTag
        self.scheduledDate = scheduledDate
        self.notes = notes
        self.priority = priority
        self.estimatedDuration = estimatedDuration
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
    var relatedTasks: [UUID] // Task IDs
    
    var progressPercentage: Int {
        return Int(progress * 100)
    }
    
    var isCompleted: Bool {
        return progress >= 1.0
    }
}

enum GoalCategory: String, CaseIterable {
    case wellness = "🌱 Wellness"
    case career = "💼 Career"
    case relationships = "❤️ Relationships"
    case learning = "📚 Learning"
    case fitness = "💪 Fitness"
    case creativity = "🎨 Creativity"
    case finance = "💰 Finance"
    case home = "🏠 Home"
    
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
    let message: String
    let suggestedAction: SuggestionAction
    let taskId: UUID?
    let emotionalContext: String
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
    @Published var tasks: [Task]
    @Published var goals: [Goal]
    @Published var currentDate: Date
    @Published var weekDates: [Date]
    @Published var suggestions: [AdaptiveSuggestion]
    @Published var userEmotionalState: String // From chat context
    
    init() {
        self.tasks = []
        self.goals = []
        self.currentDate = Date()
        self.weekDates = Self.generateWeekDates(from: Date())
        self.suggestions = []
        self.userEmotionalState = "neutral"
    }
    
    var todayTasks: [Task] {
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
    
    func completeTask(_ taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].isCompleted = true
            updateGoalProgress(for: taskId)
        }
    }
    
    func rescheduleTask(_ taskId: UUID, to date: Date) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].scheduledDate = date
        }
    }
    
    private func updateGoalProgress(for taskId: UUID) {
        for goalIndex in goals.indices {
            if goals[goalIndex].relatedTasks.contains(taskId) {
                let totalTasks = goals[goalIndex].relatedTasks.count
                let completedTasks = goals[goalIndex].relatedTasks.filter { relatedTaskId in
                    tasks.first { $0.id == relatedTaskId }?.isCompleted ?? false
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
    
    func tasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return tasks.filter { calendar.isDate($0.scheduledDate, inSameDayAs: date) }
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
}

// MARK: - Dummy Data

extension ToDoSessionData {
    static func createDummyData() -> ToDoSessionData {
        let session = ToDoSessionData()
        
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
            // Today's tasks
            Task(title: "Review project proposal", emotionalTag: .focus, scheduledDate: today, priority: .high, estimatedDuration: 60),
            Task(title: "10-minute meditation", emotionalTag: .selfCare, scheduledDate: today, priority: .medium, estimatedDuration: 10),
            Task(title: "Call mom", emotionalTag: .social, scheduledDate: today, priority: .medium, estimatedDuration: 30),
            Task(title: "Grocery shopping", emotionalTag: .routine, scheduledDate: today, priority: .low, estimatedDuration: 45),
            Task(title: "Organize desk", emotionalTag: .lowEnergy, scheduledDate: today, priority: .low, estimatedDuration: 20),
            
            // Tomorrow's tasks
            Task(title: "Team meeting", emotionalTag: .social, scheduledDate: tomorrow, priority: .high, estimatedDuration: 90),
            Task(title: "SwiftUI tutorial", emotionalTag: .creative, scheduledDate: tomorrow, priority: .medium, estimatedDuration: 120),
            Task(title: "Workout", emotionalTag: .challenging, scheduledDate: tomorrow, priority: .medium, estimatedDuration: 45),
            
            // Day after tomorrow
            Task(title: "Write blog post", emotionalTag: .creative, scheduledDate: dayAfter, priority: .medium, estimatedDuration: 90),
            Task(title: "Doctor appointment", emotionalTag: .timeSensitive, scheduledDate: dayAfter, priority: .high, estimatedDuration: 60)
        ]
        
        // Sample suggestions based on emotional state
        session.suggestions = [
            AdaptiveSuggestion(
                message: "You mentioned feeling drained today. Want to swap 'Review project proposal' with something lighter?",
                suggestedAction: .swap(with: session.tasks.first { $0.emotionalTag == .routine }?.id ?? UUID()),
                taskId: session.tasks.first { $0.emotionalTag == .focus }?.id,
                emotionalContext: "feeling drained"
            ),
            AdaptiveSuggestion(
                message: "Since you're working on work-life balance, how about scheduling some self-care time?",
                suggestedAction: .addSelfCare,
                taskId: nil,
                emotionalContext: "work-life balance goal"
            )
        ]
        
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