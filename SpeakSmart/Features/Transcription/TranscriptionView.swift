import SwiftUI

struct TranscriptionView: View {
    let transcript: String
    var initialTone: Tone?
    var initialFormat: Format?
    @EnvironmentObject private var historyStore: HistoryStore
    @Environment(\.dismiss) private var dismiss
    @State private var editedText: String = ""
    @State private var selectedTone: Tone = .professional
    @State private var selectedFormat: Format = .notes
    @State private var showRewriteSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Original text section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Original")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Copy") {
                            UIPasteboard.general.string = editedText
                        }
                        .font(.subheadline)
                    }
                    
                    TextEditor(text: $editedText)
                        .font(.body)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                // Tone selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tone")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Tone.allCases) { tone in
                                ToneChip(
                                    tone: tone,
                                    isSelected: selectedTone == tone
                                ) {
                                    selectedTone = tone
                                }
                                .accessibilityLabel("\(tone.rawValue) tone")
                                .accessibilityAddTraits(selectedTone == tone ? .isSelected : [])
                            }
                        }
                    }
                }
                
                // Format selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Format")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Format.allCases) { format in
                                FormatChip(
                                    format: format,
                                    isSelected: selectedFormat == format
                                ) {
                                    selectedFormat = format
                                }
                                .accessibilityLabel("\(format.rawValue) format")
                                .accessibilityAddTraits(selectedFormat == format ? .isSelected : [])
                            }
                        }
                    }
                }
                
                // Rewrite button
                Button(action: {
                    showRewriteSheet = true
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Rewrite with AI")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
                }
                .disabled(editedText.isEmpty)
                .opacity(editedText.isEmpty ? 0.6 : 1.0)
            }
            .padding()
        }
        .navigationTitle("Edit & Rewrite")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            editedText = transcript
            if let tone = initialTone {
                selectedTone = tone
            }
            if let format = initialFormat {
                selectedFormat = format
            }
        }
        .sheet(isPresented: $showRewriteSheet) {
            RewriteView(
                originalText: editedText,
                initialTone: selectedTone,
                initialFormat: selectedFormat
            ) { recording in
                historyStore.add(recording)
            }
        }
    }
}

// MARK: - Format Chip

struct FormatChip: View {
    let format: Format
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: format.icon)
                    .font(.system(size: 14))
                Text(format.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.green : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        TranscriptionView(transcript: "This is a sample transcription that the user can edit before rewriting with AI.")
    }
}
