import SwiftUI

struct CalendarView: View {
    @StateObject private var sessionData = ToDoSessionData.createDummyData()
    @State private var selectedDate = Date()
    @State private var showingTaskDetail = false
    @State private var selectedTask: Task?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar Header
                CalendarHeaderView(selectedDate: $selectedDate)
                
                // Calendar Grid
                CalendarGridView(
                    selectedDate: $selectedDate,
                    sessionData: sessionData
                )
                
                // Tasks for Selected Date
                if !tasksForSelectedDate.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(selectedDate.isToday ? "Today's Tasks" : "Tasks for \(selectedDate, formatter: dayFormatter)")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(tasksForSelectedDate.count) task\(tasksForSelectedDate.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(.black.opacity(0.6))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(tasksForSelectedDate) { task in
                                    CalendarTaskRow(
                                        task: task,
                                        sessionData: sessionData,
                                        onTaskTap: { selectedTask = task; showingTaskDetail = true }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 48))
                            .foregroundColor(.black.opacity(0.3))
                        
                        Text("No tasks scheduled")
                            .font(.headline)
                            .foregroundColor(.black.opacity(0.6))
                        
                        Text("for \(selectedDate, formatter: dayFormatter)")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.5))
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Calendar")
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
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task, sessionData: sessionData)
        }
    }
    
    private var tasksForSelectedDate: [Task] {
        sessionData.tasksForDate(selectedDate)
            .sorted { task1, task2 in
                if task1.isCompleted != task2.isCompleted {
                    return !task1.isCompleted
                }
                return task1.scheduledDate < task2.scheduledDate
            }
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}

struct CalendarHeaderView: View {
    @Binding var selectedDate: Date
    @State private var currentMonth = Date()
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black.opacity(0.7))
                }
                
                Spacer()
                
                Text(currentMonth, formatter: monthYearFormatter)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.black.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            
            // Weekday headers
            HStack {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.black.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let sessionData: ToDoSessionData
    @State private var currentMonth = Date()
    
    var body: some View {
        let daysInMonth = getDaysInMonth()
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(daysInMonth, id: \.self) { date in
                CalendarDayView(
                    date: date,
                    selectedDate: $selectedDate,
                    taskCount: sessionData.tasksForDate(date).count,
                    isCurrentMonth: Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let range = calendar.range(of: .day, in: .month, for: currentMonth) ?? 1..<32
        
        // Get the first day of the week for the month
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysFromPreviousMonth = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date] = []
        
        // Add days from previous month
        for i in (1...daysFromPreviousMonth).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Add days from current month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Add days from next month to fill the grid
        let remainingDays = 42 - days.count // 6 weeks * 7 days
        for i in 1...remainingDays {
            if let lastDay = days.last,
               let date = calendar.date(byAdding: .day, value: i, to: lastDay) {
                days.append(date)
            }
        }
        
        return days
    }
}

struct CalendarDayView: View {
    let date: Date
    @Binding var selectedDate: Date
    let taskCount: Int
    let isCurrentMonth: Bool
    
    var body: some View {
        Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(textColor)
                
                if taskCount > 0 {
                    Circle()
                        .fill(taskCount > 3 ? Color.red.opacity(0.8) : Color.blue.opacity(0.6))
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .black.opacity(0.3)
        } else if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .black.opacity(0.8)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .black.opacity(0.8)
        } else if isToday {
            return .blue.opacity(0.1)
        } else {
            return .clear
        }
    }
}

struct CalendarTaskRow: View {
    let task: Task
    let sessionData: ToDoSessionData
    let onTaskTap: () -> Void
    
    var body: some View {
        Button(action: onTaskTap) {
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
                        
                        Text(task.scheduledDate, formatter: timeFormatter)
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    HStack {
                        if let tag = task.emotionalTag {
                            Text(tag.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(tag.color.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.black.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Text("\(task.estimatedDuration)min")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.5))
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct TaskDetailView: View {
    let task: Task
    let sessionData: ToDoSessionData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text(task.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                    
                    if !task.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(task.notes)
                                .font(.body)
                                .foregroundColor(.black.opacity(0.8))
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Scheduled")
                                .font(.caption)
                                .foregroundColor(.black.opacity(0.6))
                            Text(task.scheduledDate, formatter: dateTimeFormatter)
                                .font(.body)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Duration")
                                .font(.caption)
                                .foregroundColor(.black.opacity(0.6))
                            Text("\(task.estimatedDuration) min")
                                .font(.body)
                                .foregroundColor(.black)
                        }
                    }
                    
                    if let tag = task.emotionalTag {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Emotional Tag")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(tag.rawValue)
                                .font(.body)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(tag.color.opacity(0.2))
                                .cornerRadius(12)
                                .foregroundColor(.black.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Task Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
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
    
    private var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    CalendarView()
} 