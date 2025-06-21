import SwiftUI

struct WelcomeView: View {
    @State private var showingOnboarding = false
    @State private var showingMainApp = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Main content
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Character with checkmark
                    ZStack {
                        // Main character circle
                        Circle()
                            .fill(Color.yellow.opacity(0.3))
                            .frame(width: 120, height: 120)
                        
                        // Face
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 8, height: 8)
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 8, height: 8)
                            }
                            
                            // Smile
                            Path { path in
                                path.addArc(center: CGPoint(x: 15, y: 5), 
                                          radius: 12, 
                                          startAngle: .degrees(0), 
                                          endAngle: .degrees(180), 
                                          clockwise: false)
                            }
                            .stroke(Color.black, lineWidth: 2)
                            .frame(width: 30, height: 15)
                        }
                        
                        // Checkmark badge
                        VStack {
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color.cyan)
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .offset(x: -8, y: 8)
                            }
                            Spacer()
                        }
                    }
                    .frame(width: 120, height: 120)
                    
                    // App title
                    Text("EmotiTask")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    // Subtitle
                    VStack(spacing: 8) {
                        Text("Log in or sign up")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("to get started")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            showingOnboarding = true
                        }) {
                            Text("Log in")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.blue)
                                .cornerRadius(28)
                        }
                        
                        Button(action: {
                            showingOnboarding = true
                        }) {
                            Text("Sign up")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.blue)
                                .cornerRadius(28)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                
                // Footer links
                HStack(spacing: 60) {
                    Button("Privacy Policy") {
                        // Handle privacy policy
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                    
                    Button("Terms of Service") {
                        // Handle terms of service
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
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
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView()
        }
        .fullScreenCover(isPresented: $showingMainApp) {
            MainTabView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
            showingOnboarding = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingMainApp = true
            }
        }
    }
}

#Preview {
    WelcomeView()
} 