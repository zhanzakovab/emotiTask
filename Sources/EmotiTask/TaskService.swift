import Foundation

// MARK: - Task API Service

class TaskService: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let session = URLSession.shared
    
    init() {
        loadTasks()
    }
    
    // MARK: - Task Operations
    
    func loadTasks() {
        guard TaskServiceConfig.backendEnabled else {
            loadMockTasks()
            return
        }
        
        isLoading = true
        error = nil
        
        guard let url = URL(string: TaskServiceConfig.tasksEndpoint) else {
            error = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = TaskServiceConfig.timeoutInterval
        
        // Add headers
        for (key, value) in TaskServiceConfig.defaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = "Network error: \(error.localizedDescription)"
                    self?.loadMockTasks() // Fallback to mock data
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.error = "Invalid response"
                    self?.loadMockTasks()
                    return
                }
                
                if httpResponse.statusCode == 401 {
                    self?.error = "Authentication required"
                    self?.loadMockTasks()
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    self?.error = "Server error: \(httpResponse.statusCode)"
                    self?.loadMockTasks()
                    return
                }
                
                guard let data = data else {
                    self?.error = "No data received"
                    self?.loadMockTasks()
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(TasksResponse.self, from: data)
                    self?.tasks = response.tasks.map { self?.convertBackendTask($0) ?? Task.sample() }
                    if TaskServiceConfig.debugLogging {
                        print("✅ Loaded \(response.tasks.count) tasks from backend")
                    }
                } catch {
                    self?.error = "Failed to decode tasks: \(error.localizedDescription)"
                    self?.loadMockTasks()
                }
            }
        }.resume()
    }
    
    func addTask(_ task: Task) {
        // Optimistic update
        tasks.append(task)
        
        guard TaskServiceConfig.backendEnabled else {
            return
        }
        
        // Sync with backend
        syncTaskToBackend(task, method: "POST")
    }
    
    func updateTask(_ task: Task) {
        // Optimistic update
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
        
        guard TaskServiceConfig.backendEnabled else {
            return
        }
        
        // Sync with backend
        syncTaskToBackend(task, method: "PUT")
    }
    
    func deleteTask(_ task: Task) {
        // Optimistic update
        tasks.removeAll { $0.id == task.id }
        
        guard TaskServiceConfig.backendEnabled else {
            return
        }
        
        // Sync with backend
        deleteTaskFromBackend(task)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updateTask(updatedTask)
    }
    
    // MARK: - Backend Sync
    
    private func syncTaskToBackend(_ task: Task, method: String) {
        let endpoint = method == "POST" ? TaskServiceConfig.tasksEndpoint : "\(TaskServiceConfig.tasksEndpoint)/\(task.id)"
        
        guard let url = URL(string: endpoint) else {
            if TaskServiceConfig.debugLogging {
                print("❌ Invalid URL for task sync: \(endpoint)")
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = TaskServiceConfig.timeoutInterval
        
        // Add headers
        for (key, value) in TaskServiceConfig.defaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let backendTask = convertToBackendTask(task)
            request.httpBody = try JSONEncoder().encode(backendTask)
        } catch {
            if TaskServiceConfig.debugLogging {
                print("❌ Failed to encode task: \(error)")
            }
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            if TaskServiceConfig.debugLogging {
                if let error = error {
                    print("❌ Task sync failed: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("✅ Task synced with status: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    private func deleteTaskFromBackend(_ task: Task) {
        let endpoint = "\(TaskServiceConfig.tasksEndpoint)/\(task.id)"
        
        guard let url = URL(string: endpoint) else {
            if TaskServiceConfig.debugLogging {
                print("❌ Invalid URL for task deletion: \(endpoint)")
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.timeoutInterval = TaskServiceConfig.timeoutInterval
        
        // Add headers
        for (key, value) in TaskServiceConfig.defaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        session.dataTask(with: request) { data, response, error in
            if TaskServiceConfig.debugLogging {
                if let error = error {
                    print("❌ Task deletion failed: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("✅ Task deleted with status: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    // MARK: - Data Conversion
    
    private func convertToBackendTask(_ task: Task) -> BackendTask {
        return BackendTask(
            title: task.title,
            notes: task.notes,
            is_completed: task.isCompleted,
            emotional_tag: task.emotionalTag?.rawValue,
            scheduled_date: ISO8601DateFormatter().string(from: task.scheduledDate),
            priority: task.priority.rawValue,
            estimated_duration: task.estimatedDuration,
            project_id: nil
        )
    }
    
    private func convertBackendTask(_ backendTask: BackendTaskResponse) -> Task {
        let dateFormatter = ISO8601DateFormatter()
        let scheduledDate = dateFormatter.date(from: backendTask.scheduled_date) ?? Date()
        
        return Task(
            id: backendTask.id,
            title: backendTask.title,
            notes: backendTask.notes,
            isCompleted: backendTask.is_completed,
            emotionalTag: EmotionalTag(rawValue: backendTask.emotional_tag ?? "routine"),
            scheduledDate: scheduledDate,
            priority: TaskPriority(rawValue: backendTask.priority) ?? .medium,
            estimatedDuration: backendTask.estimated_duration
        )
    }
    
    // MARK: - Mock Data (Fallback)
    
    private func loadMockTasks() {
        tasks = [
            Task(
                title: "10-minute meditation",
                notes: "Daily mindfulness practice",
                emotionalTag: .selfCare,
                priority: .medium,
                estimatedDuration: 10
            ),
            Task(
                title: "Review project proposal",
                notes: "Go through the Q1 launch details",
                emotionalTag: .focus,
                priority: .high,
                estimatedDuration: 60
            ),
            Task(
                title: "Call mom",
                notes: "Weekly check-in call",
                emotionalTag: .social,
                priority: .medium,
                estimatedDuration: 30
            ),
            Task(
                title: "Grocery shopping",
                notes: "Weekly grocery run",
                emotionalTag: .routine,
                priority: .low,
                estimatedDuration: 45
            )
        ]
        
        if TaskServiceConfig.debugLogging {
            print("📱 Using mock data (backend disabled or unavailable)")
        }
    }
}

// MARK: - Backend Models

struct BackendTask: Codable {
    let title: String
    let notes: String
    let is_completed: Bool
    let emotional_tag: String?
    let scheduled_date: String
    let priority: String
    let estimated_duration: Int
    let project_id: String?
}

struct BackendTaskResponse: Codable {
    let id: String
    let title: String
    let notes: String
    let is_completed: Bool
    let emotional_tag: String?
    let scheduled_date: String
    let priority: String
    let estimated_duration: Int
    let project_id: String?
    let user_id: String
    let created_at: String
    let updated_at: String
}

struct TasksResponse: Codable {
    let tasks: [BackendTaskResponse]
    let total: Int
}

// MARK: - Error Types

enum TaskServiceError: LocalizedError {
    case networkError(String)
    case invalidResponse
    case invalidData
    case httpError(Int)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}

// MARK: - Shared Instance

extension TaskService {
    static let shared = TaskService()
} 
