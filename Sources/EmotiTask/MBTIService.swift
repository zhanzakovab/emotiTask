import Foundation

// MARK: - MBTI Models

struct MBTIQuestion: Codable, Identifiable {
    let id: Int
    let question: String
    let createdAt: String
    let updatedAt: String
    var answers: [MBTIAnswer] = []
    
    enum CodingKeys: String, CodingKey {
        case id, question, answers
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct MBTIAnswer: Codable, Identifiable {
    let id: Int
    let questionId: Int
    let answer: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, answer
        case questionId = "question_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct MBTIPersonalityType: Codable, Identifiable {
    let id: Int
    let personaId: String
    let name: String
    let description: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case personaId = "persona_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct MBTIChatStyle: Codable, Identifiable {
    let id: Int
    let personalityTypeId: Int
    let keywords: String?
    let temperature: Double
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, keywords, temperature
        case personalityTypeId = "personality_type_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct QuestionsResponse: Codable {
    let questions: [MBTIQuestion]
    let total: Int
}

struct PersonalityTypesResponse: Codable {
    let personalityTypes: [MBTIPersonalityType]
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case total
        case personalityTypes = "personality_types"
    }
}

struct AssessmentAnswer: Codable {
    let questionId: Int
    let answerId: Int
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case answerId = "answer_id"
    }
}

// MARK: - User Creation Models

struct UserCreationData: Codable {
    let email: String?
    let name: String?
    
    init(email: String? = nil, name: String? = nil) {
        self.email = email
        self.name = name
    }
}

struct UserProfile: Codable, Identifiable {
    let id: String
    let personaId: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case personaId = "persona_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct AssessmentSubmissionWithUser: Codable {
    let answers: [AssessmentAnswer]
    let userData: UserCreationData?
    let userId: String?
    
    enum CodingKeys: String, CodingKey {
        case answers
        case userData = "user_data"
        case userId = "user_id"
    }
}

struct AssessmentResult: Codable {
    let personalityType: MBTIPersonalityType
    let chatStyle: MBTIChatStyle
    let confidenceScore: Double
    let userProfile: UserProfile?
    
    enum CodingKeys: String, CodingKey {
        case confidenceScore = "confidence_score"
        case personalityType = "personality_type"
        case chatStyle = "chat_style"
        case userProfile = "user_profile"
    }
}

// MARK: - MBTI API Service

class MBTIService: ObservableObject {
    @Published var questions: [MBTIQuestion] = []
    @Published var personalityTypes: [MBTIPersonalityType] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let session = URLSession.shared
    private let baseURL = TaskServiceConfig.baseURL
    
    // MARK: - API Endpoints
    
    private var questionsEndpoint: String {
        "\(baseURL)/mbti/questions"
    }
    
    private var personalityTypesEndpoint: String {
        "\(baseURL)/mbti/personality-types"
    }
    
    private var assessmentEndpoint: String {
        "\(baseURL)/mbti/assess"
    }
    
    private var assessAndCreateUserEndpoint: String {
        "\(baseURL)/mbti/assess-and-create-user"
    }
    
    // MARK: - Public Methods
    
    func loadQuestions() {
        isLoading = true
        error = nil
        
        guard let url = URL(string: questionsEndpoint) else {
            error = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = TaskServiceConfig.timeoutInterval
        
        // Add headers
        for (key, value) in TaskServiceConfig.defaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = "Network error: \(error.localizedDescription)"
                    print("❌ Failed to load MBTI questions: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.error = "Invalid response"
                    print("❌ Invalid response from MBTI API")
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    self?.error = "Server error: \(httpResponse.statusCode)"
                    print("❌ Server error: \(httpResponse.statusCode)")
                    return
                }
                
                guard let data = data else {
                    self?.error = "No data received"
                    print("❌ No data received from MBTI API")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(QuestionsResponse.self, from: data)
                    self?.questions = response.questions
                    print("✅ Loaded \(response.questions.count) MBTI questions from backend")
                    
                    // Debug: Print first question with answers
                    if let firstQuestion = response.questions.first {
                        print("📝 First question: \(firstQuestion.question)")
                        print("💬 Answers count: \(firstQuestion.answers.count)")
                        for (index, answer) in firstQuestion.answers.enumerated() {
                            print("   \(index + 1). \(answer.answer)")
                        }
                    }
                } catch {
                    self?.error = "Failed to decode questions: \(error.localizedDescription)"
                    print("❌ Failed to decode MBTI questions: \(error)")
                }
            }
        }.resume()
    }
    
    func submitAssessment(_ answers: [AssessmentAnswer], completion: @escaping (Result<AssessmentResult, Error>) -> Void) {
        guard let url = URL(string: assessmentEndpoint) else {
            completion(.failure(NSError(domain: "MBTIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = TaskServiceConfig.timeoutInterval
        
        // Add headers
        for (key, value) in TaskServiceConfig.defaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let submission = AssessmentSubmissionWithUser(answers: answers, userData: nil, userId: nil)
        
        do {
            request.httpBody = try JSONEncoder().encode(submission)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "MBTIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "MBTIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "MBTIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(AssessmentResult.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func submitAssessmentAndCreateUser(_ answers: [AssessmentAnswer], userData: UserCreationData? = nil, userId: String? = nil, completion: @escaping (Result<AssessmentResult, Error>) -> Void) {
        guard let url = URL(string: assessAndCreateUserEndpoint) else {
            completion(.failure(NSError(domain: "MBTIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = TaskServiceConfig.timeoutInterval
        
        // Add headers
        for (key, value) in TaskServiceConfig.defaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let submission = AssessmentSubmissionWithUser(answers: answers, userData: userData, userId: userId)
        
        do {
            request.httpBody = try JSONEncoder().encode(submission)
            print("🚀 Submitting assessment with \(answers.count) answers for user creation")
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Assessment submission failed: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "MBTIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    print("❌ Server error: \(httpResponse.statusCode)")
                    completion(.failure(NSError(domain: "MBTIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "MBTIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(AssessmentResult.self, from: data)
                    print("✅ Assessment completed! Personality: \(result.personalityType.personaId)")
                    if let userProfile = result.userProfile {
                        print("👤 User profile created: \(userProfile.id)")
                    }
                    completion(.success(result))
                } catch {
                    print("❌ Failed to decode assessment result: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
} 