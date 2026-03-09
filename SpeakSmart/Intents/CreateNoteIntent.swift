//
//  CreateNoteIntent.swift
//  SpeakSmart
//

import AppIntents

// MARK: - Notification Name

extension Notification.Name {
    static let startRecordingFromIntent = Notification.Name("startRecordingFromIntent")
}

// MARK: - Tone AppEnum

enum ToneEntity: String, AppEnum {
    case professional = "Professional"
    case casual = "Casual"
    case funny = "Funny"
    case polite = "Polite"
    case concise = "Concise"
    case detailed = "Detailed"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Tone")

    static var caseDisplayRepresentations: [ToneEntity: DisplayRepresentation] = [
        .professional: "Professional",
        .casual: "Casual",
        .funny: "Funny",
        .polite: "Polite",
        .concise: "Concise",
        .detailed: "Detailed"
    ]

    var toTone: Tone {
        switch self {
        case .professional: return .professional
        case .casual: return .casual
        case .funny: return .funny
        case .polite: return .polite
        case .concise: return .concise
        case .detailed: return .detailed
        }
    }
}

// MARK: - Format AppEnum

enum FormatEntity: String, AppEnum {
    case email = "Email"
    case notes = "Notes"
    case message = "Message"
    case memo = "Memo"
    case social = "Social Post"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Format")

    static var caseDisplayRepresentations: [FormatEntity: DisplayRepresentation] = [
        .email: "Email",
        .notes: "Notes",
        .message: "Message",
        .memo: "Memo",
        .social: "Social Post"
    ]

    var toFormat: Format {
        switch self {
        case .email: return .email
        case .notes: return .notes
        case .message: return .message
        case .memo: return .memo
        case .social: return .social
        }
    }
}

// MARK: - Create Note Intent

struct CreateNoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Smart Note"
    static var description = IntentDescription("Record and rewrite a note with AI")
    static var openAppWhenRun = true

    @Parameter(title: "Tone", default: .professional)
    var tone: ToneEntity

    @Parameter(title: "Format", default: .notes)
    var format: FormatEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(
            name: .startRecordingFromIntent,
            object: nil,
            userInfo: ["tone": tone.toTone, "format": format.toFormat]
        )
        return .result()
    }
}

// MARK: - App Shortcuts Provider

struct SpeakSmartShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateNoteIntent(),
            phrases: [
                "Create a smart note in \(.applicationName)",
                "Record a note in \(.applicationName)",
                "Start recording in \(.applicationName)"
            ],
            shortTitle: "Create Smart Note",
            systemImageName: "mic.fill"
        )
    }
}
