import SwiftUI

struct ChatView: View {
    @StateObject private var chatSession = ChatSessionData(chatService: ChatServiceManager.shared.createChatService())
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
                            
                            // Show loading indicator
                            if chatSession.isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Thinking...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // Show error message if any
                            if let errorMessage = chatSession.errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .onChange(of: chatSession.messages.count) { _, _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if let lastMessage = chatSession.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
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
                                .onSubmit {
                                    sendMessage()
                                }
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
                        .disabled(newMessage.isEmpty || chatSession.isLoading)
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
            // Generate AI welcome message if this is a new session
            if chatSession.messages.isEmpty {
                generateWelcomeMessage()
            }
        }
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let messageToProcess = newMessage
        newMessage = ""
        
        // Clear previous suggestions
        pendingSuggestions = []
        
        // Use the new async API-ready method
        _Concurrency.Task.detached { @MainActor in
            await chatSession.sendMessage(messageToProcess)
            
            // Generate contextual todo suggestions
            let suggestions = await chatSession.generateSuggestions(
                for: messageToProcess, 
                currentTasks: toDoSession.todayTasks
            )
            
            if !suggestions.isEmpty {
                // Add suggestion as natural AI conversation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    chatSession.addAIMessage(suggestions.first?.message ?? "")
                    pendingSuggestions = suggestions
                }
            }
        }
    }
    
    private func applySuggestion(_ suggestion: TodoSuggestion) {
        switch suggestion.actionType {
        case .rescheduleTask(let newDate):
            if let taskId = suggestion.taskId {
                toDoSession.rescheduleTask(taskId, to: newDate)
                chatSession.addAIMessage("✅ I've rescheduled that task for you. Focus on what matters most today!")
            }
        case .addSelfCare:
            let selfCareTask = EmotiTask.Task(
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
            let breakTask = EmotiTask.Task(
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
    
    private func generateWelcomeMessage() {
        // Generate contextual welcome message using GPT
        _Concurrency.Task.detached { @MainActor in
            do {
                // Create a context-aware welcome prompt
                let currentTime = Date()
                let timeFormatter = DateFormatter()
                timeFormatter.timeStyle = .short
                let timeString = timeFormatter.string(from: currentTime)
                
                let welcomePrompt = """
                This is the very first time the user is opening EmotiTask. Generate a warm, natural welcome message that:
                1. Introduces yourself as EmotiTask
                2. Briefly explains what you do (emotionally intelligent task management)
                3. Asks how they're feeling or what they'd like to work on
                4. Keep it conversational and welcoming (2-3 sentences max)
                5. It's currently \(timeString)
                
                Make it feel like a natural conversation starter, not a robotic introduction.
                """
                
                let welcomeMessage = try await chatSession.chatService.sendMessage(welcomePrompt)
                chatSession.addAIMessage(welcomeMessage)
                
            } catch {
                // Fallback to a simple welcome if GPT fails
                chatSession.addAIMessage("Hello! I'm EmotiTask, your emotionally intelligent assistant. How are you feeling today? 🌟")
            }
        }
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