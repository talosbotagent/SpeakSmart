//
//  Tone.swift
//  SpeakSmart
//

import Foundation

enum Tone: String, CaseIterable, Identifiable, Codable {
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
