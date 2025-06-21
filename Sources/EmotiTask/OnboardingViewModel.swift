import SwiftUI

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}

struct QuestionData {
    let question: String
    let options: [String]
}

class OnboardingViewModel: ObservableObject {
    @Published var selectedOption: Int?
    @Published var currentQuestionIndex = 0
    @Published var showingResult = false
    @Published var personalityType = ""
    @Published var answers: [Int] = []
    
    let questions = [
        QuestionData(
            question: "When faced with a challenging task, I typically:",
            options: [
                "Dive in immediately and figure it out as I go",
                "Plan carefully and research before starting",
                "Ask for help and collaborate with others"
            ]
        ),
        QuestionData(
            question: "Which one of the following 4 scenarios best describes your working status?",
            options: [
                "I work best in structured environments with clear guidelines",
                "I thrive in dynamic, fast-paced work situations",
                "I prefer collaborative team-based projects",
                "I excel when working independently on creative tasks"
            ]
        ),
        QuestionData(
            question: "How do you handle stress in difficult situations?",
            options: [
                "I stay calm and think through solutions methodically",
                "I take action immediately to resolve the issue",
                "I seek support and advice from others",
                "I take breaks and return with fresh perspective"
            ]
        ),
        QuestionData(
            question: "What motivates you most in your daily activities?",
            options: [
                "Achieving personal goals and milestones",
                "Learning new skills and gaining knowledge",
                "Building relationships and helping others",
                "Creating something unique and meaningful"
            ]
        ),
        QuestionData(
            question: "How do you prefer to receive feedback?",
            options: [
                "Direct and specific with actionable steps",
                "Constructive with examples and alternatives",
                "Encouraging with focus on strengths",
                "Honest and detailed for improvement"
            ]
        ),
        QuestionData(
            question: "What's your ideal work environment?",
            options: [
                "Quiet space with minimal distractions",
                "Bustling environment with lots of energy",
                "Collaborative space with team interaction",
                "Flexible space that changes based on tasks"
            ]
        ),
        QuestionData(
            question: "How do you approach decision making?",
            options: [
                "Analyze all options carefully before deciding",
                "Trust my instincts and decide quickly",
                "Discuss with others to get different perspectives",
                "Consider long-term impact and consequences"
            ]
        ),
        QuestionData(
            question: "What energizes you most during work?",
            options: [
                "Completing tasks efficiently and on time",
                "Tackling new challenges and problems",
                "Collaborating and brainstorming with others",
                "Having creative freedom and flexibility"
            ]
        ),
        QuestionData(
            question: "How do you handle multiple priorities?",
            options: [
                "Create detailed schedules and stick to them",
                "Focus on the most urgent tasks first",
                "Delegate and work with team members",
                "Find creative ways to combine similar tasks"
            ]
        ),
        QuestionData(
            question: "What describes your communication style?",
            options: [
                "Clear, concise, and to the point",
                "Enthusiastic and expressive",
                "Warm, supportive, and encouraging",
                "Thoughtful and detailed"
            ]
        )
    ]
    
    var currentQuestion: QuestionData {
        questions[currentQuestionIndex]
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    var canGoBack: Bool {
        currentQuestionIndex > 0
    }
    
    func selectOption(_ index: Int) {
        selectedOption = index
    }
    
    func nextQuestion() {
        guard let selected = selectedOption else { return }
        
        // Save the answer
        if answers.count > currentQuestionIndex {
            answers[currentQuestionIndex] = selected
        } else {
            answers.append(selected)
        }
        
        if isLastQuestion {
            // Calculate final personality type
            personalityType = calculatePersonalityType()
            print("User's personality type: \(personalityType)")
            print("All answers: \(answers)")
            
            // Notify that onboarding is completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
            }
        } else {
            // Move to next question
            currentQuestionIndex += 1
            selectedOption = nil
        }
    }
    
    func previousQuestion() {
        guard canGoBack else { return }
        currentQuestionIndex -= 1
        selectedOption = answers.count > currentQuestionIndex ? answers[currentQuestionIndex] : nil
    }
    
    func resetQuestionnaire() {
        currentQuestionIndex = 0
        selectedOption = nil
        answers = []
    }
    
    private func calculatePersonalityType() -> String {
        // Simple scoring system based on answer patterns
        var scores = [String: Int]()
        scores["Analyst"] = 0
        scores["Explorer"] = 0
        scores["Collaborator"] = 0
        scores["Creator"] = 0
        
        for (questionIndex, answerIndex) in answers.enumerated() {
            switch questionIndex {
            case 0: // First question
                switch answerIndex {
                case 0: scores["Explorer"]! += 1
                case 1: scores["Analyst"]! += 1
                case 2: scores["Collaborator"]! += 1
                default: break
                }
            case 1: // Working status
                switch answerIndex {
                case 0: scores["Analyst"]! += 1
                case 1: scores["Explorer"]! += 1
                case 2: scores["Collaborator"]! += 1
                case 3: scores["Creator"]! += 1
                default: break
                }
            default:
                // For other questions, distribute points based on answer index
                let types = ["Analyst", "Explorer", "Collaborator", "Creator"]
                if answerIndex < types.count {
                    scores[types[answerIndex]]! += 1
                }
            }
        }
        
        // Return the personality type with highest score
        return scores.max(by: { $0.value < $1.value })?.key ?? "Balanced"
    }
    
    private func determinePersonalityType(from selection: Int) -> String {
        switch selection {
        case 0:
            return "Explorer"
        case 1:
            return "Analyst"
        case 2:
            return "Collaborator"
        default:
            return "Balanced"
        }
    }
    
    // MARK: - Personality Type Descriptions
    
    func getPersonalityDescription() -> String {
        switch personalityType {
        case "Explorer":
            return "You're adventurous and prefer to learn through experience. You thrive on spontaneity and enjoy discovering solutions through trial and error."
        case "Analyst":
            return "You're methodical and detail-oriented. You prefer to understand the full scope before taking action and value thorough preparation."
        case "Collaborator":
            return "You're social and team-oriented. You believe in the power of collective intelligence and enjoy working with others to solve problems."
        default:
            return "You have a balanced approach to challenges, adapting your strategy based on the situation."
        }
    }
    
    // MARK: - Task Recommendations
    
    func getTaskRecommendations() -> [String] {
        switch personalityType {
        case "Explorer":
            return [
                "Creative projects with flexible deadlines",
                "Problem-solving tasks that require innovation",
                "Dynamic environments with changing requirements"
            ]
        case "Analyst":
            return [
                "Data analysis and research projects",
                "Tasks requiring attention to detail",
                "Long-term planning and strategy work"
            ]
        case "Collaborator":
            return [
                "Team-based projects and group activities",
                "Client-facing roles and communication tasks",
                "Mentoring and knowledge-sharing opportunities"
            ]
        default:
            return [
                "Versatile tasks that can adapt to different approaches",
                "Projects with multiple phases requiring different skills",
                "Roles that balance individual and collaborative work"
            ]
        }
    }
} 