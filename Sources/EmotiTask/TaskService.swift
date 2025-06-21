import Foundation

// MARK: - Task API Service

class TaskService: ObservableObject {
    private let baseURL = TaskServiceConfig.baseURL
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TaskServiceConfig.requestTimeout
        config.timeoutIntervalForResource = TaskServiceConfig.requestTimeout
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - API Models
    
    struct CreateTaskRequest: Codable {
        let title: String
        let notes: String?
        let scheduledDate: String // ISO 8601 format
        let priority: String
        let emotionalTag: String?
        let estimatedDuration: Int
        let projectId: String?
        let isCompleted: Bool
        
        init(from task: Task) {
            self.title = task.title
            self.notes = task.notes.isEmpty ? nil : task.notes
            self.scheduledDate = ISO8601DateFormatter().string(from: task.scheduledDate)
            self.priority = task.priority.rawValue
            self.emotionalTag = task.emotionalTag?.rawValue
            self.estimatedDuration = task.estimatedDuration
            self.projectId = task.projectId?.uuidString
            self.isCompleted = task.isCompleted
        }
    }
    
    struct TaskResponse: Codable {
        let id: String
        let title: String
        let notes: String?
        let scheduledDate: String
        let priority: String
        let emotionalTag: String?
        let estimatedDuration: Int
        let projectId: String?
        let isCompleted: Bool
        let createdAt: String
        let updatedAt: String
        
        func toTask() -> Task? {
            let dateFormatter = ISO8601DateFormatter()
            let scheduledDate = dateFormatter.date(from: self.scheduledDate) ?? Date()
            
            let priority = TaskPriority(rawValue: self.priority) ?? .medium
            let emotionalTag = self.emotionalTag.flatMap { EmotionalTag(rawValue: $0) }
            let projectId = self.projectId.flatMap { UUID(uuidString: $0) }
            
            var task = Task(
                title: title,
                isCompleted: isCompleted,
                emotionalTag: emotionalTag,
                scheduledDate: scheduledDate,
                notes: notes ?? "",
                priority: priority,
                estimatedDuration: estimatedDuration,
                projectId: projectId
            )
            
            // Manually set the ID to match backend
            // Note: This requires modifying Task struct to allow ID setting
            return task
        }
    }
    
    struct APIError: Codable {
        let detail: String
    }
    
    // MARK: - API Methods
    
    /// Create a new task on the backend
    func createTask(_ task: Task) async throws -> Task {
        let url = URL(string: "\(baseURL)/tasks")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let createRequest = CreateTaskRequest(from: task)
        let jsonData = try JSONEncoder().encode(createRequest)
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TaskServiceError.invalidResponse
            }
            
            if httpResponse.statusCode == 201 {
                // Success - parse the created task
                let taskResponse = try JSONDecoder().decode(TaskResponse.self, from: data)
                guard let createdTask = taskResponse.toTask() else {
                    throw TaskServiceError.invalidData
                }
                return createdTask
            } else {
                // Error response
                if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw TaskServiceError.apiError(apiError.detail)
                } else {
                    throw TaskServiceError.httpError(httpResponse.statusCode)
                }
            }
        } catch {
            if error is TaskServiceError {
                throw error
            } else {
                throw TaskServiceError.networkError(error.localizedDescription)
            }
        }
    }
    
    /// Get all tasks from the backend
    func getTasks() async throws -> [Task] {
        let url = URL(string: "\(baseURL)/tasks")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TaskServiceError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let taskResponses = try JSONDecoder().decode([TaskResponse].self, from: data)
                return taskResponses.compactMap { $0.toTask() }
            } else {
                throw TaskServiceError.httpError(httpResponse.statusCode)
            }
        } catch {
            if error is TaskServiceError {
                throw error
            } else {
                throw TaskServiceError.networkError(error.localizedDescription)
            }
        }
    }
    
    /// Update task completion status
    func updateTaskCompletion(taskId: UUID, isCompleted: Bool) async throws {
        let url = URL(string: "\(baseURL)/tasks/\(taskId.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updateData = ["isCompleted": isCompleted]
        let jsonData = try JSONSerialization.data(withJSONObject: updateData)
        request.httpBody = jsonData
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TaskServiceError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            throw TaskServiceError.httpError(httpResponse.statusCode)
        }
    }
    
    /// Delete a task
    func deleteTask(taskId: UUID) async throws {
        let url = URL(string: "\(baseURL)/tasks/\(taskId.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TaskServiceError.invalidResponse
        }
        
        if httpResponse.statusCode != 204 && httpResponse.statusCode != 200 {
            throw TaskServiceError.httpError(httpResponse.statusCode)
        }
    }
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
