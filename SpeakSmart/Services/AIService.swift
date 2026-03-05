//
//  AIService.swift
//  SpeakSmart
//

import Foundation

enum AIServiceError: LocalizedError {
    case invalidResponse
    case apiError(String)
    case noAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Received invalid response from AI service"
        case .apiError(let message):
            return "API Error: \(message)"
        case .noAPIKey:
            return "API key not configured"
        }
    }
}

actor AIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        // In production, load from environment or secure storage
        self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }
    
    func rewrite(text: String, tone: Tone, format: Format) async throws -> String {
        guard !apiKey.isEmpty else {
            // Fallback: simulate AI rewrite for testing
            return simulateRewrite(text: text, tone: tone, format: format)
        }
        
        let prompt = buildPrompt(text: text, tone: tone, format: format)
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful writing assistant that rewrites text in different tones and formats."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIServiceError.apiError(errorString)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIServiceError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func buildPrompt(text: String, tone: Tone, format: Format) -> String {
        """
        Rewrite the following text in a \(tone.rawValue.lowercased()) tone, suitable for a \(format.rawValue.lowercased()).
        
        Original text:
        \(text)
        
        Rewritten text:
        """
    }
    
    // Fallback simulation for testing without API key
    private func simulateRewrite(text: String, tone: Tone, format: Format) -> String {
        let prefixes: [Tone: String] = [
            .professional: "Dear Sir/Madam, ",
            .casual: "Hey, ",
            .funny: "So here's the thing... ",
            .polite: "If you don't mind, ",
            .concise: "TL;DR: ",
            .detailed: "Let me elaborate on this matter. "
        ]
        
        let suffixes: [Format: String] = [
            .email: "\n\nBest regards",
            .message: "",
            .notes: "",
            .memo: "\n\n---\nAction required",
            .social: " #SpeakSmart"
        ]
        
        let prefix = prefixes[tone] ?? ""
        let suffix = suffixes[format] ?? ""
        
        return prefix + text + suffix
    }
}
