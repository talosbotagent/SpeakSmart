import SwiftUI

struct RecordingView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @EnvironmentObject private var historyStore: HistoryStore
    @State private var showingTranscription = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Status text
                VStack(spacing: 12) {
                    if speechRecognizer.isRecording {
                        Text("Listening...")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Tap to stop")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Tap to record")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if speechRecognizer.transcript.isEmpty {
                            Text("Speak naturally, we'll handle the rest")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Tap to start new recording")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Transcription preview (when available)
                if !speechRecognizer.transcript.isEmpty && !speechRecognizer.isRecording {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Transcription")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            NavigationLink("Edit →") {
                                TranscriptionView(transcript: speechRecognizer.transcript)
                                    .environmentObject(historyStore)
                            }
                            .font(.subheadline)
                        }
                        
                        Text(speechRecognizer.transcript)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // Waveform visualization (placeholder during recording)
                if speechRecognizer.isRecording {
                    RecordingWaveform()
                        .frame(height: 60)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Record button
                RecordButton(isRecording: speechRecognizer.isRecording) {
                    toggleRecording()
                }
                
                Spacer()
                    .frame(height: 60)
            }
            .padding()
            .navigationTitle("SpeakSmart")
            .alert("Error", isPresented: .constant(speechRecognizer.errorMessage != nil)) {
                Button("OK") {
                    speechRecognizer.errorMessage = nil
                }
            } message: {
                Text(speechRecognizer.errorMessage ?? "")
            }
        }
    }
    
    private func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            Task {
                do {
                    try await speechRecognizer.startRecording()
                } catch {
                    speechRecognizer.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Record Button

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer ring pulse animation when recording
                if isRecording {
                    PulseRing()
                }
                
                // Main button
                Circle()
                    .fill(isRecording ? Color.red : Color.blue)
                    .frame(width: 80, height: 80)
                
                // Icon
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Pulse Ring Animation

struct PulseRing: View {
    @State private var animating = false
    
    var body: some View {
        Circle()
            .stroke(Color.red.opacity(0.3), lineWidth: 4)
            .frame(width: 100, height: 100)
            .scaleEffect(animating ? 1.3 : 1.0)
            .opacity(animating ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    animating = true
                }
            }
    }
}

// MARK: - Waveform Visualization

struct RecordingWaveform: View {
    @State private var phase = 0.0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<20) { index in
                WaveformBar(index: index, phase: phase)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.1).repeatForever(autoreverses: false)) {
                phase += .pi
            }
        }
    }
}

struct WaveformBar: View {
    let index: Int
    let phase: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.red)
            .frame(width: 6)
            .frame(height: barHeight)
    }
    
    private var barHeight: CGFloat {
        let base = sin(Double(index) * 0.5 + phase) * 0.5 + 0.5
        let random = Double.random(in: 0.3...1.0)
        return CGFloat(base * random * 40 + 10)
    }
}

#Preview {
    RecordingView()
}
