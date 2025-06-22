import SwiftUI
import Combine

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}

class OnboardingViewModel: ObservableObject {
    @Published var selectedOption: Int?
    @Published var currentQuestionIndex = 0
    @Published var showingResult = false
    @Published var personalityType = ""
    @Published var personalityDescription = ""
    @Published var answers: [AssessmentAnswer] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let mbtiService = MBTIService()
    
    var questions: [MBTIQuestion] {
        mbtiService.questions
    }
    
    var currentQuestion: MBTIQuestion? {
        guard !questions.isEmpty && currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    var canGoBack: Bool {
        currentQuestionIndex > 0
    }
    
    init() {
        loadQuestions()
    }
    
    func loadQuestions() {
        isLoading = true
        mbtiService.loadQuestions()
        
        // Observe changes from MBTI service
        mbtiService.$questions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] questions in
                self?.isLoading = false
                if !questions.isEmpty {
                    print("✅ Loaded \(questions.count) questions for onboarding")
                }
            }
            .store(in: &cancellables)
            
        mbtiService.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.error = error
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func selectOption(_ index: Int) {
        selectedOption = index
    }
    
    func nextQuestion() {
        guard let selected = selectedOption,
              let question = currentQuestion,
              selected < question.answers.count else { return }
        
        // Save the answer with proper IDs
        let answer = AssessmentAnswer(
            questionId: question.id,
            answerId: question.answers[selected].id
        )
        
        if answers.count > currentQuestionIndex {
            answers[currentQuestionIndex] = answer
        } else {
            answers.append(answer)
        }
        
        if isLastQuestion {
            // Submit assessment to backend
            submitAssessment()
        } else {
            // Move to next question
            currentQuestionIndex += 1
            selectedOption = nil
        }
    }
    
    func previousQuestion() {
        guard canGoBack else { return }
        currentQuestionIndex -= 1
        selectedOption = answers.count > currentQuestionIndex ? 
            findAnswerIndex(for: answers[currentQuestionIndex]) : nil
    }
    
    private func findAnswerIndex(for assessmentAnswer: AssessmentAnswer) -> Int? {
        guard let question = currentQuestion else { return nil }
        return question.answers.firstIndex { $0.id == assessmentAnswer.answerId }
    }
    
    private func submitAssessment() {
        isLoading = true
        
        // Create user data for new user creation
        let userData = UserCreationData(email: nil, name: nil) // Can be extended later
        
        mbtiService.submitAssessmentAndCreateUser(answers, userData: userData) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let assessmentResult):
                    self?.personalityType = assessmentResult.personalityType.personaId
                    self?.personalityDescription = assessmentResult.personalityType.description ?? ""
                    
                    print("✅ Assessment completed: \(assessmentResult.personalityType.personaId)")
                    print("Confidence: \(assessmentResult.confidenceScore)")
                    
                    // Store personality results for later use
                    UserDefaults.standard.set(assessmentResult.personalityType.personaId, forKey: "userPersonalityType")
                    UserDefaults.standard.set(assessmentResult.personalityType.name, forKey: "userPersonalityName")
                    UserDefaults.standard.set(assessmentResult.personalityType.description, forKey: "userPersonalityDescription")
                    
                    // Store user profile information if created
                    if let userProfile = assessmentResult.userProfile {
                        UserDefaults.standard.set(userProfile.id, forKey: "userId")
                        UserDefaults.standard.set(userProfile.personaId, forKey: "userPersonaId")
                        print("👤 User profile created: \(userProfile.id) with persona_id: \(userProfile.personaId ?? "nil")")
                    }
                    
                    // Store chat style preferences
                    UserDefaults.standard.set(assessmentResult.chatStyle.keywords, forKey: "userChatKeywords")
                    UserDefaults.standard.set(assessmentResult.chatStyle.temperature, forKey: "userChatTemperature")
                    
                    // Notify that onboarding is completed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
                    }
                    
                case .failure(let error):
                    self?.error = "Assessment failed: \(error.localizedDescription)"
                    print("❌ Assessment failed: \(error)")
                    
                    // Fallback to simple completion without user creation
                    self?.personalityType = "INTJ"
                    self?.personalityDescription = "The Architect - Strategic and imaginative, you prefer to work independently and think several steps ahead."
                    
                    // Store fallback values
                    UserDefaults.standard.set("INTJ", forKey: "userPersonalityType")
                    UserDefaults.standard.set("The Architect", forKey: "userPersonalityName")
                    UserDefaults.standard.set(self?.personalityDescription, forKey: "userPersonalityDescription")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
                    }
                }
            }
        }
    }
    
    func resetQuestionnaire() {
        currentQuestionIndex = 0
        selectedOption = nil
        answers = []
        personalityType = ""
        personalityDescription = ""
        error = nil
    }
    
    // MARK: - Personality Type Descriptions (Fallback)
    
    func getPersonalityDescription() -> String {
        if !personalityDescription.isEmpty {
            return personalityDescription
        }
        
        // Fallback descriptions
        switch personalityType {
        case "INTJ":
            return "The Architect - Strategic and imaginative, you prefer to work independently and think several steps ahead."
        case "INTP":
            return "The Thinker - Innovative and curious, you love exploring new ideas and understanding complex systems."
        case "ENTJ":
            return "The Commander - Natural leader who thrives on organizing and directing projects toward success."
        case "ENTP":
            return "The Debater - Quick-witted and creative, you excel at generating new possibilities and solutions."
        case "INFJ":
            return "The Advocate - Insightful and principled, you work best when your tasks align with your values."
        case "INFP":
            return "The Mediator - Creative and idealistic, you prefer flexible environments that honor your personal values."
        case "ENFJ":
            return "The Protagonist - Charismatic and inspiring, you excel at motivating others and building consensus."
        case "ENFP":
            return "The Campaigner - Enthusiastic and creative, you thrive in dynamic environments with lots of possibilities."
        case "ISTJ":
            return "The Logistician - Reliable and methodical, you prefer structured environments with clear expectations."
        case "ISFJ":
            return "The Protector - Caring and detail-oriented, you work best in supportive, harmonious environments."
        case "ESTJ":
            return "The Executive - Organized and decisive, you excel at managing projects and leading teams efficiently."
        case "ESFJ":
            return "The Consul - Warm and cooperative, you thrive in collaborative environments focused on helping others."
        case "ISTP":
            return "The Virtuoso - Practical and adaptable, you prefer hands-on work with immediate, tangible results."
        case "ISFP":
            return "The Adventurer - Gentle and flexible, you work best in environments that respect your personal space and values."
        case "ESTP":
            return "The Entrepreneur - Energetic and pragmatic, you excel in fast-paced, results-oriented environments."
        case "ESFP":
            return "The Entertainer - Spontaneous and enthusiastic, you thrive in people-focused, dynamic work situations."
        default:
            return "You have a balanced approach to challenges, adapting your strategy based on the situation."
        }
    }
    
    // MARK: - Task Recommendations
    
    func getTaskRecommendations() -> [String] {
        switch personalityType {
        case "INTJ", "INTP":
            return [
                "Long-term strategic planning projects",
                "Complex problem-solving tasks",
                "Independent research and analysis work"
            ]
        case "ENTJ", "ESTJ":
            return [
                "Leadership and project management roles",
                "Goal-setting and milestone tracking",
                "Team coordination and resource planning"
            ]
        case "INFJ", "INFP":
            return [
                "Creative projects aligned with personal values",
                "Meaningful work that helps others",
                "Flexible deadlines with autonomy"
            ]
        case "ENFJ", "ENFP":
            return [
                "Collaborative team projects",
                "Brainstorming and ideation sessions",
                "People-focused initiatives and communication"
            ]
        case "ISTJ", "ISFJ":
            return [
                "Structured tasks with clear guidelines",
                "Detail-oriented work with quality focus",
                "Consistent routines and organized workflows"
            ]
        case "ESFJ", "ESFP":
            return [
                "Social and team-oriented projects",
                "Tasks involving direct people interaction",
                "Varied work with immediate feedback"
            ]
        case "ISTP", "ISFP":
            return [
                "Hands-on, practical projects",
                "Flexible work with minimal supervision",
                "Tasks allowing for personal expression"
            ]
        case "ESTP":
            return [
                "Fast-paced, results-driven tasks",
                "Dynamic environments with variety",
                "Immediate problem-solving challenges"
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