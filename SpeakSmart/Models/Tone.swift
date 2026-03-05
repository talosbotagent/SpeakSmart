import Foundation

enum Tone: String, CaseIterable, Identifiable {
    case professional = "Professional"
    case casual = "Casual"
    case funny = "Funny"
    case polite = "Polite"
    case concise = "Concise"
    case detailed = "Detailed"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .professional: return "briefcase"
        case .casual: return "person"
        case .funny: return "face.smiling"
        case .polite: return "hand.thumbsup"
        case .concise: return "arrow.down.circle"
        case .detailed: return "text.alignleft"
        }
    }
}

enum Format: String, CaseIterable, Identifiable {
    case email = "Email"
    case notes = "Notes"
    case message = "Message"
    case memo = "Memo"
    case social = "Social Post"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .email: return "envelope"
        case .notes: return "note.text"
        case .message: return "bubble.left"
        case .memo: return "doc.text"
        case .social: return "shareplay"
        }
    }
}

struct Recording: Identifiable {
    let id: UUID
    let originalText: String
    let rewrittenText: String?
    let tone: Tone?
    let format: Format
    let createdAt: Date
    let audioURL: URL?
    
    init(id: UUID = UUID(), originalText: String, rewrittenText: String? = nil, tone: Tone? = nil, format: Format = .notes, createdAt: Date = Date(), audioURL: URL? = nil) {
        self.id = id
        self.originalText = originalText
        self.rewrittenText = rewrittenText
        self.tone = tone
        self.format = format
        self.createdAt = createdAt
        self.audioURL = audioURL
    }
}
