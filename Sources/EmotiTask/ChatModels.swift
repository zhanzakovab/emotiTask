import Foundation
import SwiftUI

// MARK: - Chat Service Protocol (API-Ready)

protocol ChatServiceProtocol {
    func sendMessage(_ message: String) async throws -> String
    func generateTaskSuggestions(for message: String, currentTasks: [EmotiTask.Task]) async throws -> [TodoSuggestion]
}

// MARK: - Dummy Chat Service (for now)
class DummyChatService: ChatServiceProtocol {
    func sendMessage(_ message: String) async throws -> String {
        // Simulate network delay
        try await _Concurrency.Task.sleep(nanoseconds: 1_500_000_000)
        
        let responses = [
            "I understand how you're feeling. Let's work through this together.",
            "That sounds like a great opportunity to grow. How can I help you tackle it?",
            "Your emotions are valid. Would you like to break this down into smaller steps?",
            "I can sense the energy in your message! What would you like to accomplish today?",
            "Thank you for sharing that with me. What's the most important thing on your mind right now?",
            "It sounds like you're processing a lot. Would creating a task list help organize your thoughts?"
        ]
        return responses.randomElement() ?? "I'm here to help you navigate through this."
    }
    
    func generateTaskSuggestions(for message: String, currentTasks: [EmotiTask.Task]) async throws -> [TodoSuggestion] {
        // Simulate network delay
        try await _Concurrency.Task.sleep(nanoseconds: 1_000_000_000)
        
        let lowercaseMessage = message.lowercased()
        var suggestions: [TodoSuggestion] = []
        
        // Analyze emotional context and suggest todo changes
        if lowercaseMessage.contains("overwhelmed") || lowercaseMessage.contains("stressed") {
            suggestions.append(TodoSuggestion(
                message: "I notice you're feeling overwhelmed. Would you like me to reschedule some lower-priority tasks to tomorrow?",
                actionType: .rescheduleTask(to: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()),
                taskId: currentTasks.first { $0.priority == .low }?.id
            ))
            
            suggestions.append(TodoSuggestion(
                message: "How about adding a 10-minute breathing break to your schedule?",
                actionType: .addSelfCare,
                taskId: nil
            ))
        }
        
        if lowercaseMessage.contains("tired") || lowercaseMessage.contains("exhausted") {
            suggestions.append(TodoSuggestion(
                message: "You sound tired. Want me to prioritize your energy-friendly tasks for now?",
                actionType: .prioritizeTask,
                taskId: currentTasks.first { $0.emotionalTag == .lowEnergy }?.id
            ))
        }
        
        if lowercaseMessage.contains("presentation") || lowercaseMessage.contains("deadline") {
            suggestions.append(TodoSuggestion(
                message: "I can help you focus on your presentation. Should I move other tasks to give you more time?",
                actionType: .prioritizeTask,
                taskId: currentTasks.first { $0.emotionalTag == .focus }?.id
            ))
        }
        
        return suggestions
    }
}

// Note: OpenAI service is now in dedicated OpenAIService.swift file

// MARK: - Todo Suggestion for Chat Integration
struct TodoSuggestion: Identifiable {
    let id = UUID()
    let message: String
    let actionType: SuggestionActionType
    let taskId: UUID?
    
    enum SuggestionActionType {
        case rescheduleTask(to: Date)
        case addBreak
        case prioritizeTask
        case addSelfCare
        case swapTasks
    }
}

// MARK: - Onboarding Models

struct OnboardingQuestion: Identifiable {
    let id = UUID()
    let questionText: String
    let options: [String]
}

class OnboardingData: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: [String] = []
    let questions: [OnboardingQuestion]
    
    init(questions: [OnboardingQuestion]) {
        self.questions = questions
        self.selectedAnswers = Array(repeating: "", count: questions.count)
    }
    
    var totalQuestions: Int {
        return questions.count
    }
    
    var currentQuestion: OnboardingQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var isLastQuestion: Bool {
        return currentQuestionIndex >= questions.count - 1
    }
    
    var canGoNext: Bool {
        return !selectedAnswers[currentQuestionIndex].isEmpty
    }
    
    var canGoPrevious: Bool {
        return currentQuestionIndex > 0
    }
    
    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(totalQuestions)
    }
    
    func selectAnswer(_ answer: String) {
        selectedAnswers[currentQuestionIndex] = answer
    }
    
    func goToNext() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
    
    func goToPrevious() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    func reset() {
        currentQuestionIndex = 0
        selectedAnswers = Array(repeating: "", count: questions.count)
    }
}

// MARK: - Chat Models

enum MessageSender {
    case user
    case ai
    
    var displayName: String {
        switch self {
        case .user: return "You"
        case .ai: return "EmotiTask"
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let sender: MessageSender
    let timestamp: Date
    
    init(text: String, sender: MessageSender, timestamp: Date = Date()) {
        self.text = text
        self.sender = sender
        self.timestamp = timestamp
    }
}

class ChatSessionData: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let sessionId: String
    let createdAt: Date
    let chatService: ChatServiceProtocol
    
    init(chatService: ChatServiceProtocol = DummyChatService()) {
        self.sessionId = UUID().uuidString
        self.createdAt = Date()
        self.chatService = chatService
    }
    
    func addMessage(_ message: ChatMessage) {
        messages.append(message)
    }
    
    func addUserMessage(_ text: String) {
        let message = ChatMessage(text: text, sender: .user)
        addMessage(message)
    }
    
    func addAIMessage(_ text: String) {
        let message = ChatMessage(text: text, sender: .ai)
        addMessage(message)
    }
    
    @MainActor
    func sendMessage(_ text: String) async {
        // Add user message immediately
        addUserMessage(text)
        
        // Clear any previous errors
        errorMessage = nil
        
        // Start typing indicator
        isTyping = true
        isLoading = true
        
        do {
            // Get AI response
            let response = try await chatService.sendMessage(text)
            
            // Stop typing and add AI response
            isTyping = false
            isLoading = false
            addAIMessage(response)
            
        } catch {
            // Handle error
            isTyping = false
            isLoading = false
            errorMessage = "Sorry, I'm having trouble responding right now. Please try again."
            addAIMessage("I apologize, but I'm experiencing some technical difficulties. Please try again in a moment.")
        }
    }
    
    @MainActor
    func generateSuggestions(for message: String, currentTasks: [EmotiTask.Task]) async -> [TodoSuggestion] {
        do {
            return try await chatService.generateTaskSuggestions(for: message, currentTasks: currentTasks)
        } catch {
            print("Error generating suggestions: \(error)")
            return []
        }
    }
    
    func simulateTyping() {
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isTyping = false
        }
    }
    
    var lastMessage: ChatMessage? {
        return messages.last
    }
    
    var messageCount: Int {
        return messages.count
    }
}

// MARK: - Extensions

extension Date {
    var chatTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

// MARK: - Dummy Data

extension OnboardingData {
    static var dummy: OnboardingData {
        let questions = [
            OnboardingQuestion(
                questionText: "How are you feeling about your productivity lately?",
                options: ["Very productive", "Somewhat productive", "Struggling with productivity", "Not productive at all"]
            ),
            OnboardingQuestion(
                questionText: "What time of day do you feel most energetic?",
                options: ["Early morning", "Mid-morning", "Afternoon", "Evening", "Night"]
            ),
            OnboardingQuestion(
                questionText: "How do you prefer to manage stress?",
                options: ["Take breaks", "Exercise", "Talk to someone", "Listen to music", "Meditation"]
            ),
            OnboardingQuestion(
                questionText: "What motivates you most to complete tasks?",
                options: ["Achieving goals", "Helping others", "Personal growth", "Recognition", "Financial rewards"]
            ),
            OnboardingQuestion(
                questionText: "How do you handle overwhelming workloads?",
                options: ["Break tasks into smaller pieces", "Prioritize urgent items", "Ask for help", "Take a step back", "Work through it"]
            ),
            OnboardingQuestion(
                questionText: "What's your biggest challenge with task management?",
                options: ["Procrastination", "Too many tasks", "Lack of focus", "Poor time estimation", "Getting started"]
            ),
            OnboardingQuestion(
                questionText: "How important is work-life balance to you?",
                options: ["Extremely important", "Very important", "Somewhat important", "Not very important"]
            ),
            OnboardingQuestion(
                questionText: "What helps you stay focused during work?",
                options: ["Quiet environment", "Music", "Short breaks", "Clear deadlines", "Rewards"]
            ),
            OnboardingQuestion(
                questionText: "How do you prefer to receive feedback on your progress?",
                options: ["Daily check-ins", "Weekly summaries", "Milestone celebrations", "Gentle reminders", "Achievement badges"]
            ),
            OnboardingQuestion(
                questionText: "What would make you feel most supported in reaching your goals?",
                options: ["Personalized suggestions", "Emotional check-ins", "Flexible scheduling", "Progress tracking", "Community support"]
            )
        ]
        
        return OnboardingData(questions: questions)
    }
    
    static var shortDummy: OnboardingData {
        let questions = [
            OnboardingQuestion(
                questionText: "How are you feeling right now?",
                options: ["Great", "Good", "Okay", "Not great", "Struggling"]
            ),
            OnboardingQuestion(
                questionText: "What's your main goal today?",
                options: ["Be productive", "Relax and recharge", "Connect with others", "Learn something new"]
            ),
            OnboardingQuestion(
                questionText: "How can EmotiTask best support you?",
                options: ["Smart task suggestions", "Emotional check-ins", "Flexible scheduling", "Progress celebrations"]
            )
        ]
        
        return OnboardingData(questions: questions)
    }
}

extension ChatSessionData {
    static var dummy: ChatSessionData {
        // Return a clean session - welcome messages will be added in ChatView.onAppear
        return ChatSessionData(chatService: ChatServiceManager.shared.createChatService())
    }
} 