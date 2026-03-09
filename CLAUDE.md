# CLAUDE.md — SpeakSmart

> Instructions for Claude Code when working on this project.
> You are the final quality gate before code ships.

## Your Role

You are a code reviewer and quality enforcer. Your job is to:
1. Review code for bugs, security issues, and missing error handling
2. Ensure consistency with project conventions
3. Write or improve tests to meet coverage targets
4. Handle git workflow (commit, push) when code passes review
5. Provide feedback

Do NOT refactor working code for style preferences. Only flag things that matter: bugs, security, performance, missing tests, convention violations.

## Project Overview

SpeakSmart is a native iOS app built with Swift and SwiftUI.

**Stack:** Swift + SwiftUI
**Deployment:** TestFlight → App Store (awaiting Apple Developer account)
**Status:** In development — no automated tests currently

## Project Structure

```
SpeakSmart.xcodeproj
SpeakSmart/
├── App.swift            # Entry point (@main)
├── Views/               # SwiftUI views
├── Models/              # Data models
├── Services/            # API clients, managers
└── Assets.xcassets      # Images, colours, app icon
SpeakSmartTests/         # XCTest files
```

## Conventions

- **Test framework:** XCTest
- **Commit format:** Conventional Commits (feat:, fix:, chore:, docs:, test:)
- PascalCase for types, structs, classes, enums, protocols, SwiftUI views
- camelCase for variables, functions, properties
- UPPER_SNAKE_CASE for global constants
- Prefer value types (struct) over reference types (class) where possible
- Use `@State`, `@Binding`, `@StateObject`, `@EnvironmentObject` appropriately
- No force unwrapping (`!`) in production code — use `guard let` or `if let`

## Known Technical Debt (Fix On Sight)

- **No automated tests** — XCTest files may not exist yet. Priority is adding tests for core logic
- Test coverage target: 80% on critical paths

## Security Rules

- Never hardcode API keys or secrets in Swift source
- Use Keychain for sensitive data storage, not UserDefaults
- Validate all external data before use
- HTTPS only (App Transport Security enforced by default)

## Performance Targets

- 60fps UI at all times — no frame drops during animations or scrolling
- < 3s cold start
- Lazy-load views and data where possible
- Use `@MainActor` for UI updates, avoid blocking the main thread

## When Reviewing

1. **First priority:** Check if any automated tests exist — if not, write them for core logic
2. Check for force unwraps (`!`) — replace with safe unwrapping
3. Verify no secrets hardcoded in source files
4. Ensure views are performant (no heavy computation in body)
5. Check accessibility (VoiceOver labels, Dynamic Type support)
6. Build and run tests: `xcodebuild test -scheme SpeakSmart -destination 'platform=iOS Simulator,name=iPhone 15'`
7. If everything passes: commit with conventional commit message and push

# Review Report Output

After completing a review (whether or not you make fixes), generate a review report and save it to:

```
/Users/user01/.openclaw/workspace/shared/outbox/claude-code/reviews/YYYY-MM-DD-{project-name}.md
```

Use today's date and the project name (e.g. `2026-03-07-contractscan.md`). If multiple reviews happen on the same day, append a number (e.g. `2026-03-07-contractscan-2.md`).

Create the directories if they don't exist.

## Report Format

Use this exact structure:

```markdown
# Code Review: {Project Name}
**Date:** {YYYY-MM-DD}
**Reviewer:** Claude Code
**Branch:** {current branch}

## Issues Found

### {Issue Title}
- **Severity:** Critical / High / Medium / Low
- **File:** {filepath:line}
- **What was wrong:** {One sentence describing the problem}
- **Why it matters:** {One sentence on the impact — security risk, bug, data loss, etc.}
- **Correct pattern:** {Show the right way to do it — code snippet or clear instruction}
- **Fixed:** Yes / No (if no, explain why)

{Repeat for each issue}

## Patterns to Adopt

{Distil the issues into 3-5 reusable rules. These should be general enough to apply to future work, not specific to this review. Write them as clear imperatives.}

Example:
- Always consume rate limit tokens before processing, not after — this prevents race conditions under concurrent requests.
- Never log any portion of an API key. Log only a boolean presence check: `console.log('API key present:', !!apiKey)`
- Extract shared logic into a single function when two handlers do the same thing — duplicate code means duplicate bugs.

## Test Coverage Summary

| Critical Path | Status |
|---|---|
| {path name} | {Tested / Partial / Missing} |

## Changes Made

{Brief list of what was fixed in this session, with commit hashes if applicable}
```

## Rules

- Be specific in "Correct pattern" — show code, not just advice
- Keep "Patterns to Adopt" actionable and general — these are teaching moments
- Don't pad with praise or filler — Codie needs signal, not noise
- If you didn't fix something, explain why in the issue entry (e.g. "structural change requiring Tony's approval")
