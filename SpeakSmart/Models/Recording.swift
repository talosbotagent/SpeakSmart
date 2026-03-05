//
//  Recording.swift
//  SpeakSmart
//

import Foundation

struct Recording: Identifiable, Codable {
    let id: UUID
    let originalText: String
    let rewrittenText: String?
    let tone: Tone?
    let format: Format
    let createdAt: Date
    let audioURL: URL?
    
    init(id: UUID = UUID(),
         originalText: String,
         rewrittenText: String? = nil,
         tone: Tone? = nil,
         format: Format = .notes,
         createdAt: Date = Date(),
         audioURL: URL? = nil) {
        self.id = id
        self.originalText = originalText
        self.rewrittenText = rewrittenText
        self.tone = tone
        self.format = format
        self.createdAt = createdAt
        self.audioURL = audioURL
    }
}

enum Tone: String, Codable, CaseIterable {
    case professional = "Professional"
    case casual = "Casual"
    case funny = "Funny"
    case polite = "Polite"
    case concise = "Concise"
    case detailed = "Detailed"
    
    var icon: String {
        switch self {
        case .professional: return "briefcase.fill"
        case .casual: return "message.fill"
        case .funny: return "face.smiling.fill"
        case .polite: return "hand.wave.fill"
        case .concise: return "text.badge.checkmark"
        case .detailed: return "text.alignleft"
        }
    }
    
    var description: String {
        switch self {
        case .professional: return "Formal and business-appropriate"
        case .casual: return "Relaxed and conversational"
        case .funny: return "Witty and lighthearted"
        case .polite: return "Respectful and courteous"
        case .concise: return "Brief and to the point"
        case .detailed: return "Comprehensive and thorough"
        }
    }
}

enum Format: String, Codable, CaseIterable {
    case email = "Email"
    case notes = "Notes"
    case message = "Message"
    case memo = "Memo"
    case social = "Social Post"
    
    var icon: String {
        switch self {
        case .email: return "envelope.fill"
        case .notes: return "doc.text.fill"
        case .message: return "bubble.left.fill"
        case .memo: return "doc.text.magnifyingglass"
        case .social: return "square.and.arrow.up.fill"
        }
    }
}
