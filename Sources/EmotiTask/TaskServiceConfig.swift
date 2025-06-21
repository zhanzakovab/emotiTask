import Foundation

// MARK: - Task Service Configuration

struct TaskServiceConfig {
    // Backend Configuration
    static let backendEnabled = true
    static let backendURL = "http://localhost:8000"
    
    // API Endpoints
    static let baseURL = "\(backendURL)/api/v1"
    static let tasksEndpoint = "\(baseURL)/tasks"
    static let projectsEndpoint = "\(baseURL)/projects"
    static let goalsEndpoint = "\(baseURL)/goals"
    static let authEndpoint = "\(baseURL)/auth"
    static let chatEndpoint = "\(baseURL)/chat"
    
    // Request Configuration
    static let timeoutInterval: TimeInterval = 30.0
    static let retryAttempts = 3
    
    // Headers
    static func defaultHeaders(with token: String? = nil) -> [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    // Development settings
    static let debugLogging = true
    static let mockDataEnabled = !backendEnabled
} 