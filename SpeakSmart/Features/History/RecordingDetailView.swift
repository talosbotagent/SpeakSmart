//
//  RecordingDetailView.swift
//  SpeakSmart
//

import SwiftUI

struct RecordingDetailView: View {
    let recording: Recording
    @Environment(\.dismiss) private var dismiss
    @State private var showCopyConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Metadata
                    metadataSection
                    
                    Divider()
                    
                    // Original Text
                    textSection(
                        title: "Original",
                        text: recording.originalText,
                        backgroundColor: Color(.systemGray6)
                    )
                    
                    // Rewritten Text (if available)
                    if let rewritten = recording.rewrittenText {
                        Divider()
                        
                        textSection(
                            title: "Rewritten",
                            text: rewritten,
                            backgroundColor: Color.blue.opacity(0.1)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Recording Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: copyOriginal) {
                            Label("Copy Original", systemImage: "doc.on.doc")
                        }
                        
                        if recording.rewrittenText != nil {
                            Button(action: copyRewritten) {
                                Label("Copy Rewritten", systemImage: "doc.on.doc.fill")
                            }
                        }
                        
                        ShareLink(item: shareText) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Copied!", isPresented: $showCopyConfirmation) {
                Button("OK") {}
            } message: {
                Text("Text copied to clipboard.")
            }
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(recording.format.rawValue, systemImage: recording.format.icon)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let tone = recording.tone {
                    Label(tone.rawValue, systemImage: tone.icon)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            Text(recording.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(recording.createdAt, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func textSection(title: String, text: String, backgroundColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    UIPasteboard.general.string = text
                    showCopyConfirmation = true
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
            }
            
            Text(text)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(backgroundColor)
                .cornerRadius(12)
        }
    }
    
    private var shareText: String {
        if let rewritten = recording.rewrittenText {
            return """\nOriginal:\n\(recording.originalText)\n\nRewritten:\n\(rewritten)\n"""
        }
        return recording.originalText
    }
    
    private func copyOriginal() {
        UIPasteboard.general.string = recording.originalText
        showCopyConfirmation = true
    }
    
    private func copyRewritten() {
        UIPasteboard.general.string = recording.rewrittenText
        showCopyConfirmation = true
    }
}

#Preview {
    RecordingDetailView(recording: Recording(
        originalText: "This is the original transcribed text from the recording.",
        rewrittenText: "Here is the professionally rewritten version of the text.",
        tone: .professional,
        format: .email
    ))
}
