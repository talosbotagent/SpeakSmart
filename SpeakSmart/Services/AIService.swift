//
//  AIService.swift
//  SpeakSmart
//

import Foundation

enum AIServiceError: LocalizedError {
    case invalidResponse
    case apiError(String)
    case noAPIKey
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Received invalid response from AI service"
        case .apiError(let message):
            return "API Error: \(message)"
        case .noAPIKey:
            return "OpenAI API key not configured. Add it in Settings."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

@MainActor
class AIService: ObservableObject {
    @Published var isConfigured = false
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private var apiKey: String = ""
    
    static let shared = AIService()
    
    init() {
        loadAPIKey()
    }
    
    func loadAPIKey() {
        // Try environment first (for development)
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            apiKey = envKey
            isConfigured = true
            return
        }
        
        // Then try UserDefaults (for production - user enters in app)
        if let storedKey = UserDefaults.standard.string(forKey: "openai_api_key"), !storedKey.isEmpty {
            apiKey = storedKey
            isConfigured = true
        }
    }
    
    func setAPIKey(_ key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        apiKey = trimmed
        UserDefaults.standard.set(trimmed, forKey: "openai_api_key")
        isConfigured = !trimmed.isEmpty
    }
    
    func clearAPIKey() {
        apiKey = ""
        UserDefaults.standard.removeObject(forKey: "openai_api_key")
        isConfigured = false
    }
    
    func rewrite(text: String, tone: Tone, format: Format) async throws -> String {
        guard !apiKey.isEmpty else {
            // Fallback: simulate AI rewrite for testing/demo
            #if DEBUG
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay for realism
            return simulateRewrite(text: text, tone: tone, format: format)
            #else
            throw AIServiceError.noAPIKey
            #endif
        }
        
        let prompt = buildPrompt(text: text, tone: tone, format: format)
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful writing assistant that rewrites text in different tones and formats. Respond only with the rewritten text, no explanations."],
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
        request.timeoutInterval = 30
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIServiceError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorString = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
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
            
        } catch let error as AIServiceError {
            throw error
        } catch {
            throw AIServiceError.networkError(error)
        }
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
            .casual: "Hey! ",
            .funny: "So here's the thing... ",
            .polite: "If you don't mind, ",
            .concise: "TL;DR: ",
            .detailed: "Let me elaborate on this matter in detail. "
        ]
        
        let suffixes: [Format: String] = [
            .email: "\n\nBest regards,\n[Your Name]",
            .message: "",
            .notes: "\n\n---\nNote: Key points captured",
            .memo: "\n\n---\nACTION REQUIRED: Please review and respond",
            .social: " #SpeakSmart #AIWriting"
        ]
        
        let prefix = prefixes[tone] ?? ""
        let suffix = suffixes[format] ?? ""
        
        // Add some AI-like variation based on tone
        var bodyText = text
        switch tone {
        case .concise:
            // Truncate to first sentence for concise
            if let firstSentence = text.split(separator: ".").first {
                bodyText = String(firstSentence) + "."
            }
        case .detailed:
            bodyText = text + " This is an important consideration that requires careful attention and thoughtful analysis to ensure the best possible outcome."
        case .funny:
            bodyText = text + " (And yes, I'm totally serious about this... or am I? 😉)"
        default:
            break
        }
        
        return prefix + bodyText + suffix
    }
}
