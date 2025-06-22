import Foundation

// MARK: - Chat Service Configuration

class ChatServiceManager {
    static let shared = ChatServiceManager()
    
    private init() {}
    
    // Automatically switches between Backend and dummy service based on user ID availability
    func createChatService() -> ChatServiceProtocol {
        // Check if we have a user ID from onboarding
        if let userId = UserDefaults.standard.string(forKey: "userId"), !userId.isEmpty {
            print("🤖 Using Backend Chat service for user: \(userId)")
            return BackendChatService(userId: userId)
        } else {
            print("🎭 Using dummy chat service (no user ID found)")
            return DummyChatService()
        }
    }
    
    // MARK: - API Key Management (for future use)
    
    private func getOpenAIAPIKey() -> String? {
        // Option 1: From environment variable
        if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return apiKey
        }
        
        // Option 2: From UserDefaults (not recommended for production)
        if let apiKey = UserDefaults.standard.string(forKey: "openai_api_key") {
            return apiKey
        }
        
        // Option 3: From Keychain (recommended for production)
        // return KeychainManager.getAPIKey(for: "openai")
        
        // Option 4: Hardcoded for development (not recommended for production)
        return "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"
    }
    
    func setOpenAIAPIKey(_ apiKey: String) {
        // Store in UserDefaults for now (in production, use Keychain)
        UserDefaults.standard.set(apiKey, forKey: "openai_api_key")
    }
}

// MARK: - Backend Chat Service

class BackendChatService: ChatServiceProtocol {
    private let userId: String
    private let session = URLSession.shared
    private let baseURL = TaskServiceConfig.baseURL
    
    init(userId: String) {
        self.userId = userId
    }
    
    private var chatEndpoint: String {
        "\(baseURL)/chat/send"
    }
    
    private var historyEndpoint: String {
        "\(baseURL)/chat/history/\(userId)"
    }
    
    func sendMessage(_ message: String) async throws -> String {
        guard let url = URL(string: chatEndpoint) else {
            throw ChatError.invalidURL
        }
        
        let requestBody = ChatRequest(userId: userId, message: message)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = TaskServiceConfig.timeoutInterval
        
        // Add headers
        for (key, value) in TaskServiceConfig.defaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Encode request body
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw ChatError.encodingError
        }
        
        // Make request
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ChatError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ChatError.serverError(httpResponse.statusCode)
            }
            
            // Decode response
            let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            return chatResponse.message
            
        } catch let error as ChatError {
            throw error
        } catch {
            throw ChatError.networkError(error.localizedDescription)
        }
    }
    
    func generateTaskSuggestions(for message: String, currentTasks: [TodoTask]) async throws -> [TodoSuggestion] {
        // For now, return empty array - this can be enhanced later
        return []
    }
    
    func loadChatHistory() async throws -> [BackendChatMessage] {
        guard let url = URL(string: historyEndpoint) else {
            throw ChatError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = TaskServiceConfig.timeoutInterval
        
        // Add headers
        for (key, value) in TaskServiceConfig.defaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ChatError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ChatError.serverError(httpResponse.statusCode)
            }
            
            // Decode response
            let historyResponse = try JSONDecoder().decode(ChatHistoryResponse.self, from: data)
            
            if historyResponse.exists, let chatData = historyResponse.chatData {
                return chatData.messages
            } else {
                return []
            }
            
        } catch let error as ChatError {
            throw error
        } catch {
            throw ChatError.networkError(error.localizedDescription)
        }
    }
}

// MARK: - Backend Chat Models

struct ChatRequest: Codable {
    let userId: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case message
    }
}

struct ChatResponse: Codable {
    let message: String
    let chatData: BackendChatData
    
    enum CodingKeys: String, CodingKey {
        case message
        case chatData = "chat_data"
    }
}

struct BackendChatData: Codable {
    let id: String
    let userId: String
    let messages: [BackendChatMessage]
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case messages
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct BackendChatMessage: Codable {
    let role: String
    let content: String
    let timestamp: String
}

struct ChatHistoryResponse: Codable {
    let chatData: BackendChatData?
    let exists: Bool
    
    enum CodingKeys: String, CodingKey {
        case chatData = "chat_data"
        case exists
    }
}

// MARK: - Chat Errors

enum ChatError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case invalidResponse
    case serverError(Int)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError:
            return "Failed to encode request"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// Note: OpenAI models and errors are now in OpenAIService.swift 
