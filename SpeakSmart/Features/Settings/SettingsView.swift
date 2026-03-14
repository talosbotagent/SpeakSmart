//
//  SettingsView.swift
//  SpeakSmart
//

import SwiftUI

struct SettingsView: View {
    var isModal: Bool = false
    @ObservedObject private var aiService = AIService.shared
    @State private var apiKey = ""
    @State private var showKey = false
    @State private var showSaved = false
    @State private var keyIsPlaceholder = false
    private let placeholderMask = String(repeating: "\u{2022}", count: 24)
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("AI Engine") {
                    HStack {
                        Image(systemName: aiService.appleIntelligenceAvailable ? "apple.logo" : "cloud")
                            .foregroundColor(aiService.isConfigured ? .green : .orange)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Active: \(aiService.activeEngine.rawValue)")
                                .fontWeight(.medium)
                            if aiService.appleIntelligenceAvailable {
                                Text("On-device • No API key needed • Works offline")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    if aiService.appleIntelligenceAvailable && !aiService.isConfigured {
                        // Apple Intelligence only — no OpenAI fallback configured
                    } else if !aiService.appleIntelligenceAvailable {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("Apple Intelligence not available on this device. OpenAI API key required.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("OpenAI API Key\(aiService.appleIntelligenceAvailable ? " (Fallback)" : "")") {
                    HStack {
                        Image(systemName: !apiKey.isEmpty && !keyIsPlaceholder || aiService.isConfigured && aiService.activeEngine == .openAI ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(!apiKey.isEmpty || aiService.activeEngine == .openAI ? .green : .secondary)

                        Text(aiService.activeEngine == .openAI ? "API Key Configured" : aiService.appleIntelligenceAvailable ? "Optional — for higher-quality results" : "API Key Required")
                            .fontWeight(.medium)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("OpenAI API Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            if showKey {
                                TextField("sk-...", text: $apiKey)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("sk-...", text: $apiKey)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .accessibilityLabel("OpenAI API key")
                            }
                            
                            Button(action: { showKey.toggle() }) {
                                Image(systemName: showKey ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: saveAPIKey) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save API Key")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(apiKey.isEmpty || keyIsPlaceholder)
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Save API key")
                    
                    if aiService.hasAPIKey {
                        Button(action: clearAPIKey) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Remove API Key")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.red)
                        .accessibilityLabel("Remove API key")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    if let url = URL(string: "https://platform.openai.com/api-keys") {
                        Link(destination: url) {
                            HStack {
                                Text("Get OpenAI API Key")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("How to use") {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Record your voice using the microphone", systemImage: "1.circle.fill")
                        Label("Review the transcription", systemImage: "2.circle.fill")
                        Label("Select a tone and format", systemImage: "3.circle.fill")
                        Label("Tap 'Rewrite with AI' to transform your text", systemImage: "4.circle.fill")
                        Label("Share or save your rewritten text", systemImage: "5.circle.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isModal {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                }
            }
            .alert("Saved", isPresented: $showSaved) {
                Button("OK") {}
            } message: {
                Text("Your API key has been saved.")
            }
            .onAppear {
                if aiService.hasAPIKey {
                    apiKey = placeholderMask
                    keyIsPlaceholder = true
                }
            }
            .onChange(of: apiKey) {
                if keyIsPlaceholder && apiKey != placeholderMask {
                    keyIsPlaceholder = false
                }
            }
        }
    }
    
    private func saveAPIKey() {
        guard !keyIsPlaceholder else { return }
        aiService.setAPIKey(apiKey)
        showSaved = true
        apiKey = placeholderMask
        keyIsPlaceholder = true
    }
    
    private func clearAPIKey() {
        aiService.clearAPIKey()
        apiKey = ""
    }
}

#Preview {
    SettingsView()
}
