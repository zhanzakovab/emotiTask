import SwiftUI

extension Color {
    static let coral = Color(red: 1.0, green: 0.5, blue: 0.31)
}

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
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
                
                // Main content
                VStack(spacing: 40) {
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
                            Text("Allow me to know you better...")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 20)
                        }
                        
                        Text(viewModel.currentQuestion.question)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                    }
                    
                    // Options
                    VStack(spacing: 16) {
                        ForEach(0..<viewModel.currentQuestion.options.count, id: \.self) { index in
                            ModernOptionButton(
                                title: viewModel.currentQuestion.options[index],
                                isSelected: viewModel.selectedOption == index,
                                action: {
                                    viewModel.selectOption(index)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    
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
                            Text("Complete")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(viewModel.selectedOption != nil ? .coral : .gray.opacity(0.5))
                        } else {
                        Text("\(viewModel.currentQuestionIndex + 1)/\(viewModel.questions.count)")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.coral)
                        }
                        
                        Spacer()
                        
                        // Next button (only show if not last question)
                        if !viewModel.isLastQuestion {
                        Button(action: {
                            viewModel.nextQuestion()
                        }) {
                                Image(systemName: "arrow.right")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(viewModel.selectedOption != nil ? .coral : .gray.opacity(0.5))
                            }
                            .disabled(viewModel.selectedOption == nil)
                        } else {
                            // Invisible spacer to keep layout balanced
                            Button(action: {
                                viewModel.nextQuestion()
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(.title3)
                                    .opacity(0)
                        }
                        .disabled(viewModel.selectedOption == nil)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.3),
                    Color.pink.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct ModernOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .black)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                
                if isSelected {
                    HStack {
                        Spacer()
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
                    .fill(isSelected ? Color.blue : Color.white.opacity(0.8))
                    .shadow(
                        color: isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2),
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