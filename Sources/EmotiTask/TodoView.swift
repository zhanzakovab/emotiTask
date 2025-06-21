import SwiftUI

struct TodoView: View {
    @StateObject private var toDoSession = ToDoSessionData.createDummyData()
    @State private var selectedDate = Date()
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
        GeometryReader { geometry in
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.8, blue: 0.7),
                        Color(red: 1.0, green: 0.7, blue: 0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Goals at a Glance - Top Section
                        GoalsSection(goals: toDoSession.goals)
                        
                        // Week Timeline - Mini Calendar
                        WeekTimeline(
                            weekDates: toDoSession.weekDates,
                            selectedDate: $selectedDate,
                            toDoSession: toDoSession
                        )
                        
                        // Today's Tasks - Middle Section
                        TasksSection(
                            tasks: tasksForSelectedDate,
                            onTaskComplete: { taskId in
                                toDoSession.completeTask(taskId)
                            }
                        )
                        
                        // Adaptive Suggestions - Bottom Section
                        if !toDoSession.suggestions.isEmpty {
                            SuggestionsSection(
                                suggestions: toDoSession.suggestions,
                                emotionalState: toDoSession.userEmotionalState
                            )
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Your Day")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            NewTaskView { newTask in
                toDoSession.addTask(newTask)
            }
        }
    }
    
    private var tasksForSelectedDate: [Task] {
        toDoSession.tasksForDate(selectedDate)
    }
}

// MARK: - Goals Section

struct GoalsSection: View {
    let goals: [Goal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 Goals at a Glance")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(goals) { goal in
                        GoalWidget(goal: goal)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct GoalWidget: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.7))
                Spacer()
                Text("\(goal.progressPercentage)%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.8))
            }
            
            Text(goal.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 4)
                    .frame(width: 45, height: 45)
                
                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(Color.black.opacity(0.7), lineWidth: 4)
                    .frame(width: 45, height: 45)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: goal.progress)
                
                Text("\(goal.progressPercentage)%")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.black.opacity(0.8))
            }
        }
        .padding(16)
        .frame(width: 180, height: 130)
        .background(Color.white.opacity(0.85))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Week Timeline

struct WeekTimeline: View {
    let weekDates: [Date]
    @Binding var selectedDate: Date
    let toDoSession: ToDoSessionData
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📅 This Week")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(weekDates, id: \.self) { date in
                    DayButton(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        taskCount: toDoSession.tasksForDate(date).count,
                        onTap: { selectedDate = date }
                    )
                }
            }
        }
    }
}

struct DayButton: View {
    let date: Date
    let isSelected: Bool
    let taskCount: Int
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            Text(date.dayOfWeek.uppercased())
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .black.opacity(0.7))
            
            Text(date.dayNumber)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .black)
            
            // Task indicator dot
            Circle()
                .fill(taskCount > 0 ? 
                      (isSelected ? Color.white.opacity(0.8) : Color.black.opacity(0.4)) : 
                      Color.clear)
                .frame(width: taskCount > 0 ? 6 : 4, height: taskCount > 0 ? 6 : 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.black.opacity(0.75) : Color.white.opacity(0.7))
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                onTap()
            }
        }
    }
}

// MARK: - Tasks Section

struct TasksSection: View {
    let tasks: [Task]
    let onTaskComplete: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("✅ Today")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Spacer()
                if !tasks.isEmpty {
                    let completed = tasks.filter { $0.isCompleted }.count
                    Text("\(completed)/\(tasks.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(8)
                }
            }
            
            if tasks.isEmpty {
                EmptyTasksMessage()
            } else {
                VStack(spacing: 12) {
                    ForEach(tasks) { task in
                        TaskRow(
                            task: task,
                            onComplete: { onTaskComplete(task.id) }
                        )
                    }
                }
            }
        }
    }
}

struct TaskRow: View {
    let task: Task
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Completion checkbox
            Button(action: onComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : .black.opacity(0.4))
                    .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
            }
            .disabled(task.isCompleted)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                Text(task.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(task.isCompleted ? .black.opacity(0.5) : .black)
                    .strikethrough(task.isCompleted)
                
                    Spacer()
                    
                    // Emotional tag
                    if let emotionalTag = task.emotionalTag {
                        Text(emotionalTag.rawValue)
                    .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
                
                HStack {
                    Text("⏱ \(task.estimatedDuration) min")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                    
                    Spacer()
                    
                    // Priority indicator
                    Circle()
                        .fill(priorityColor(for: task.priority))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(task.isCompleted ? 0.5 : 0.9))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
    }
    
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .blue  
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

struct EmptyTasksMessage: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "party.popper")
                .font(.system(size: 48))
                .foregroundColor(.black.opacity(0.3))
            
            Text("All done for today!")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(0.7))
            
            Text("You've completed all your tasks.\nTake a moment to celebrate! 🎉")
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(Color.white.opacity(0.7))
        .cornerRadius(16)
    }
}

// MARK: - Suggestions Section

struct SuggestionsSection: View {
    let suggestions: [AdaptiveSuggestion]
    let emotionalState: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💡 Adaptive Suggestions")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Text("Based on your current state: \(emotionalState)")
                .font(.caption)
                .foregroundColor(.black.opacity(0.6))
                .italic()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.5))
                .cornerRadius(8)
            
            VStack(spacing: 12) {
                ForEach(suggestions) { suggestion in
                    SuggestionCard(suggestion: suggestion)
                }
            }
        }
    }
}

struct SuggestionCard: View {
    let suggestion: AdaptiveSuggestion
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "lightbulb.fill")
                .font(.title3)
                .foregroundColor(.yellow.opacity(0.9))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.message)
                    .font(.body)
                    .foregroundColor(.black)
                    .lineLimit(nil)
                
                Text("Context: \(suggestion.emotionalContext)")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.6))
            }
            
            Spacer()
            
            Button("Try it") {
                print("Applying suggestion: \(suggestion.message)")
            }
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.15))
            .cornerRadius(16)
            .foregroundColor(.black.opacity(0.8))
        }
        .padding(16)
        .background(Color.white.opacity(0.85))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
    }
}

// MARK: - New Task View

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var notes = ""
    @State private var scheduledDate = Date()
    @State private var priority: TaskPriority = .medium
    @State private var emotionalTag: EmotionalTag? = nil
    @State private var estimatedDuration = 30
    
    let onSave: (Task) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Title")
                        .font(.headline)
                            .foregroundColor(.black)
                        TextField("What needs to be done?", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
                        .font(.headline)
                            .foregroundColor(.black)
                        TextField("Any additional details...", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                        Text("When")
                            .font(.headline)
                            .foregroundColor(.black)
                        DatePicker("", selection: $scheduledDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Priority")
                            .font(.headline)
                            .foregroundColor(.black)
                        Picker("Priority", selection: $priority) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Emotional Context (Optional)")
                        .font(.headline)
                            .foregroundColor(.black)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                Button("None") {
                                    emotionalTag = nil
                                }
                                .foregroundColor(emotionalTag == nil ? .white : .black.opacity(0.7))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(emotionalTag == nil ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
                                .cornerRadius(20)
                                
                                ForEach(EmotionalTag.allCases, id: \.self) { tag in
                                    Button(tag.rawValue) {
                                        emotionalTag = tag
                                    }
                                    .foregroundColor(emotionalTag == tag ? .white : .black.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(emotionalTag == tag ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
                                    .cornerRadius(20)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estimated Duration")
                            .font(.headline)
                            .foregroundColor(.black)
                        HStack {
                            Text("\(estimatedDuration) minutes")
                                .foregroundColor(.black.opacity(0.7))
                Spacer()
                            Stepper("", value: $estimatedDuration, in: 5...480, step: 5)
                        }
                    }
                    
                    Spacer(minLength: 40)
                
                    Button("Create Task") {
                        let newTask = Task(
                        title: title,
                            emotionalTag: emotionalTag,
                            scheduledDate: scheduledDate,
                            notes: notes,
                            priority: priority,
                            estimatedDuration: estimatedDuration
                    )
                    onSave(newTask)
                    dismiss()
                }
                .disabled(title.isEmpty)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(title.isEmpty ? Color.gray : Color.black.opacity(0.8))
                    .cornerRadius(28)
                }
                .padding(20)
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black.opacity(0.7))
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.9, blue: 0.8),
                        Color(red: 1.0, green: 0.8, blue: 0.7)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    TodoView()
} 