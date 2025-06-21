import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1 // Default to chat (center)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Profile Tab (Left)
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                        .font(.title2)
                }
                .tag(0)
            
            // Chat Tab (Center - Default)
            ChatView()
                .tabItem {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 32, height: 32)
                        
                        // App icon - simplified emoji character
                        ZStack {
                            Circle()
                                .fill(Color.yellow.opacity(0.9))
                                .frame(width: 24, height: 24)
                            
                            VStack(spacing: 2) {
                                HStack(spacing: 3) {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 2, height: 2)
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 2, height: 2)
                                }
                                
                                Path { path in
                                    path.addArc(center: CGPoint(x: 6, y: 2), 
                                              radius: 4, 
                                              startAngle: .degrees(0), 
                                              endAngle: .degrees(180), 
                                              clockwise: false)
                                }
                                .stroke(Color.black, lineWidth: 0.5)
                                .frame(width: 12, height: 6)
                            }
                        }
                    }
                }
                .tag(1)
            
            // Todo Tab (Right)
            TodoView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                }
                .tag(2)
        }
        .accentColor(.blue)
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

#Preview {
    MainTabView()
} 