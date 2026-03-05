//
//  RewriteView.swift
//  SpeakSmart
//

import SwiftUI

struct RewriteView: View {
    let originalText: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RewriteViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Tone Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Tone.allCases, id: \.self) { tone in
                            ToneChip(tone: tone, isSelected: viewModel.selectedTone == tone) {
                                viewModel.selectedTone = tone
                            }
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
                    ProgressView("Rewriting with AI...")
                    Spacer()
                } else if let rewritten = viewModel.rewrittenText {
                    rewrittenView(rewritten)
                } else {
                    originalView
                }
                
                // Action Buttons
                if viewModel.rewrittenText != nil {
                    actionButtons
                }
            }
            .padding(.vertical)
            .navigationTitle("Rewrite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .sheet(isPresented: $viewModel.showAPIKeyPrompt) {
                SettingsView()
            }
        }
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
                    Text("Rewritten")
                        .font(.headline)
                    
                    Spacer()
                    
                    if let tone = viewModel.selectedTone {
                        Label(tone.rawValue, systemImage: tone.icon)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
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
        .padding(.horizontal)
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
