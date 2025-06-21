import SwiftUI

struct TodoView: View {
    @StateObject private var taskService = TaskService()
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var selectedEmotionalTag: EmotionalTag = .routine
    @State private var selectedPriority: TaskPriority = .medium
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with connection status
                    headerSection
                    
                    // Goals at a Glance
                    goalsSection
                    
                    // Today's Tasks
                    todayTasksSection
                    
                    // Adaptive Suggestions
                    adaptiveSuggestionsSection
                }
                .padding()
            }
            .navigationTitle("EmotiTask")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { taskService.loadTasks() }) {
                        Image(systemName: "arrow.clockwise")
                            .opacity(taskService.isLoading ? 0.5 : 1.0)
                    }
                    .disabled(taskService.isLoading)
                }
            }
            .sheet(isPresented: $showingAddTask) {
                addTaskSheet
            }
            .refreshable {
                taskService.loadTasks()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Good morning! 🌅")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                connectionStatusView
            }
            
            if taskService.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading tasks...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if let error = taskService.error {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("You have \(incompleteTasks.count) tasks for today")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var connectionStatusView: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(TaskServiceConfig.backendEnabled ? .green : .orange)
                .frame(width: 8, height: 8)
            Text(TaskServiceConfig.backendEnabled ? "Live" : "Local")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goals at a Glance")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(sampleGoals) { goal in
                        goalCard(goal)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var todayTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Tasks")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(completedTasks.count)/\(taskService.tasks.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Mini timeline
            miniTimeline
            
            // Task list
            LazyVStack(spacing: 8) {
                ForEach(taskService.tasks) { task in
                    taskRow(task)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var adaptiveSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Adaptive Suggestions")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(adaptiveSuggestions, id: \.title) { suggestion in
                suggestionCard(suggestion)
            }
        }
    }
    
    private var addTaskSheet: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task title", text: $newTaskTitle)
                    
                    Picker("Emotional Tag", selection: $selectedEmotionalTag) {
                        ForEach(EmotionalTag.allCases, id: \.self) { tag in
                            Text(tag.rawValue.capitalized).tag(tag)
                        }
                    }
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                }
            }
            .navigationTitle("Add Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddTask = false
                        resetAddTaskForm()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add") {
                        addNewTask()
                        showingAddTask = false
                        resetAddTaskForm()
                    }
                    .disabled(newTaskTitle.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func goalCard(_ goal: Goal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            Text(goal.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
            
            ProgressView(value: goal.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding()
        .frame(width: 160)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var miniTimeline: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(taskService.tasks.enumerated()), id: \.element.id) { index, task in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(task.isCompleted ? .green : emotionalTagColor(task.emotionalTag))
                            .frame(width: 12, height: 12)
                        
                        Text(timeString(for: task.scheduledDate, offset: index * 30))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func taskRow(_ task: Task) -> some View {
        HStack(spacing: 12) {
            // Completion button
            Button(action: { taskService.toggleTaskCompletion(task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                HStack {
                    if let tag = task.emotionalTag {
                        Text(tag.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(emotionalTagColor(tag).opacity(0.2))
                            .foregroundColor(emotionalTagColor(tag))
                            .cornerRadius(8)
                    }
                    
                    Text("\(task.estimatedDuration) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    priorityIndicator(task.priority)
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: { taskService.deleteTask(task) }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func suggestionCard(_ suggestion: AdaptiveSuggestion) -> some View {
        HStack(spacing: 12) {
            Image(systemName: suggestion.icon)
                .foregroundColor(.blue)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(suggestion.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { applySuggestion(suggestion) }) {
                Text("Apply")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Helper Functions
    
    private var incompleteTasks: [Task] {
        taskService.tasks.filter { !$0.isCompleted }
    }
    
    private var completedTasks: [Task] {
        taskService.tasks.filter { $0.isCompleted }
    }
    
    private func emotionalTagColor(_ tag: EmotionalTag?) -> Color {
        guard let tag = tag else { return .gray }
        switch tag {
        case .lowEnergy: return .purple
        case .focus: return .blue
        case .timeSensitive: return .red
        case .creative: return .orange
        case .social: return .green
        case .selfCare: return .pink
        case .routine: return .gray
        case .challenging: return .indigo
        }
    }
    
    private func priorityIndicator(_ priority: TaskPriority) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<priority.level, id: \.self) { _ in
                Circle()
                    .fill(priorityColor(priority))
                    .frame(width: 4, height: 4)
            }
        }
    }
    
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .urgent: return .purple
        }
    }
    
    private func timeString(for date: Date, offset: Int) -> String {
        let adjustedDate = Calendar.current.date(byAdding: .minute, value: offset, to: date) ?? date
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: adjustedDate)
    }
    
    private func addNewTask() {
        let newTask = Task(
            title: newTaskTitle,
            notes: "",
            emotionalTag: selectedEmotionalTag,
            priority: selectedPriority
        )
        
        taskService.addTask(newTask)
        showingAddTask = false
        resetAddTaskForm()
    }
    
    private func resetAddTaskForm() {
        newTaskTitle = ""
        selectedEmotionalTag = .routine
        selectedPriority = .medium
    }
    
    private func applySuggestion(_ suggestion: AdaptiveSuggestion) {
        let newTask = Task(
            title: suggestion.title,
            notes: suggestion.description,
            emotionalTag: .selfCare,
            priority: .medium
        )
        taskService.addTask(newTask)
    }
    
    // MARK: - Sample Data
    
    private var sampleGoals: [Goal] {
        [
            Goal(
                title: "Improve Work-Life Balance",
                description: "Create better boundaries between work and personal time",
                targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                progress: 0.4,
                category: .wellness,
                relatedTasks: []
            ),
            Goal(
                title: "Learn SwiftUI",
                description: "Master SwiftUI for iOS development",
                targetDate: Calendar.current.date(byAdding: .day, value: 60, to: Date()) ?? Date(),
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
    }
    
    private var adaptiveSuggestions: [AdaptiveSuggestion] {
        [
            AdaptiveSuggestion(
                title: "Take a mindful break",
                description: "You've been focused for a while. A 5-minute breathing exercise could help.",
                icon: "leaf.fill",
                priority: .medium,
                emotionalContext: "Based on your focus-heavy tasks"
            ),
            AdaptiveSuggestion(
                title: "Review tomorrow's priorities",
                description: "End your day by setting intentions for tomorrow.",
                icon: "calendar",
                priority: .low,
                emotionalContext: "Evening routine suggestion"
            )
        ]
    }
}

// MARK: - Extensions

extension TaskPriority {
    var level: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .urgent: return 4
        }
    }
}

#Preview {
    TodoView()
} 