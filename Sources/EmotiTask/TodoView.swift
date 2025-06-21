import SwiftUI

struct TodoView: View {
    @StateObject private var sessionData = ToDoSessionData.createDummyData()
    @State private var showingNewTask = false
    @State private var showingNewProject = false
    @State private var selectedProject: Project?
    @State private var showingAllTasks = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview Cards Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        // All Tasks Card
                        OverviewCard(
                            title: "All",
                            count: sessionData.tasks.count,
                            icon: "tray.fill",
                            iconColor: .black.opacity(0.6),
                            action: {
                                showingAllTasks = true
                            }
                        )
                        
                        // Completed Tasks Card
                        OverviewCard(
                            title: "Completed",
                            count: sessionData.tasks.filter { $0.isCompleted }.count,
                            icon: "checkmark.circle.fill",
                            iconColor: .green,
                            action: {}
                        )
                        
                        // Today Tasks Card
                        OverviewCard(
                            title: "Today",
                            count: sessionData.todayTasks.count,
                            icon: "calendar",
                            iconColor: .blue,
                            action: {}
                        )
                        
                        // Scheduled Tasks Card
                        OverviewCard(
                            title: "Scheduled",
                            count: sessionData.tasks.filter { !Calendar.current.isDateInToday($0.scheduledDate) }.count,
                            icon: "calendar.badge.clock",
                            iconColor: .orange,
                            action: {}
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // My Projects Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("My Projects")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        
                        // Project Lists
                        ForEach(sessionData.projects) { project in
                            ProjectListCard(
                                project: project,
                                taskCount: sessionData.tasksForProject(project.id).count,
                                action: {
                                    selectedProject = project
                                }
                            )
                        }
                        .onDelete(perform: deleteProjects)
                        
                        // Add Project Button
                        Button(action: { showingNewProject = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.black.opacity(0.7))
                                
                                Text("Add Project")
                                    .font(.body)
                                    .foregroundColor(.black.opacity(0.7))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    
                    Spacer(minLength: 120) // Space for floating tab bar
                }
                .padding(.top, 8)
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showingNewTask = true }) {
                            Label("New Task", systemImage: "plus.circle")
                        }
                        
                        Button(action: { showingNewProject = true }) {
                            Label("New Project", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.black.opacity(0.8))
                    }
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
        .sheet(isPresented: $showingNewTask) {
            NewTaskView(projectId: nil) { task in
                sessionData.addTask(task)
            }
        }
        .sheet(isPresented: $showingNewProject) {
            NewProjectView { project in
                sessionData.addProject(project)
            }
        }
        .sheet(item: $selectedProject) { project in
            ProjectDetailView(project: project, sessionData: sessionData)
        }
        .sheet(isPresented: $showingAllTasks) {
            AllTasksView(sessionData: sessionData)
        }
    }
    
    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            let project = sessionData.projects[index]
            sessionData.deleteProject(project.id)
        }
    }
}

// MARK: - Overview Card

struct OverviewCard: View {
    let title: String
    let count: Int
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(iconColor)
                    
                    Spacer()
                    
            Text("\(count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            
            Text(title)
                    .font(.body)
                    .foregroundColor(.black.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color.white.opacity(0.8))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Project List Card

struct ProjectListCard: View {
    let project: Project
    let taskCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: project.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(project.color)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    if !project.description.isEmpty {
                        Text(project.description)
                .font(.caption)
                            .foregroundColor(.black.opacity(0.6))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Text("\(taskCount)")
                    .font(.body)
                .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.7))
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.8))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Task Card

struct TaskCard: View {
    let task: Task
    @ObservedObject var sessionData: ToDoSessionData
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                sessionData.completeTask(task.id)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : .black.opacity(0.4))
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .foregroundColor(.black)
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: 8) {
                    if let tag = task.emotionalTag {
                        Text(tag.rawValue)
                    .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(tag.color.opacity(0.2))
                            .cornerRadius(6)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    
                    Text(task.scheduledDate, formatter: dateTimeFormatter)
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.5))
                    
                    Spacer()
                    
                    Text("\(task.estimatedDuration)min")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.5))
                }
            }
            
            Spacer()
            
            // Priority Indicator
            if task.priority == .high || task.priority == .urgent {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
    
    private var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(task.scheduledDate) {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        }
        return formatter
    }
}

// MARK: - New Project View

struct NewProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedColor = Color.blue
    @State private var selectedIcon = "folder.fill"
    
    let onSave: (Project) -> Void
    
    let projectColors: [Color] = [.blue, .green, .purple, .orange, .red, .pink, .teal, .indigo]
    let projectIcons = ["folder.fill", "briefcase.fill", "house.fill", "book.fill", "heart.fill", "star.fill", "flag.fill", "target"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project Name")
                            .font(.headline)
                            .foregroundColor(.black)
                        TextField("Enter project name", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.headline)
                            .foregroundColor(.black)
                        TextField("Project description", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(projectColors, id: \.self) { color in
                                Button(action: { selectedColor = color }) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black.opacity(0.3), lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Icon")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(projectIcons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedColor)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedColor.opacity(0.1))
                                                .stroke(selectedColor.opacity(selectedIcon == icon ? 0.5 : 0), lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    Button("Create Project") {
                        let newProject = Project(
                            title: title,
                            description: description,
                            color: selectedColor,
                            icon: selectedIcon
                        )
                        onSave(newProject)
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
            .navigationTitle("New Project")
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

// MARK: - New Task View

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var notes = ""
    @State private var scheduledDate = Date()
    @State private var priority: TaskPriority = .medium
    @State private var emotionalTag: EmotionalTag? = nil
    @State private var estimatedDuration = 30
    
    let projectId: UUID?
    let onSave: (Task) -> Void
    
    init(projectId: UUID? = nil, onSave: @escaping (Task) -> Void) {
        self.projectId = projectId
        self.onSave = onSave
    }
    
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
                        Text("Tag (Optional)")
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
                            estimatedDuration: estimatedDuration,
                            projectId: projectId
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

// MARK: - Project Detail View

struct ProjectDetailView: View {
    let project: Project
    @ObservedObject var sessionData: ToDoSessionData
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewTask = false
    
    var projectTasks: [Task] {
        sessionData.tasksForProject(project.id)
            .sorted { task1, task2 in
                if task1.isCompleted != task2.isCompleted {
                    return !task1.isCompleted // Incomplete tasks first
                }
                return task1.scheduledDate < task2.scheduledDate
            }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Project Header
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: project.icon)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(project.color)
                                .cornerRadius(16)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(project.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                if !project.description.isEmpty {
                                    Text(project.description)
                                        .font(.body)
                                        .foregroundColor(.black.opacity(0.7))
                                }
                                
                                Text("\(project.completedTasksCount)/\(project.totalTasksCount) completed")
                                    .font(.caption)
                                    .foregroundColor(.black.opacity(0.6))
                            }
                            
                            Spacer()
                        }
                        
                        // Progress Bar
                        if project.totalTasksCount > 0 {
                            ProgressView(value: project.progress)
                                .tint(project.color)
                                .scaleEffect(y: 2)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 16)
                    
                    // Tasks List
                    if projectTasks.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "checklist")
                                .font(.system(size: 48))
                                .foregroundColor(.black.opacity(0.3))
                            
                            Text("No tasks yet")
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.6))
                            
                            Text("Add your first task to get started")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.5))
                                .multilineTextAlignment(.center)
                            
                            Button("Add Task") {
                                showingNewTask = true
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(project.color)
                            .cornerRadius(20)
                        }
                        .padding(40)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(projectTasks) { task in
                                ProjectTaskCard(task: task, sessionData: sessionData, projectColor: project.color)
                            }
                            .onDelete(perform: deleteProjectTasks)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 8)
            }
            .navigationTitle(project.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.black.opacity(0.7))
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNewTask = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.black.opacity(0.8))
                    }
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
        .sheet(isPresented: $showingNewTask) {
            NewTaskView(projectId: project.id) { task in
                sessionData.addTask(task)
            }
        }
    }
    
    private func deleteProjectTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = projectTasks[index]
            sessionData.deleteTask(task.id)
        }
    }
}

// MARK: - Project Task Card

struct ProjectTaskCard: View {
    let task: Task
    @ObservedObject var sessionData: ToDoSessionData
    let projectColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                sessionData.completeTask(task.id)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? projectColor : .black.opacity(0.4))
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .foregroundColor(.black)
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: 8) {
                    if let tag = task.emotionalTag {
                        Text(tag.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(tag.color.opacity(0.2))
                            .cornerRadius(6)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    
                    Text(task.scheduledDate, formatter: dateTimeFormatter)
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.5))
                    
                    Spacer()
                    
                    Text("\(task.estimatedDuration)min")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.5))
                }
                
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Priority Indicator
            if task.priority == .high || task.priority == .urgent {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(task.scheduledDate) {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        }
        return formatter
    }
}

// MARK: - All Tasks View

struct AllTasksView: View {
    @ObservedObject var sessionData: ToDoSessionData
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewTask = false
    
    var allTasks: [Task] {
        sessionData.tasks
            .sorted { task1, task2 in
                if task1.isCompleted != task2.isCompleted {
                    return !task1.isCompleted // Incomplete tasks first
                }
                return task1.scheduledDate < task2.scheduledDate
            }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Summary Header
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "tray.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(.black.opacity(0.6))
                                .cornerRadius(16)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("All Tasks")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                Text("Complete overview of all your tasks")
                                    .font(.body)
                                    .foregroundColor(.black.opacity(0.7))
                                
                                Text("\(sessionData.tasks.filter { $0.isCompleted }.count)/\(sessionData.tasks.count) completed")
                                    .font(.caption)
                                    .foregroundColor(.black.opacity(0.6))
                            }
                            
                            Spacer()
                        }
                        
                        // Progress Bar
                        if sessionData.tasks.count > 0 {
                            let progress = Double(sessionData.tasks.filter { $0.isCompleted }.count) / Double(sessionData.tasks.count)
                            ProgressView(value: progress)
                                .tint(.black.opacity(0.6))
                                .scaleEffect(y: 2)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 16)
                    
                    // Tasks List
                    if allTasks.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "checklist")
                                .font(.system(size: 48))
                                .foregroundColor(.black.opacity(0.3))
                            
                            Text("No tasks yet")
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.6))
                            
                            Text("Create your first task to get started")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.5))
                                .multilineTextAlignment(.center)
                            
                            Button("Add Task") {
                                showingNewTask = true
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.black.opacity(0.6))
                            .cornerRadius(20)
                        }
                        .padding(40)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(allTasks) { task in
                                AllTaskCard(task: task, sessionData: sessionData)
                            }
                            .onDelete(perform: deleteTasks)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 8)
            }
            .navigationTitle("All Tasks")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.black.opacity(0.7))
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNewTask = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.black.opacity(0.8))
                    }
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
        .sheet(isPresented: $showingNewTask) {
            NewTaskView(projectId: nil) { task in
                sessionData.addTask(task)
            }
        }
    }
    
    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = allTasks[index]
            sessionData.deleteTask(task.id)
        }
    }
}

// MARK: - All Task Card

struct AllTaskCard: View {
    let task: Task
    @ObservedObject var sessionData: ToDoSessionData
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                sessionData.completeTask(task.id)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : .black.opacity(0.4))
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.body)
                        .foregroundColor(.black)
                        .strikethrough(task.isCompleted)
                    
                    Spacer()
                    
                    // Project indicator
                    if let projectId = task.projectId,
                       let project = sessionData.projects.first(where: { $0.id == projectId }) {
                        HStack(spacing: 4) {
                            Image(systemName: project.icon)
                                .font(.caption)
                                .foregroundColor(project.color)
                            Text(project.title)
                                .font(.caption)
                                .foregroundColor(.black.opacity(0.6))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(project.color.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                
                HStack(spacing: 8) {
                    if let tag = task.emotionalTag {
                        Text(tag.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(tag.color.opacity(0.2))
                            .cornerRadius(6)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    
                    Text(task.scheduledDate, formatter: dateTimeFormatter)
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.5))
                    
                    Spacer()
                    
                    Text("\(task.estimatedDuration)min")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.5))
                }
                
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Priority Indicator
            if task.priority == .high || task.priority == .urgent {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(task.scheduledDate) {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        }
        return formatter
    }
}

#Preview {
    TodoView()
} 