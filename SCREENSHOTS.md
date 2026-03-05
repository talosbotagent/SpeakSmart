# SpeakSmart - App Store Screenshots

## Required Device Sizes

### iPhone
- **6.7" (iPhone 15 Pro Max):** 1290 x 2796 px
- **6.5" (iPhone 14 Plus):** 1242 x 2688 px  
- **5.5" (iPhone 8 Plus):** 1242 x 2208 px

### iPad (if supporting)
- **12.9" (iPad Pro):** 2048 x 2732 px

## Screenshot Plan (5 screens)

### Screen 1: Hero - Recording
**View:** RecordingView with mic button prominent
**Caption:** "Tap. Speak. Done."
**Key Visual:** Big record button, clean UI

### Screen 2: Transcription
**View:** TranscriptionView with sample text
**Caption:** "Real-time speech to text"
**Key Visual:** Transcribed text displayed cleanly

### Screen 3: Tone Selection
**View:** RewriteView with tone chips visible
**Caption:** "Choose your tone"
**Key Visual:** 6 tone options (Professional, Casual, Funny, Polite, Concise, Detailed)

### Screen 4: Before/After Rewrite
**View:** RewriteView with rewritten text
**Caption:** "AI rewrites in seconds"
**Key Visual:** Original vs rewritten text comparison

### Screen 5: History
**View:** HistoryView with saved recordings
**Caption:** "Every recording, saved"
**Key Visual:** List of past recordings with search

## How to Generate

### With Xcode Simulator
```bash
# Boot simulator
xcrun simctl boot "iPhone 15 Pro Max"

# Take screenshot
xcrun simctl io booted screenshot screenshot1.png

# Or use Xcode: Product → Destination → iPhone 15 Pro Max
# Then use Cmd+S in simulator window
```

### With Xcode UI Testing (Automated)
Create `SpeakSmartUITests/ScreenshotTests.swift` that navigates to each screen and captures.

### With Third-Party Tools
- **Fastlane Snapshot** — Automated screenshot generation
- **AppScreens.com** — Add device frames and captions
- **Screenshots.pro** — Template-based screenshot builder

## Notes
- Use sample text that demonstrates value (not lorem ipsum)
- Show different tones in action
- Dark mode screenshots optional but recommended
- Ensure status bar shows good signal/battery
