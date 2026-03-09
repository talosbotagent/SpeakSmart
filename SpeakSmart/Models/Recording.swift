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
