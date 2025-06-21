import Foundation

// MARK: - Task Service Configuration

struct TaskServiceConfig {
    /// Backend API base URL
    /// Change this to your Python backend URL
    static let baseURL = "http://0.0.0.0:8000"
    
    /// Enable/disable backend integration
    /// Set to false to use local-only mode for development
    static let isBackendEnabled = true
    
    /// Request timeout in seconds
    static let requestTimeout: TimeInterval = 30.0
    
    /// Enable debug logging
    static let isDebugEnabled = true
} 