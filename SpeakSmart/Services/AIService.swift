//
//  AIService.swift
//  SpeakSmart
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

enum AIEngine: String {
    case appleIntelligence = "Apple Intelligence"
    case openAI = "OpenAI"
    case none = "Not Configured"
}

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
    @Published var activeEngine: AIEngine = .none
    @Published var appleIntelligenceAvailable = false

    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private var apiKey: String = ""
    var hasAPIKey: Bool { !apiKey.isEmpty }

    private static let keychainKey = "com.speaksmart.openai-api-key"
    private static let legacyDefaultsKey = "openai_api_key"

    static let shared = AIService()

    init() {
        migrateFromUserDefaultsIfNeeded()
        loadAPIKey()
        updateActiveEngine()
    }

    private func migrateFromUserDefaultsIfNeeded() {
        let defaults = UserDefaults.standard
        guard let legacyKey = defaults.string(forKey: Self.legacyDefaultsKey), !legacyKey.isEmpty else {
            return
        }
        _ = KeychainHelper.save(legacyKey, forKey: Self.keychainKey)
        defaults.removeObject(forKey: Self.legacyDefaultsKey)
    }

    func loadAPIKey() {
        // Try environment first (for development)
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            apiKey = envKey
            isConfigured = true
            return
        }

        // Then try Keychain
        if let storedKey = KeychainHelper.loadString(forKey: Self.keychainKey), !storedKey.isEmpty {
            apiKey = storedKey
            isConfigured = true
        }
    }

    func setAPIKey(_ key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        apiKey = trimmed
        _ = KeychainHelper.save(trimmed, forKey: Self.keychainKey)
        updateActiveEngine()
    }

    func clearAPIKey() {
        apiKey = ""
        KeychainHelper.delete(forKey: Self.keychainKey)
        updateActiveEngine()
    }

    func updateActiveEngine() {
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            let model = SystemLanguageModel.default
            appleIntelligenceAvailable = model.isAvailable
            if model.isAvailable {
                activeEngine = .appleIntelligence
                isConfigured = true
                return
            }
        }
        #endif
        if !apiKey.isEmpty {
            activeEngine = .openAI
            isConfigured = true
        } else {
            activeEngine = .none
            isConfigured = false
        }
    }

    func rewrite(text: String, tone: Tone, format: Format) async throws -> String {
        // Try Apple Intelligence first (on-device, free, works offline)
        #if canImport(FoundationModels)
        if #available(iOS 26, *), appleIntelligenceAvailable {
            do {
                return try await rewriteWithAppleIntelligence(text: text, tone: tone, format: format)
            } catch {
                // Fall through to OpenAI if Apple Intelligence fails
                if !apiKey.isEmpty {
                    // Log but continue to fallback
                } else {
                    throw AIServiceError.apiError("Apple Intelligence failed: \(error.localizedDescription)")
                }
            }
        }
        #endif

        // Fall back to OpenAI
        guard !apiKey.isEmpty else {
            #if DEBUG
            try await Task.sleep(nanoseconds: 1_000_000_000)
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
    
    #if canImport(FoundationModels)
    @available(iOS 26, *)
    private func rewriteWithAppleIntelligence(text: String, tone: Tone, format: Format) async throws -> String {
        let session = LanguageModelSession(
            instructions: "You are a helpful writing assistant that rewrites text in different tones and formats. Respond only with the rewritten text, no explanations or preamble."
        )
        let prompt = buildPrompt(text: text, tone: tone, format: format)
        let response = try await session.respond(to: prompt)
        return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    #endif

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
