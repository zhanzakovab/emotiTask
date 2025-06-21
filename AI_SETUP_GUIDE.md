# 🤖 EmotiTask AI Setup & Customization Guide

## 🚀 Quick Setup

### Step 1: Add Your OpenAI API Key

Open `Sources/EmotiTask/ChatService.swift` and find the `getOpenAIAPIKey()` function:

```swift
private func getOpenAIAPIKey() -> String? {
    // Option 1: From environment variable
    if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
        return apiKey
    }
    
    // Option 2: From UserDefaults (not recommended for production)
    if let apiKey = UserDefaults.standard.string(forKey: "openai_api_key") {
        return apiKey
    }
    
    // Option 3: From Keychain (recommended for production)
    // return KeychainManager.getAPIKey(for: "openai")
    
    return nil  // 👈 REPLACE THIS LINE
}
```

**Replace the `return nil` line with:**
```swift
return "your-openai-api-key-here"
```

### Step 2: Run Your App

That's it! The console will show:
- ✅ `🤖 Using OpenAI ChatGPT service` (with API key)
- ✅ `🎭 Using dummy chat service (no API key found)` (without API key)

---

## 🎨 Customizing Your AI

**All AI configuration is in `Sources/EmotiTask/OpenAIService.swift`**

### 1. Change AI Personality

Edit the `systemPrompt` property:

```swift
private var systemPrompt: String {
    return """
    You are EmotiTask, a [YOUR PERSONALITY HERE]
    
    Your personality:
    - [TRAIT 1]
    - [TRAIT 2]
    - [TRAIT 3]
    
    Your role:
    - [ROLE 1]
    - [ROLE 2]
    """
}
```

**Example Personalities:**
- **Professional**: "You are a professional productivity coach..."
- **Casual Friend**: "You are a supportive friend who's great at organization..."
- **Motivational**: "You are an energetic motivational coach..."

### 2. Adjust Response Style

Modify the `modelSettings` property:

```swift
private var modelSettings: OpenAIModelSettings {
    return OpenAIModelSettings(
        model: "gpt-3.5-turbo",        // or "gpt-4" for better responses
        maxTokens: 150,                // 50-300 for different lengths
        temperature: 0.7               // 0.1 (focused) to 1.0 (creative)
    )
}
```

**Temperature Guide:**
- `0.1-0.3`: Focused, consistent responses
- `0.4-0.7`: Balanced (recommended)
- `0.8-1.0`: Creative, varied responses

### 3. Model Options

- **`gpt-3.5-turbo`**: Fast, cost-effective (recommended)
- **`gpt-4`**: More intelligent, slower, more expensive
- **`gpt-4-turbo`**: Latest model with better performance

---

## 🔮 Future Enhancement Ideas

The `OpenAIService.swift` file is ready for these upgrades:

### AI-Powered Task Management
```swift
// TODO: Add to generateTaskSuggestions method
- Analyze user's emotional state
- Suggest optimal task ordering
- Recommend break times
- Personalized productivity tips
```

### Advanced Features
- **Function Calling**: Let AI directly manage tasks
- **Memory**: Remember user preferences and patterns
- **Context Awareness**: Responses based on time of day
- **Integration**: Connect with calendar and reminders

### Personality Presets
```swift
enum AIPersonality {
    case professional
    case casual
    case motivational
    case therapeutic
    
    var systemPrompt: String {
        // Different prompts for each personality
    }
}
```

---

## 🛡️ Security Best Practices

### For Development:
```swift
return "sk-your-api-key-here"  // Direct in code (testing only)
```

### For Production:
```swift
// Environment variable (recommended)
return ProcessInfo.processInfo.environment["OPENAI_API_KEY"]

// Or use Keychain (most secure)
return KeychainManager.getAPIKey(for: "openai")
```

---

## 🎯 Quick Customization Examples

### Make AI More Professional:
```swift
"You are EmotiTask, a professional productivity consultant with expertise in emotional intelligence and task management."
```

### Make AI More Casual:
```swift
"You are EmotiTask, a friendly and supportive buddy who happens to be amazing at helping people get organized."
```

### Make AI More Motivational:
```swift
"You are EmotiTask, an energetic and inspiring productivity coach who believes everyone can achieve their goals."
```

---

**Your AI assistant is ready to be customized exactly how you want it!** 🌟 