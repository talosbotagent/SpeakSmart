# SpeakSmart

AI Voice Writer iOS App — Transform spoken words into perfectly formatted text with AI-powered tone control.

## Features

- **Voice-to-Text** — Real-time dictation with high accuracy
- **Tone Rewriting** — Professional, Casual, Funny, Polite, Concise, Detailed
- **Format Options** — Email, Notes, Message, Memo, Social Post
- **History** — Save and organize previous recordings
- **Export** — Share to any app, copy to clipboard

## Tech Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Speech Recognition:** Speech framework (Apple native)
- **AI:** OpenAI GPT-4o / Gemini API for rewriting
- **Storage:** SwiftData

## Project Structure

```
SpeakSmart/
├── App/
│   ├── SpeakSmartApp.swift      # App entry point
│   └── Info.plist               # Permissions
├── Features/
│   ├── Recording/               # Voice recording & transcription
│   ├── Transcription/           # Edit & tone selection
│   ├── Rewrite/                 # AI rewriting (Phase 2)
│   ├── History/                 # Saved recordings (Phase 3)
│   └── Export/                  # Share & copy (Phase 3)
├── Models/
│   └── Tone.swift               # Data models
└── Services/
    ├── AIService.swift          # AI integration (Phase 2)
    └── StorageService.swift     # Persistence (Phase 3)
```

## Setup

1. Open project in Xcode 15+
2. Set your development team
3. Build and run on iOS 17+ device or simulator
4. Grant microphone and speech recognition permissions when prompted

## API Keys (Phase 2)

Add to `Config.xcconfig` (gitignored):
```
OPENAI_API_KEY = your_key_here
```

Or set in Xcode environment variables.

## Phases

- **Phase 1:** Recording + Transcription ✅
- **Phase 2:** AI Rewriting
- **Phase 3:** History & Export
- **Phase 4:** Polish & App Store

## Deadline

March 15, 2026 — App Store submission

## License

Proprietary — App Mog Labs
