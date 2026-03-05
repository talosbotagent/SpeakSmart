//
//  SettingsView.swift
//  SpeakSmart
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var aiService = AIService.shared
    @State private var apiKey = ""
    @State private var showKey = false
    @State private var showSaved = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("AI Configuration") {
                    HStack {
                        Image(systemName: aiService.isConfigured ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundColor(aiService.isConfigured ? .green : .orange)
                        
                        Text(aiService.isConfigured ? "API Key Configured" : "API Key Required")
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
                    .disabled(apiKey.isEmpty)
                    .buttonStyle(.borderedProminent)
                    
                    if aiService.isConfigured {
                        Button(action: clearAPIKey) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Remove API Key")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                        HStack {
                            Text("Get OpenAI API Key")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Saved", isPresented: $showSaved) {
                Button("OK") {}
            } message: {
                Text("Your API key has been saved.")
            }
            .onAppear {
                // Load current key masked
                if aiService.isConfigured {
                    apiKey = "••••••••••••••••••••••••"
                }
            }
        }
    }
    
    private func saveAPIKey() {
        aiService.setAPIKey(apiKey)
        showSaved = true
        apiKey = "••••••••••••••••••••••••"
    }
    
    private func clearAPIKey() {
        aiService.clearAPIKey()
        apiKey = ""
    }
}

#Preview {
    SettingsView()
}
