//
//  RewriteView.swift
//  SpeakSmart
//

import SwiftUI

struct RewriteView: View {
    let originalText: String
    var initialTone: Tone = .professional
    var initialFormat: Format = .notes
    var onSave: ((Recording) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RewriteViewModel()
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @ObservedObject private var aiService = AIService.shared
    @State private var showSaveConfirmation = false
    @State private var showCopied = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Offline banner — only show when Apple Intelligence is unavailable
                if !networkMonitor.isConnected && !aiService.appleIntelligenceAvailable {
                    HStack(spacing: 8) {
                        Image(systemName: "wifi.slash")
                        Text("No internet connection")
                        Spacer()
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.orange)
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                // AI engine indicator
                if aiService.activeEngine != .none {
                    HStack(spacing: 6) {
                        Image(systemName: aiService.appleIntelligenceAvailable ? "apple.logo" : "cloud")
                            .font(.caption2)
                        Text("Using \(aiService.activeEngine.rawValue)")
                            .font(.caption)
                        Spacer()
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                }
                // Tone Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Tone.allCases, id: \.self) { tone in
                            ToneChip(tone: tone, isSelected: viewModel.selectedTone == tone) {
                                viewModel.selectedTone = tone
                            }
                            .accessibilityLabel("\(tone.rawValue) tone")
                            .accessibilityAddTraits(viewModel.selectedTone == tone ? .isSelected : [])
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Format Selector
                Picker("Format", selection: $viewModel.selectedFormat) {
                    ForEach(Format.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Content
                if viewModel.isRewriting {
                    Spacer()
                    ProgressView("Rewriting with \(aiService.activeEngine.rawValue)...")
                        .accessibilityLabel("Rewriting text with AI, please wait")
                    Spacer()
                } else if let rewritten = viewModel.rewrittenText {
                    rewrittenView(rewritten)
                } else {
                    originalView
                    
                    // Rewrite trigger button
                    Button(action: { viewModel.rewrite(originalText) }) {
                        Label("Rewrite", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canRewrite ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!canRewrite)
                    .padding(.horizontal)
                }
                
                // Action Buttons
                if viewModel.rewrittenText != nil {
                    actionButtons
                }
            }
            .padding(.vertical)
            .navigationTitle("Output")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                viewModel.selectedTone = initialTone
                viewModel.selectedFormat = initialFormat
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .sheet(isPresented: $viewModel.showAPIKeyPrompt) {
                SettingsView(isModal: true)
            }
            .alert("Saved!", isPresented: $showSaveConfirmation) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your recording has been saved to history.")
            }
        }
    }
    
    private var canRewrite: Bool {
        // Apple Intelligence works offline; OpenAI needs network
        aiService.appleIntelligenceAvailable || networkMonitor.isConnected
    }

    private var originalView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Original")
                    .font(.headline)
                
                Text(originalText)
                    .font(.body)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding()
        }
    }
    
    private func rewrittenView(_ text: String) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Rewritten")
                            .font(.headline)
                        Label(viewModel.selectedTone.rawValue, systemImage: viewModel.selectedTone.icon)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Button(showCopied ? "Copied!" : "Copy") {
                        UIPasteboard.general.string = text
                        showCopied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showCopied = false }
                    }
                    .font(.subheadline)
                    .accessibilityLabel(showCopied ? "Text copied" : "Copy rewritten text")
                }

                Text(text)
                    .font(.body)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding()
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Button(action: { viewModel.rewrite(originalText) }) {
                    Label("Rewrite Again", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }

                ShareLink(item: viewModel.rewrittenText ?? "") {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            
            Button(action: saveRecording) {
                Label("Save to History", systemImage: "arrow.down.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    private func saveRecording() {
        let recording = Recording(
            originalText: originalText,
            rewrittenText: viewModel.rewrittenText,
            tone: viewModel.selectedTone,
            format: viewModel.selectedFormat
        )
        onSave?(recording)
        showSaveConfirmation = true
    }
}

struct ToneChip: View {
    let tone: Tone
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tone.icon)
                    .font(.system(size: 24))
                Text(tone.rawValue)
                    .font(.caption)
            }
            .frame(width: 80, height: 70)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

#Preview {
    RewriteView(originalText: "This is a sample text to rewrite.")
}
