import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1 // Default to chat (center)
    
    var body: some View {
        ZStack {
            // Content Views
            Group {
                switch selectedTab {
                case 0:
                    ProfileView()
                case 1:
                    ChatView()
                case 2:
                    TodoView()
                default:
                    ChatView()
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            
            // Custom Floating Tab Bar
            VStack {
                Spacer()
                FloatingTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34) // Account for safe area
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.1),
                    Color.pink.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    @State private var centerButtonScale: CGFloat = 1.0
    
    var body: some View {
        HStack {
            // Profile Tab
            TabButton(
                icon: "person.circle.fill",
                isSelected: selectedTab == 0,
                action: { 
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 0
                    }
                }
            )
            
            Spacer()
            
            // Tasks Tab  
            TabButton(
                icon: "checkmark.circle.fill",
                isSelected: selectedTab == 2,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 2
                    }
                }
            )
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            // Center Floating Button - Siri Style
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                    centerButtonScale = 0.95
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        centerButtonScale = 1.0
                    }
                }
            }) {
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.blue.opacity(0.3),
                                    Color.blue.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 25,
                                endRadius: 35
                            )
                        )
                        .frame(width: 70, height: 70)
                        .opacity(selectedTab == 1 ? 1.0 : 0.6)
                    
                    // Main button
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.9),
                                    Color.blue.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    // Emoji Character
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.95))
                            .frame(width: 32, height: 32)
                        
                        VStack(spacing: 2) {
                            HStack(spacing: 3) {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 2.5, height: 2.5)
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 2.5, height: 2.5)
                            }
                            
                            Path { path in
                                path.addArc(
                                    center: CGPoint(x: 8, y: 2), 
                                    radius: 5, 
                                    startAngle: .degrees(0), 
                                    endAngle: .degrees(180), 
                                    clockwise: false
                                )
                            }
                            .stroke(Color.black, lineWidth: 0.8)
                            .frame(width: 16, height: 8)
                        }
                    }
                }
            }
            .scaleEffect(centerButtonScale)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: centerButtonScale)
            .offset(y: -8) // Float above the tab bar
        )
    }
}

struct TabButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .blue : .gray.opacity(0.6))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

#Preview {
    MainTabView()
} 