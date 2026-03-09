//
//  Format.swift
//  SpeakSmart
//

import Foundation

enum Format: String, Codable, CaseIterable, Identifiable {
    case email = "Email"
    case notes = "Notes"
    case message = "Message"
    case memo = "Memo"
    case social = "Social Post"
    
    var id: String { rawValue }
    
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
