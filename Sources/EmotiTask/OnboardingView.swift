import SwiftUI

extension Color {
    static let coral = Color(red: 1.0, green: 0.5, blue: 0.31)
}

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToMainApp = false
    
    var body: some View {
        ZStack {
            // Full screen background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.3),
                    Color.pink.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            if viewModel.isLoading && viewModel.questions.isEmpty {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .coral))
                    
                    Text("Loading personality assessment...")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.black.opacity(0.7))
                }
            } else if let error = viewModel.error, viewModel.questions.isEmpty {
                // Error state
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Unable to load questions")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text(error)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Try Again") {
                        viewModel.loadQuestions()
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.coral)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .cornerRadius(25)
                }
            } else if !viewModel.questions.isEmpty {
                // Main content
                VStack(spacing: 0) {
                    // Header with back button
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Invisible spacer to center the question indicator
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .opacity(0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Main content area
                    VStack(spacing: 30) {
                        Spacer()
                        
                        // Character with thinking expression
                        ZStack {
                            // Main character circle
                            Circle()
                                .fill(Color.yellow.opacity(0.3))
                                .frame(width: 120, height: 120)
                            
                            // Face with thinking expression
                            VStack(spacing: 8) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 8, height: 8)
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 8, height: 8)
                                }
                                
                                // Thinking mouth
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 4, height: 4)
                            }
                            
                            // Thinking bubble
                            VStack {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 32, height: 32)
                                            .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 1)
                                        
                                        Text("?")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.gray)
                                    }
                                    .offset(x: -8, y: -8)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        .frame(width: 120, height: 120)
                        
                        // Question
                        VStack(spacing: 16) {
                            if viewModel.currentQuestionIndex == 0 {
                                Text("Let me understand your personality...")
                                    .font(.system(size: 26, weight: .medium, design: .rounded))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 20)
                            }
                            
                            if let currentQuestion = viewModel.currentQuestion {
                                Text(currentQuestion.question)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        // Options
                        if let currentQuestion = viewModel.currentQuestion {
                            VStack(spacing: 16) {
                                ForEach(0..<currentQuestion.answers.count, id: \.self) { index in
                                    ModernOptionButton(
                                        title: currentQuestion.answers[index].answer,
                                        isSelected: viewModel.selectedOption == index,
                                        action: {
                                            viewModel.selectOption(index)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                        
                        // Navigation Button
                        HStack {
                            // Back button
                            Button(action: {
                                viewModel.previousQuestion()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(viewModel.canGoBack ? .coral : .gray.opacity(0.5))
                            }
                            .disabled(!viewModel.canGoBack)
                            
                            Spacer()
                            
                            // Question counter or Complete button
                            if viewModel.isLastQuestion {
                                if viewModel.isLoading {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .coral))
                                        Text("Processing...")
                                            .font(.title3)
                                            .fontWeight(.medium)
                                            .foregroundColor(.coral)
                                    }
                                } else {
                                    Text("Complete Assessment")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(viewModel.selectedOption != nil ? .coral : .gray.opacity(0.5))
                                }
                            } else {
                                Text("\(viewModel.currentQuestionIndex + 1)/\(viewModel.questions.count)")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.coral)
                            }
                            
                            Spacer()
                            
                            // Next button
                            Button(action: {
                                viewModel.nextQuestion()
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(viewModel.selectedOption != nil && !viewModel.isLoading ? .coral : .gray.opacity(0.5))
                            }
                            .disabled(viewModel.selectedOption == nil || viewModel.isLoading)
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToMainApp) {
            MainTabView()
        }
        .onAppear {
            if viewModel.questions.isEmpty && !viewModel.isLoading {
                viewModel.loadQuestions()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                navigateToMainApp = true
            }
        }
    }
}

struct ModernOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                HStack {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.coral : Color.white.opacity(0.8))
                    .shadow(
                        color: isSelected ? Color.coral.opacity(0.3) : Color.gray.opacity(0.2),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    OnboardingView()
} 