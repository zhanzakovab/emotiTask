import Foundation

// MARK: - OpenAI Service

class OpenAIService: ChatServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    // MARK: - AI Personality Configuration
    
    private var systemPrompt: String {
        return """
        You are EmotiTask, a warm and emotionally intelligent AI assistant that helps users manage their tasks while caring for their emotional well-being. 

        Your personality:
        - Warm, empathetic, and genuinely caring
        - Supportive but not overly cheerful
        - Practical and helpful with task management
        - Use gentle encouragement and validation
        - Keep responses concise (1-3 sentences max)
        - Use emojis sparingly and naturally
        
        Your role:
        - Help users organize and prioritize tasks
        - Provide emotional support during stressful times
        - Suggest breaks and self-care when needed
        - Celebrate small wins and progress
        - Never be judgmental about productivity struggles
        
        Respond naturally as if you're a caring friend who happens to be great at organization.
        """
    }
    
    // MARK: - Model Configuration
    
    private var modelSettings: OpenAIModelSettings {
        return OpenAIModelSettings(
            model: "gpt-3.5-turbo",
            maxTokens: 150,
            temperature: 0.7
        )
    }
    
    // MARK: - Initialization
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Chat Service Protocol
    
    func sendMessage(_ message: String) async throws -> String {
        // Check if this is a welcome message request
        let isWelcomeMessage = message.contains("This is the very first time the user is opening EmotiTask")
        
        let systemMessage = isWelcomeMessage ? welcomeSystemPrompt : systemPrompt
        
        let request = OpenAIRequest(
            model: modelSettings.model,
            messages: [
                OpenAIMessage(role: "system", content: systemMessage),
                OpenAIMessage(role: "user", content: message)
            ],
            maxTokens: modelSettings.maxTokens,
            temperature: modelSettings.temperature
        )
        
        return try await makeOpenAIRequest(request)
    }
    
    // MARK: - Welcome Message System Prompt
    
    private var welcomeSystemPrompt: String {
        return """
        You are EmotiTask, a warm and emotionally intelligent AI assistant. This is your first interaction with a new user.
        
        Create a natural, welcoming introduction that:
        - Sounds genuinely friendly and approachable
        - Briefly introduces what you do (help with tasks and emotional well-being)
        - Shows interest in how they're feeling or what they need
        - Feels conversational, not scripted
        - Is concise (2-3 sentences maximum)
        - Uses the current time context naturally if relevant
        
        Be warm but not overly enthusiastic. Think of greeting a friend you want to help.
        """
    }
    
    func generateTaskSuggestions(for message: String, currentTasks: [EmotiTask.Task]) async throws -> [TodoSuggestion] {
        // For now, keep task suggestions simple and use dummy service
        // This prevents over-complicating the AI responses
        let dummyService = DummyChatService()
        return try await dummyService.generateTaskSuggestions(for: message, currentTasks: currentTasks)
        
        // TODO: Future enhancement - AI-powered task suggestions
        // Could analyze user's emotional state and current tasks to provide intelligent suggestions
    }
    
    // MARK: - Private Methods
    
    private func makeOpenAIRequest(_ request: OpenAIRequest) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OpenAIError.apiError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
        
        guard let firstChoice = openAIResponse.choices.first else {
            throw OpenAIError.noResponse
        }
        
        return firstChoice.message.content
    }
}

// MARK: - OpenAI Configuration Models

struct OpenAIModelSettings {
    let model: String
    let maxTokens: Int
    let temperature: Double
}

// MARK: - OpenAI Request/Response Models

struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int?
    let temperature: Double?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage?
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - OpenAI Errors

enum OpenAIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noResponse
    case apiError(Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from OpenAI"
        case .noResponse:
            return "No response from OpenAI"
        case .apiError(let code):
            return "OpenAI API error: \(code)"
        case .decodingError:
            return "Failed to decode OpenAI response"
        }
    }
}

// MARK: - Future Enhancement Ideas

/*
 PERSONALITY UPDATES:
 - Modify the `systemPrompt` property to change AI personality
 - Adjust `modelSettings` for different response styles
 - Add personality presets (professional, casual, motivational, etc.)
 
 FUNCTION ENHANCEMENTS:
 - AI-powered task suggestions based on emotional state
 - Smart scheduling recommendations
 - Personalized productivity tips
 - Emotional check-ins and mood tracking
 - Integration with calendar and reminders
 
 ADVANCED FEATURES:
 - Function calling for task management actions
 - Memory of user preferences and patterns
 - Context-aware responses based on time of day
 - Integration with external productivity tools
 */ 