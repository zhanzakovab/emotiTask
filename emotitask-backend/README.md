# 🚀 EmotiTask - Emotionally Intelligent Task Management

A SwiftUI app that combines task management with emotional intelligence and AI-powered suggestions.

## ✨ Features

### 🎯 Core Functionality
- **Smart Task Management** - Create, organize, and complete tasks
- **Emotional Intelligence** - Tag tasks with emotional context
- **AI Chat Assistant** - Get personalized suggestions and support
- **Project Organization** - Group related tasks into projects
- **Goal Tracking** - Set and monitor long-term objectives
- **Calendar Integration** - Schedule and view tasks by date

### 🧠 Emotional Intelligence
- **Emotional Tags** - Categorize tasks by emotional state needed
- **Adaptive Suggestions** - AI suggests task changes based on your mood
- **Personality Assessment** - 10-question onboarding to understand your work style
- **Contextual Support** - Chat assistant provides emotional guidance

### 🤖 AI Integration
- **OpenAI GPT Integration** - Powered by ChatGPT for intelligent conversations
- **Personalized Responses** - AI adapts to your personality type
- **Task Suggestions** - Smart recommendations based on your emotional state
- **Time-aware Context** - AI considers time of day and schedule

## 🏗️ Architecture

### Frontend (SwiftUI)
- **MVVM Pattern** - Clean separation of concerns
- **Combine Framework** - Reactive data flow
- **SwiftUI Navigation** - Modern navigation patterns
- **Async/Await** - Modern concurrency handling

### Backend (Supabase)
- **PostgreSQL Database** - Robust data storage
- **Row-Level Security** - User data protection
- **Real-time Sync** - Instant updates across devices
- **Authentication** - Secure user management
- **RESTful API** - Automatic API generation

## 📱 App Structure

```
EmotiTask/
├── Sources/EmotiTask/
│   ├── EmotiTaskApp.swift          # App entry point
│   ├── WelcomeView.swift           # Landing page
│   ├── OnboardingView.swift        # Personality assessment
│   ├── MainTabView.swift           # Main navigation
│   ├── ChatView.swift              # AI chat interface
│   ├── TodoView.swift              # Task management
│   ├── CalendarView.swift          # Calendar view
│   ├── ProfileView.swift           # User profile
│   ├── Models/
│   │   ├── ToDoModels.swift        # Task/Project/Goal models
│   │   └── ChatModels.swift        # Chat/AI models
│   └── Services/
│       ├── SupabaseService.swift   # Backend integration
│       ├── OpenAIService.swift     # AI chat service
│       └── TaskService.swift       # Task operations
└── SUPABASE_SETUP.md              # Backend setup guide
```

## 🚀 Quick Start

### Prerequisites
- Xcode 15.0+
- iOS 15.0+
- Supabase account
- OpenAI API key (optional)

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/emotitask.git
cd emotitask
```

### 2. Setup Supabase Backend
Follow the complete guide in [SUPABASE_SETUP.md](SUPABASE_SETUP.md):

1. Create Supabase project
2. Run database schema
3. Get project credentials
4. Update `SupabaseConfig` in the app

### 3. Add OpenAI Integration (Optional)
1. Get OpenAI API key from [platform.openai.com](https://platform.openai.com)
2. Update `OpenAIService.swift` with your key
3. Enable AI features in settings

### 4. Build and Run
```bash
swift build
# Or open in Xcode and run
```

## 🗄️ Database Schema

### Core Tables
- **users** - User authentication (managed by Supabase Auth)
- **user_profiles** - Personality types and preferences
- **projects** - Task organization containers
- **tasks** - Individual task items with emotional context
- **goals** - Long-term objectives with progress tracking

### Key Features
- **Row-Level Security** - Users only access their own data
- **Real-time Subscriptions** - Live updates across devices
- **Automatic Timestamps** - Created/updated tracking
- **UUID Primary Keys** - Globally unique identifiers

## 🤖 AI Features

### Chat Assistant
- **Emotional Support** - Provides encouragement and guidance
- **Task Suggestions** - Recommends task modifications
- **Context Awareness** - Remembers conversation history
- **Personality Adaptation** - Adjusts responses to user type

### Smart Suggestions
- **Overwhelm Detection** - Suggests task rescheduling
- **Energy Matching** - Recommends tasks based on energy level
- **Break Reminders** - Suggests self-care activities
- **Priority Adjustment** - Helps focus on important tasks

## 📊 Data Models

### Task Model
```swift
struct Task: Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var emotionalTag: EmotionalTag?
    var scheduledDate: Date
    var notes: String
    var priority: TaskPriority
    var estimatedDuration: Int
    var projectId: UUID?
}
```

### Emotional Tags
- **Low Energy** - Tasks suitable for tired states
- **Focus** - Deep work requiring concentration
- **Creative** - Brainstorming and ideation
- **Social** - Collaboration and communication
- **Self Care** - Wellness and personal time
- **Routine** - Regular maintenance tasks

## 🔧 Configuration

### Environment Setup
1. **Supabase Credentials** - Add to `SupabaseConfig`
2. **OpenAI API Key** - Add to `OpenAIService`
3. **Backend Toggle** - Enable/disable in `TaskServiceConfig`

### Customization
- **Personality Types** - Modify in `OnboardingViewModel`
- **Emotional Tags** - Update `EmotionalTag` enum
- **AI Prompts** - Customize in `OpenAIService`
- **UI Themes** - Adjust colors and styling

## 🧪 Testing

### Manual Testing
1. **Authentication Flow** - Sign up/in with email
2. **Task Operations** - Create, complete, delete tasks
3. **AI Chat** - Test conversation and suggestions
4. **Offline Mode** - Test without internet connection
5. **Data Sync** - Verify cross-device synchronization

### Unit Tests
```bash
swift test
```

## 🚀 Deployment

### iOS App Store
1. **Archive in Xcode** - Create release build
2. **Upload to App Store Connect** - Submit for review
3. **Configure App Store Listing** - Screenshots, description
4. **Review Process** - Apple review (typically 1-3 days)

### Backend (Supabase)
- **Automatic Scaling** - Handles traffic increases
- **Global CDN** - Fast worldwide access
- **Backup & Recovery** - Built-in data protection
- **Monitoring** - Real-time performance metrics

## 📈 Future Roadmap

### Planned Features
- **Team Collaboration** - Shared projects and tasks
- **Advanced Analytics** - Productivity insights
- **Habit Tracking** - Recurring task patterns
- **Voice Commands** - Siri integration
- **Apple Watch** - Quick task interactions
- **Widgets** - Home screen task overview

### Technical Improvements
- **Offline-First** - Enhanced offline capabilities
- **Performance** - Optimized for large datasets
- **Accessibility** - VoiceOver and accessibility features
- **Localization** - Multi-language support

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create feature branch
3. Follow Swift style guidelines
4. Add tests for new features
5. Submit pull request

### Code Style
- **SwiftLint** - Automated style checking
- **MVVM Pattern** - Consistent architecture
- **Async/Await** - Modern concurrency
- **Documentation** - Comprehensive comments

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenAI** - GPT-4 for intelligent conversations
- **Supabase** - Backend-as-a-Service platform
- **Swift Community** - SwiftUI and development resources
- **Design Inspiration** - Modern task management apps

## 📞 Support

- **Issues** - Report bugs on GitHub Issues
- **Discussions** - Feature requests and questions
- **Email** - Direct support contact
- **Documentation** - Comprehensive guides and tutorials

---

**Built with ❤️ using SwiftUI and Supabase**

*EmotiTask - Where productivity meets emotional intelligence*