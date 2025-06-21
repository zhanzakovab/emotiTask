import Foundation

// MARK: - Chat Service Configuration

class ChatServiceManager {
    static let shared = ChatServiceManager()
    
    private init() {}
    
    // Automatically switches between OpenAI and dummy service based on API key availability
    func createChatService() -> ChatServiceProtocol {
        // Check if OpenAI API key is available
        if let apiKey = getOpenAIAPIKey() {
            print("🤖 Using OpenAI ChatGPT service")
            return OpenAIService(apiKey: apiKey)
        } else {
            print("🎭 Using dummy chat service (no API key found)")
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
        
        return nil  // 👈 PUT YOUR API KEY HERE: return "your-api-key-here"

    }
    
    func setOpenAIAPIKey(_ apiKey: String) {
        // Store in UserDefaults for now (in production, use Keychain)
        UserDefaults.standard.set(apiKey, forKey: "openai_api_key")
    }
}

// Note: OpenAI models and errors are now in OpenAIService.swift 