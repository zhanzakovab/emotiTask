import SwiftUI

struct ProfileView: View {
    @State private var showingPersonalityTest = false
    @State private var userName = "Alex"
    @State private var personalityType = "Explorer"
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        // Profile character
                        ZStack {
                            Circle()
                                .fill(Color.yellow.opacity(0.3))
                                .frame(width: 80, height: 80)
                            
                            // Profile face
                            VStack(spacing: 6) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 6, height: 6)
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 6, height: 6)
                                }
                                
                                Path { path in
                                    path.addArc(center: CGPoint(x: 10, y: 4), 
                                              radius: 8, 
                                              startAngle: .degrees(0), 
                                              endAngle: .degrees(180), 
                                              clockwise: false)
                                }
                                .stroke(Color.black, lineWidth: 1.5)
                                .frame(width: 20, height: 10)
                            }
                            
                            // Profile badge
                            VStack {
                                HStack {
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 24, height: 24)
                                        
                                        Image(systemName: "person.crop.circle")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .offset(x: -5, y: -5)
                                }
                                Spacer()
                            }
                        }
                        .frame(width: 80, height: 80)
                        
                        VStack(spacing: 4) {
                            Text("Hello, \(userName)!")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Personality Type: \(personalityType)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        ProfileStatCard(
                            title: "Days Active",
                            value: "12",
                            icon: "calendar",
                            color: .blue
                        )
                        
                        ProfileStatCard(
                            title: "Tasks Done",
                            value: "47",
                            icon: "checkmark.circle",
                            color: .green
                        )
                        
                        ProfileStatCard(
                            title: "Mood Score",
                            value: "8.2",
                            icon: "heart",
                            color: .pink
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Menu Options
                    VStack(spacing: 12) {
                        ProfileMenuItem(
                            icon: "brain.head.profile",
                            title: "Personality Results",
                            subtitle: "View your personality assessment",
                            action: {
                                showingPersonalityTest = true
                            }
                        )
                        
                        ProfileMenuItem(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Mood Analytics",
                            subtitle: "Track your emotional patterns over time",
                            action: {
                                // Handle mood analytics
                            }
                        )
                        
                        ProfileMenuItem(
                            icon: "gearshape",
                            title: "Preferences",
                            subtitle: "Customize your experience",
                            action: {
                                // Handle preferences
                            }
                        )
                        
                        ProfileMenuItem(
                            icon: "bell",
                            title: "Notifications",
                            subtitle: "Manage your notification settings",
                            action: {
                                // Handle notifications
                            }
                        )
                        
                        ProfileMenuItem(
                            icon: "questionmark.circle",
                            title: "Help & Support",
                            subtitle: "Get help and contact support",
                            action: {
                                // Handle help
                            }
                        )
                        
                        ProfileMenuItem(
                            icon: "info.circle",
                            title: "About EmotiTask",
                            subtitle: "Version 1.0.0",
                            action: {
                                // Handle about
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
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
        .fullScreenCover(isPresented: $showingPersonalityTest) {
            OnboardingView()
        }
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MoodAnalyticsView: View {
    var body: some View {
        VStack {
            Text("Mood Analytics")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Coming Soon!")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

#Preview {
    ProfileView()
} 