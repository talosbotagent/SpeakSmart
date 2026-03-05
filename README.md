# SpeakSmart

AI Voice Writer iOS App — Transform spoken words into perfectly formatted text with AI-powered tone control.

## Features

- 🎤 **Voice-to-Text** — Real-time dictation with high accuracy
- ✨ **AI Rewriting** — Transform text into: Professional, Casual, Funny, Polite, Concise, Detailed
- 📝 **Format Options** — Email, Notes, Message, Memo, Social Post
- 📚 **History** — Save and organize previous recordings
- 📤 **Export** — Share to any app, copy to clipboard

## Tech Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Speech Recognition:** Speech framework (Apple native)
- **AI:** OpenAI GPT-4o-mini API for rewriting
- **Storage:** UserDefaults (lightweight) / Core Data (scale)
- **Minimum iOS:** 17.0

## Project Structure

```
SpeakSmart/
├── App/
│   ├── SpeakSmartApp.swift
│   └── Info.plist
├── Features/
│   ├── Recording/
│   │   ├── RecordingView.swift
│   │   ├── RecordingViewModel.swift
│   │   ├── SpeechRecognizer.swift
│   │   └── ContentView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── HistoryStore.swift
│   └── Rewrite/
│       ├── RewriteView.swift
│       └── RewriteViewModel.swift
├── Services/
│   └── AIService.swift
├── Models/
│   └── Recording.swift
└── Resources/
    └── Assets.xcassets
```

## Setup

1. Open `SpeakSmart.xcodeproj` in Xcode 15+
2. Set your OpenAI API key in the environment or directly in `AIService.swift`
3. Build and run on iOS 17+ simulator or device

## Permissions

The app requires:
- **Microphone** — To record your voice
- **Speech Recognition** — To transcribe speech to text

These permissions are declared in `Info.plist`.

## Build

```bash
# Open in Xcode
open SpeakSmart.xcodeproj

# Or build from command line
xcodebuild -project SpeakSmart.xcodeproj -scheme SpeakSmart -destination 'platform=iOS Simulator,name=iPhone 15'
```

## TODO

- [ ] Add Core Data for persistent storage
- [ ] Implement app icon and launch screen
- [ ] Add onboarding flow
- [ ] Create App Store screenshots
- [ ] Submit to App Store

## License

Copyright © 2026 App Mog. All rights reserved.
