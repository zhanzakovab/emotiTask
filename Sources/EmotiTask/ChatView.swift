import SwiftUI

struct ChatMessage {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

struct ChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hello! I'm your EmotiTask assistant. How are you feeling today?", isFromUser: false, timestamp: Date()),
        ChatMessage(text: "I'm ready to help you organize your tasks and understand your emotional patterns.", isFromUser: false, timestamp: Date())
    ]
    @State private var newMessage = ""
    @State private var isTyping = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    // Character
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.3))
                            .frame(width: 60, height: 60)
                        
                        // Happy face
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 4, height: 4)
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 4, height: 4)
                            }
                            
                            Path { path in
                                path.addArc(center: CGPoint(x: 8, y: 3), 
                                          radius: 6, 
                                          startAngle: .degrees(0), 
                                          endAngle: .degrees(180), 
                                          clockwise: false)
                            }
                            .stroke(Color.black, lineWidth: 1)
                            .frame(width: 16, height: 8)
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text("EmotiTask Assistant")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Your personal productivity companion")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages, id: \.id) { message in
                                MessageBubble(message: message)
                            }
                            
                            if isTyping {
                                TypingIndicator()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                // Input area
                VStack(spacing: 12) {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    HStack(spacing: 12) {
                        // Text input
                        HStack {
                            TextField("Share how you're feeling...", text: $newMessage)
                                .font(.body)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                        )
                        
                        // Send button
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(newMessage.isEmpty ? .gray.opacity(0.5) : .blue)
                        }
                        .disabled(newMessage.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
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
    
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let userMessage = ChatMessage(text: newMessage, isFromUser: true, timestamp: Date())
        messages.append(userMessage)
        
        let messageToProcess = newMessage
        newMessage = ""
        
        // Simulate AI response
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            let aiResponse = generateAIResponse(for: messageToProcess)
            let aiMessage = ChatMessage(text: aiResponse, isFromUser: false, timestamp: Date())
            messages.append(aiMessage)
        }
    }
    
    private func generateAIResponse(for message: String) -> String {
        let responses = [
            "I understand how you're feeling. Let's work through this together.",
            "That sounds like a great opportunity to grow. How can I help you tackle it?",
            "Your emotions are valid. Would you like to break this down into smaller steps?",
            "I can sense the energy in your message! What would you like to accomplish today?",
            "Thank you for sharing that with me. What's the most important thing on your mind right now?",
            "It sounds like you're processing a lot. Would creating a task list help organize your thoughts?"
        ]
        return responses.randomElement() ?? "I'm here to help you navigate through this."
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.blue)
                        )
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 8)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                        )
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                }
                
                Spacer(minLength: 60)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 8, height: 8)
                            .scaleEffect(animationOffset == CGFloat(index) ? 1.2 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: animationOffset
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                )
            }
            
            Spacer(minLength: 60)
        }
        .onAppear {
            animationOffset = 2
        }
    }
}

#Preview {
    ChatView()
} 