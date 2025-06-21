import SwiftUI

struct TaskItem {
    let id = UUID()
    let title: String
    let description: String
    let dueDate: Date
    var isCompleted: Bool
    let priority: TaskPriority
}

enum TaskPriority {
    case high, medium, low
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

struct TodoView: View {
    @State private var tasks: [TaskItem] = [
        TaskItem(title: "Morning Reflection", description: "Take 5 minutes to journal about your mood", dueDate: Date(), isCompleted: false, priority: .medium),
        TaskItem(title: "Complete Project Proposal", description: "Finish the quarterly project proposal draft", dueDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(), isCompleted: false, priority: .high),
        TaskItem(title: "Team Check-in", description: "Weekly sync with the development team", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), isCompleted: false, priority: .medium),
        TaskItem(title: "Exercise", description: "30-minute walk or workout session", dueDate: Date(), isCompleted: true, priority: .low)
    ]
    @State private var showingAddTask = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    // Character with task focus
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.3))
                            .frame(width: 60, height: 60)
                        
                        // Focused face
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 4, height: 4)
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 4, height: 4)
                            }
                            
                            // Determined mouth
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 8, height: 2)
                        }
                        
                        // Task list icon
                        VStack {
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 20, height: 20)
                                    
                                    Image(systemName: "list.clipboard")
                                        .foregroundColor(.white)
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .offset(x: -5, y: -5)
                            }
                            Spacer()
                        }
                    }
                    .frame(width: 60, height: 60)
                    
                    VStack(spacing: 4) {
                        Text("Your Tasks")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Stay organized and productive")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Task Stats
                HStack(spacing: 20) {
                    TaskStatCard(
                        title: "Completed",
                        count: tasks.filter { $0.isCompleted }.count,
                        color: .green
                    )
                    
                    TaskStatCard(
                        title: "Pending",
                        count: tasks.filter { !$0.isCompleted }.count,
                        color: .orange
                    )
                    
                    TaskStatCard(
                        title: "Today",
                        count: todayTasks.count,
                        color: .blue
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Tasks List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                            TaskCard(task: task) {
                                tasks[index].isCompleted.toggle()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Add Task Button
                Button(action: {
                    showingAddTask = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Add New Task")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.3),
                    Color.pink.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .sheet(isPresented: $showingAddTask) {
            AddTaskView { newTask in
                tasks.append(newTask)
            }
        }
    }
    
    private var todayTasks: [TaskItem] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        return tasks.filter { task in
            task.dueDate >= today && task.dueDate < tomorrow
        }
    }
}

struct TaskStatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

struct TaskCard: View {
    let task: TaskItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Completion button
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray.opacity(0.6))
            }
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(formatDueDate(task.dueDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Priority indicator
                    Circle()
                        .fill(task.priority.color)
                        .frame(width: 8, height: 8)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(task.isCompleted ? 0.6 : 0.9))
                .shadow(
                    color: .gray.opacity(task.isCompleted ? 0.1 : 0.2),
                    radius: task.isCompleted ? 2 : 4,
                    x: 0,
                    y: task.isCompleted ? 1 : 2
                )
        )
        .scaleEffect(task.isCompleted ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.timeStyle = .short
            return "Today, \(formatter.string(from: date))"
        } else if Calendar.current.isDateInTomorrow(date) {
            formatter.timeStyle = .short
            return "Tomorrow, \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var priority: TaskPriority = .medium
    
    let onSave: (TaskItem) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Title")
                        .font(.headline)
                    TextField("Enter task title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    TextField("Enter task description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Due Date")
                        .font(.headline)
                    DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                Spacer()
                
                Button("Save Task") {
                    let newTask = TaskItem(
                        title: title,
                        description: description,
                        dueDate: dueDate,
                        isCompleted: false,
                        priority: priority
                    )
                    onSave(newTask)
                    dismiss()
                }
                .disabled(title.isEmpty)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(title.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(25)
            }
            .padding()
            .navigationTitle("New Task")
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
}

#Preview {
    TodoView()
} 