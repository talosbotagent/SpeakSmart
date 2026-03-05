//
//  RecordingView.swift
//  SpeakSmart
//

import SwiftUI

struct RecordingView: View {
    @ObservedObject var viewModel: RecordingViewModel
    @State private var showRewrite = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Transcription Display
                if viewModel.transcribedText.isEmpty {
                    emptyStateView
                } else {
                    transcriptionView
                }
                
                Spacer()
                
                // Record Button
                recordButton
            }
            .padding()
            .navigationTitle("SpeakSmart")
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .sheet(isPresented: $showRewrite) {
                RewriteView(originalText: viewModel.transcribedText)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "waveform")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Tap the microphone to start")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("Speak clearly and we'll transcribe your words")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
            
            Spacer()
        }
    }
    
    private var transcriptionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transcription")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { viewModel.clearTranscription() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            ScrollView {
                Text(viewModel.transcribedText)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            Button(action: { showRewrite = true }) {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Rewrite with AI")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    private var recordButton: some View {
        Button(action: { viewModel.toggleRecording() }) {
            ZStack {
                Circle()
                    .fill(viewModel.isRecording ? Color.red : Color.red.opacity(0.8))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .stroke(viewModel.isRecording ? Color.red.opacity(0.3) : Color.clear, lineWidth: 4)
                    .frame(width: viewModel.isRecording ? 100 : 80, height: viewModel.isRecording ? 100 : 80)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isRecording)
                
                Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, 30)
    }
}

#Preview {
    RecordingView(viewModel: RecordingViewModel())
}
