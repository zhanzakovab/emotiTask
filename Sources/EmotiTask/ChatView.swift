import SwiftUI

// Todo Suggestion for Chat Integration
struct TodoSuggestion: Identifiable {
    let id = UUID()
    let message: String
    let actionType: SuggestionActionType
    let taskId: UUID?
    
    enum SuggestionActionType {
        case rescheduleTask(to: Date)
        case addBreak
        case prioritizeTask
        case addSelfCare
        case swapTasks
    }
}

struct ChatView: View {
    @StateObject private var chatSession = ChatSessionData.dummy
    @StateObject private var toDoSession = ToDoSessionData.createDummyData()
    @State private var newMessage = ""
    @State private var pendingSuggestions: [TodoSuggestion] = []
    @State private var showDemoSuggestions = true // Demo mode to show suggestions immediately
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(chatSession.messages, id: \.id) { message in
                                MessageBubbleWithActions(
                                    message: message, 
                                    showActions: message.sender == .ai && 
                                                message.id == chatSession.messages.last?.id &&
                                                !pendingSuggestions.isEmpty,
                                    onTryIt: { 
                                        if let suggestion = pendingSuggestions.first {
                                            applySuggestion(suggestion)
                                        }
                                    },
                                    onNotNow: {
                                        if let suggestion = pendingSuggestions.first {
                                            dismissSuggestion(suggestion)
                                        }
                                    }
                                )
                            }
                            
                            if chatSession.isTyping {
                                TypingIndicator()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .onChange(of: chatSession.messages.count) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(chatSession.messages.last?.id, anchor: .bottom)
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
        .onAppear {
            // Show demo suggestions immediately for testing
            if showDemoSuggestions {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    chatSession.addAIMessage("I notice you mentioned a presentation earlier. Would you like me to reschedule some less important tasks to give you more focus time?")
                    pendingSuggestions = [
                        TodoSuggestion(
                            message: "I notice you mentioned a presentation. Would you like me to reschedule less important tasks to give you more focus time?",
                            actionType: .rescheduleTask(to: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()),
                            taskId: toDoSession.todayTasks.first { $0.priority == .low }?.id
                        )
                    ]
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        chatSession.addUserMessage(newMessage)
        
        let messageToProcess = newMessage
        newMessage = ""
        
        // Clear previous suggestions
        pendingSuggestions = []
        
        // Simulate AI response
        chatSession.simulateTyping()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let aiResponse = generateAIResponse(for: messageToProcess)
            chatSession.addAIMessage(aiResponse)
            
            // Generate contextual todo suggestions and add them as AI messages
            let suggestions = generateSuggestions(for: messageToProcess)
            if !suggestions.isEmpty {
                // Add suggestion as natural AI conversation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    chatSession.addAIMessage(suggestions.first?.message ?? "")
                    pendingSuggestions = suggestions
                }
            }
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
    
    private func generateSuggestions(for message: String) -> [TodoSuggestion] {
        let lowercaseMessage = message.lowercased()
        var suggestions: [TodoSuggestion] = []
        
        // Analyze emotional context and suggest todo changes
        if lowercaseMessage.contains("overwhelmed") || lowercaseMessage.contains("stressed") {
            suggestions.append(TodoSuggestion(
                message: "I notice you're feeling overwhelmed. Would you like me to reschedule some lower-priority tasks to tomorrow?",
                actionType: .rescheduleTask(to: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()),
                taskId: toDoSession.todayTasks.first { $0.priority == .low }?.id
            ))
            
            suggestions.append(TodoSuggestion(
                message: "How about adding a 10-minute breathing break to your schedule?",
                actionType: .addSelfCare,
                taskId: nil
            ))
        }
        
        if lowercaseMessage.contains("tired") || lowercaseMessage.contains("exhausted") {
            suggestions.append(TodoSuggestion(
                message: "You sound tired. Want me to prioritize your energy-friendly tasks for now?",
                actionType: .prioritizeTask,
                taskId: toDoSession.todayTasks.first { $0.emotionalTag == .lowEnergy }?.id
            ))
        }
        
        if lowercaseMessage.contains("presentation") || lowercaseMessage.contains("deadline") {
            suggestions.append(TodoSuggestion(
                message: "I can help you focus on your presentation. Should I move other tasks to give you more time?",
                actionType: .prioritizeTask,
                taskId: toDoSession.todayTasks.first { $0.emotionalTag == .focus }?.id
            ))
        }
        
        return suggestions
    }
    
    private func applySuggestion(_ suggestion: TodoSuggestion) {
        switch suggestion.actionType {
        case .rescheduleTask(let newDate):
            if let taskId = suggestion.taskId {
                toDoSession.rescheduleTask(taskId, to: newDate)
                chatSession.addAIMessage("✅ I've rescheduled that task for you. Focus on what matters most today!")
            }
        case .addSelfCare:
            let selfCareTask = Task(
                title: "Take a mindful break",
                emotionalTag: .selfCare,
                scheduledDate: Date(),
                notes: "10 minutes of deep breathing or meditation",
                priority: .medium,
                estimatedDuration: 10
            )
            toDoSession.addTask(selfCareTask)
            chatSession.addAIMessage("✅ I've added a mindful break to your schedule. Your wellbeing matters!")
        case .prioritizeTask:
            if suggestion.taskId != nil {
                chatSession.addAIMessage("✅ I've prioritized that task for you. You've got this!")
            }
        case .addBreak:
            let breakTask = Task(
                title: "Short break",
                emotionalTag: .selfCare,
                scheduledDate: Date(),
                estimatedDuration: 15
            )
            toDoSession.addTask(breakTask)
            chatSession.addAIMessage("✅ I've scheduled a break for you. Rest is productive too!")
        case .swapTasks:
            chatSession.addAIMessage("✅ I've reorganized your tasks to better match your energy!")
        }
        
        // Remove applied suggestion
        pendingSuggestions.removeAll { $0.id == suggestion.id }
    }
    
    private func dismissSuggestion(_ suggestion: TodoSuggestion) {
        pendingSuggestions.removeAll { $0.id == suggestion.id }
        chatSession.addAIMessage("No problem! I'm here if you change your mind.")
    }
}

struct MessageBubbleWithActions: View {
    let message: ChatMessage
    let showActions: Bool
    let onTryIt: () -> Void
    let onNotNow: () -> Void
    
    var body: some View {
        HStack {
            if message.sender == .user {
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
                    
                    Text(message.timestamp.chatTimeString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 8)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 8) {
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
                        
                        // Action buttons right after the message
                        if showActions {
                            HStack(spacing: 12) {
                                Button(action: onNotNow) {
                                    Text("Not now")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray.opacity(0.8))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(16)
                                }
                                
                                Button(action: onTryIt) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                        Text("Try it")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(16)
                                }
                                
                                Spacer()
                            }
                            .padding(.leading, 16)
                        }
                    }
                    
                    Text(message.timestamp.chatTimeString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                }
                
                Spacer(minLength: 60)
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        MessageBubbleWithActions(
            message: message,
            showActions: false,
            onTryIt: {},
            onNotNow: {}
        )
    }
}

struct ActionButtons: View {
    let onTryIt: () -> Void
    let onNotNow: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Button(action: onNotNow) {
                    Text("Not now")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                }
                
                Button(action: onTryIt) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.caption)
                        Text("Try it")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
            )
            
            Spacer(minLength: 60)
        }
        .padding(.horizontal, 20)
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