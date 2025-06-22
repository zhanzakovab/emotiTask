# 🎯 EmotiTask - Emotionally Intelligent Task Management

A SwiftUI iOS app that combines intelligent task management with MBTI personality insights and AI-powered emotional support.

## ✨ Features

### 🧠 Personality-Driven Experience
- **MBTI Assessment** - 10-question onboarding to determine your personality type
- **Personalized AI Chat** - Chat assistant adapts responses to your MBTI type
- **Emotional Task Tagging** - Categorize tasks by emotional context and energy requirements
- **Adaptive Suggestions** - Task recommendations based on your personality and current mood

### 📋 Smart Task Management
- **Intuitive Task Creation** - Quick task entry with emotional tags and priorities
- **Calendar Integration** - Visual calendar view with task scheduling
- **Priority Management** - Four-level priority system (Low, Medium, High, Urgent)
- **Progress Tracking** - Visual progress indicators and completion status
- **Project Organization** - Group related tasks into projects with goal tracking

### 🤖 AI-Powered Support
- **Emotional Intelligence** - AI recognizes emotional context in conversations
- **Contextual Suggestions** - Smart recommendations for task adjustments
- **Stress Management** - Detects overwhelm and suggests breaks or rescheduling
- **Motivational Support** - Encouraging responses tailored to your personality

### 🎨 Beautiful Interface
- **Modern SwiftUI Design** - Clean, intuitive user interface
- **Gradient Themes** - Warm, calming color schemes
- **Smooth Animations** - Polished transitions and interactions
- **Accessibility** - VoiceOver support and accessibility features

## 🏗️ Architecture

### Frontend (SwiftUI)
```
Sources/EmotiTask/
├── EmotiTaskApp.swift           # App entry point
├── WelcomeView.swift            # Landing screen
├── OnboardingView.swift         # MBTI personality assessment
├── OnboardingViewModel.swift    # Assessment logic and MBTI calculation
├── MainTabView.swift            # Main tab navigation
├── ChatView.swift               # AI chat interface
├── TodoView.swift               # Task management
├── CalendarView.swift           # Calendar view with task scheduling
├── ProfileView.swift            # User profile and settings
├── ToDoModels.swift             # Core data models
├── ChatModels.swift             # Chat and AI models
├── MBTIService.swift            # MBTI API integration
├── ChatService.swift           # Chat service management
├── OpenAIService.swift          # OpenAI integration
├── TaskService.swift           # Task operations
└── TaskServiceConfig.swift     # API configuration
```

### Backend (Python + Supabase)
```
emotitask-backend/
├── app/
│   ├── main.py                  # FastAPI application
│   ├── models.py                # Pydantic data models
│   ├── database.py              # Supabase connection
│   ├── mbti_calculator.py       # MBTI assessment logic
│   ├── openai_service.py        # OpenAI integration
│   └── routes/
│       ├── mbti.py              # MBTI endpoints
│       ├── chat.py              # Chat endpoints
│       ├── tasks.py             # Task management
│       ├── projects.py          # Project management
│       └── auth.py              # Authentication
├── supabase_schema.sql          # Database schema
├── requirements.txt             # Python dependencies
└── run.py                       # Server entry point
```

## 🚀 Quick Start

### Prerequisites
- **iOS Development**: Xcode 15.0+, iOS 15.0+
- **Backend**: Python 3.8+, Supabase account
- **AI Features**: OpenAI API key (optional)

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/emotitask.git
cd emotitask
```

### 2. Setup Supabase Database
1. Create a new project at [supabase.com](https://supabase.com)
2. Run the database schema:
```sql
-- Execute the contents of emotitask-backend/supabase_schema.sql
-- in your Supabase SQL Editor
```
3. Get your project URL and API key from Settings > API

### 3. Configure Backend
```bash
cd emotitask-backend
pip install -r requirements.txt

# Create .env file
echo "SUPABASE_URL=your_supabase_url" > .env
echo "SUPABASE_KEY=your_supabase_key" >> .env
echo "OPENAI_API_KEY=your_openai_key" >> .env  # Optional

# Start the server
python run.py
```

### 4. Configure iOS App
Update `TaskServiceConfig.swift`:
```swift
struct TaskServiceConfig {
    static let baseURL = "http://localhost:8000/api/v1"  // Your backend URL
    // ... other configuration
}
```

### 5. Build and Run
Open the project in Xcode and run, or use Swift Package Manager:
```bash
swift build
```

## 🗄️ Database Schema

### Core Tables

#### MBTI System
- **`questions`** - 10 personality assessment questions
- **`answers`** - 40 multiple choice answers (4 per question)
- **`personality_types`** - 16 MBTI types with descriptions
- **`chat_styles`** - AI chat configurations per personality type

#### User Management
- **`user_profiles`** - User data with assigned MBTI personality
- **`chat_data`** - Conversation history and context

#### Task System
- **`tasks`** - Individual tasks with emotional tags and priorities
- **`projects`** - Project containers for task organization
- **`goals`** - Long-term objectives with progress tracking

### Key Features
- **Row-Level Security** - Users can only access their own data
- **Foreign Key Relationships** - Maintains data integrity
- **Automatic Timestamps** - Tracks creation and updates
- **UUID Primary Keys** - Globally unique identifiers

## 🧠 MBTI Integration

### Assessment Process
1. **10 Scenario Questions** - Fun, relatable situations
2. **4 Answer Choices** - Each maps to MBTI dimensions (E/I, S/N, T/F, J/P)
3. **Automatic Calculation** - Backend determines personality type
4. **Profile Creation** - User profile linked to MBTI type

### 16 Personality Types
- **Analysts**: INTJ, INTP, ENTJ, ENTP
- **Diplomats**: INFJ, INFP, ENFJ, ENFP
- **Sentinels**: ISTJ, ISFJ, ESTJ, ESFJ
- **Explorers**: ISTP, ISFP, ESTP, ESFP

### Chat Personalization
Each personality type has unique:
- **Response Keywords** - Vocabulary that resonates
- **Communication Style** - Formal vs casual tone
- **AI Temperature** - Creativity vs consistency balance
- **Task Recommendations** - Aligned with personality strengths

## 🤖 AI Features

### Chat Assistant Capabilities
- **Emotional Support** - Recognizes stress, overwhelm, excitement
- **Task Suggestions** - Recommends breaks, rescheduling, prioritization
- **Personality Adaptation** - Adjusts tone and advice to MBTI type
- **Context Awareness** - Remembers conversation history

### Smart Suggestions
- **Overwhelm Detection** → Suggests task rescheduling
- **Low Energy** → Recommends self-care breaks
- **High Stress** → Proposes breathing exercises
- **Deadline Pressure** → Helps prioritize critical tasks

## 📊 Data Models

### Core Models
```swift
struct TodoTask: Identifiable, Codable {
    let id: String
    var title: String
    var notes: String
    var isCompleted: Bool
    var emotionalTag: EmotionalTag?
    var priority: TaskPriority
    var scheduledDate: Date
    var estimatedDuration: Int
}

enum EmotionalTag: String, CaseIterable {
    case lowEnergy = "Low Energy"
    case focus = "Focus"
    case creative = "Creative"
    case social = "Social"
    case selfCare = "Self Care"
    case routine = "Routine"
    case timeSensitive = "Time Sensitive"
    case challenging = "Challenging"
}

enum TaskPriority: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
}
```

### MBTI Models
```swift
struct MBTIQuestion: Codable {
    let id: Int
    let questionText: String
    let answers: [MBTIAnswer]
}

struct PersonalityType: Codable {
    let personaId: String  // e.g., "INTJ"
    let name: String       // e.g., "The Architect"
    let description: String
}
```

## 🎨 UI/UX Design

### Design Principles
- **Emotional Warmth** - Soft gradients and calming colors
- **Clarity** - Clear typography and intuitive navigation
- **Accessibility** - VoiceOver support and high contrast options
- **Responsiveness** - Smooth animations and immediate feedback

### Color Scheme
- **Primary Gradients** - Warm oranges and soft blues
- **Emotional Tags** - Color-coded for quick recognition
- **Priority Levels** - Visual hierarchy with distinct colors
- **Chat Interface** - Bubble design with personality-based styling

## 🔧 Configuration

### Environment Variables
```bash
# Backend (.env)
SUPABASE_URL=your_supabase_project_url
SUPABASE_KEY=your_supabase_anon_key
OPENAI_API_KEY=your_openai_api_key  # Optional
```

### iOS Configuration
```swift
// TaskServiceConfig.swift
struct TaskServiceConfig {
    static let baseURL = "http://localhost:8000/api/v1"
    static let timeoutInterval: TimeInterval = 30.0
    static let enableBackendIntegration = true
}
```

## 🧪 Testing

### Backend API Testing
```bash
cd emotitask-backend

# Test MBTI endpoints
python test_mbti_api.py

# Test chat functionality
python test_chat_api.py

# Test task integration
python test_task_integration.py
```

### Manual Testing Checklist
- [ ] Complete MBTI assessment
- [ ] Create and manage tasks
- [ ] Test AI chat responses
- [ ] Verify calendar integration
- [ ] Check data persistence
- [ ] Test offline functionality

## 📱 Platform Support

### iOS Requirements
- **iOS 15.0+** - SwiftUI 3.0 features
- **iPhone/iPad** - Universal app support
- **iOS Simulator** - Full development support
- **macOS** - Mac Catalyst compatibility

### Backend Deployment
- **Local Development** - Python FastAPI server
- **Production** - Deploy to Heroku, Railway, or similar
- **Database** - Supabase PostgreSQL (managed)
- **AI Services** - OpenAI API integration

## 🚀 Deployment

### iOS App Store
1. **Archive in Xcode** - Create release build
2. **App Store Connect** - Upload and configure listing
3. **Review Process** - Apple review (1-3 days typically)
4. **Release** - Publish to App Store

### Backend Deployment
```bash
# Example: Deploy to Railway
railway login
railway init
railway add postgresql
railway deploy
```

## 📈 Future Roadmap

### Planned Features
- **Team Collaboration** - Shared projects and tasks
- **Advanced Analytics** - Productivity insights and patterns
- **Habit Tracking** - Recurring task management
- **Voice Commands** - Siri integration for quick task entry
- **Apple Watch** - Glanceable task overview and quick actions
- **Widgets** - Home screen task summary

### Technical Improvements
- **Offline-First Architecture** - Enhanced offline capabilities
- **Performance Optimization** - Faster data loading and sync
- **Advanced AI** - More sophisticated personality adaptation
- **Localization** - Multi-language support
- **Accessibility** - Enhanced VoiceOver and assistive technology support

## 🤝 Contributing

### Development Guidelines
1. **Fork** the repository
2. **Create** feature branch (`git checkout -b feature/amazing-feature`)
3. **Follow** Swift style guidelines and MVVM patterns
4. **Add** tests for new functionality
5. **Commit** changes (`git commit -m 'Add amazing feature'`)
6. **Push** to branch (`git push origin feature/amazing-feature`)
7. **Open** Pull Request

### Code Standards
- **SwiftLint** - Automated style checking
- **MVVM Architecture** - Consistent separation of concerns
- **Async/Await** - Modern concurrency patterns
- **Documentation** - Comprehensive inline documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenAI** - GPT integration for intelligent conversations
- **Supabase** - Backend-as-a-Service platform and database
- **Swift Community** - SwiftUI frameworks and development resources
- **MBTI Foundation** - Personality type system and assessment methodology
- **Design Inspiration** - Modern productivity and wellness apps

## 📞 Support

- **GitHub Issues** - Bug reports and feature requests
- **Discussions** - Community questions and ideas
- **Documentation** - Comprehensive setup and usage guides
- **Email Support** - Direct technical assistance

---

**Built with ❤️ using SwiftUI, Python, and Supabase**

*EmotiTask - Where productivity meets emotional intelligence and personality insights* 