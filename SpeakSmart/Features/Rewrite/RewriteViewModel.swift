//
//  RewriteViewModel.swift
//  SpeakSmart
//

import Foundation

@MainActor
class RewriteViewModel: ObservableObject {
    @Published var selectedTone: Tone = .professional
    @Published var selectedFormat: Format = .notes
    @Published var rewrittenText: String?
    @Published var isRewriting = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showAPIKeyPrompt = false
    
    private let aiService = AIService.shared
    
    func rewrite(_ text: String) {
        guard !text.isEmpty else { return }
        
        // Check if API is configured
        if !aiService.isConfigured {
            showAPIKeyPrompt = true
            return
        }
        
        isRewriting = true
        rewrittenText = nil
        
        Task {
            do {
                let result = try await aiService.rewrite(
                    text: text,
                    tone: selectedTone,
                    format: selectedFormat
                )
                rewrittenText = result
            } catch AIServiceError.noAPIKey {
                showAPIKeyPrompt = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isRewriting = false
        }
    }
}
