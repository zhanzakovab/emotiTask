import Foundation
import SwiftUI

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
    let sessionId: String
    let createdAt: Date
    
    init() {
        self.sessionId = UUID().uuidString
        self.createdAt = Date()
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
        let session = ChatSessionData()
        
        // Add some sample conversation
        session.addAIMessage("Hello! I'm here to help you manage your tasks while taking care of your emotional well-being. How are you feeling today?")
        session.addUserMessage("I'm feeling a bit overwhelmed with work. I have so many tasks and don't know where to start.")
        session.addAIMessage("I understand that feeling of being overwhelmed. It's completely normal when facing a lot of tasks. Let's break this down together. What's the most pressing thing on your mind right now?")
        session.addUserMessage("I have a big presentation due tomorrow and I haven't even started preparing for it.")
        session.addAIMessage("That sounds stressful, but we can tackle this step by step. Since you're feeling overwhelmed, I'd suggest breaking the presentation prep into smaller, manageable chunks. Would you like me to help you create a task plan that considers your current emotional state?")
        
        return session
    }
    
    static var empty: ChatSessionData {
        return ChatSessionData()
    }
}

// MARK: - Date Extensions

extension Date {
    var chatTimeString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(self) {
            formatter.timeStyle = .short
            return formatter.string(from: self)
        } else if Calendar.current.isDateInYesterday(self) {
            formatter.timeStyle = .short
            return "Yesterday \(formatter.string(from: self))"
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: self)
        }
    }
} 