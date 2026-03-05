# Build Instructions

## Option 1: Create Xcode Project (Recommended)

1. Open Xcode 15+
2. File → New → Project
3. Select "App" template
4. Configure:
   - Name: SpeakSmart
   - Team: Your Apple ID
   - Organization: AppMogLabs
   - Interface: SwiftUI
   - Language: Swift
5. Save to `projects/active/speaksmart/`

6. Replace generated files with source files from this repo:
   - Replace `SpeakSmartApp.swift`
   - Add `Models/`, `Features/` folders
   - Update `Info.plist` with permissions

## Option 2: Swift Package Manager

```bash
cd projects/active/speaksmart
swift build
```

## Required Permissions

Add to `Info.plist`:
- `NSMicrophoneUsageDescription` — for voice recording
- `NSSpeechRecognitionUsageDescription` — for transcription

## Testing

- Run on physical iOS device (speech recognition requires device)
- Simulator: Test UI only, transcription won't work

## Phase 1 Complete When

- [ ] App launches without crash
- [ ] Mic permission requested on first tap
- [ ] Speech recognized and displayed
- [ ] Transcription editable
- [ ] Tone/format selectors visible
