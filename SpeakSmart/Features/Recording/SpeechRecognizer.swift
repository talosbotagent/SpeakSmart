//
//  SpeechRecognizer.swift
//  SpeakSmart
//

import Foundation
import Speech
import AVFoundation

@MainActor
class SpeechRecognizer: ObservableObject {
    @Published var transcribedText = ""
    @Published var errorMessage: String?
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
    }
    
    func requestAuthorization() async throws {
        // Request microphone permission
        let audioSession = AVAudioSession.sharedInstance()
        try await audioSession.setCategory(.playAndRecord, mode: .default)
        try await audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Request speech recognition permission
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume()
            }
        }
        
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            throw SpeechError.notAuthorized
        }
    }
    
    func startRecording() async throws {
        // Reset any previous task
        await stopRecording()
        
        // Request authorization if needed
        try await requestAuthorization()
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.requestCreationFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            if let result = result {
                Task { @MainActor in
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
        }
        
        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stopRecording() async {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    nonisolated func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            Task { @MainActor in
                self.errorMessage = "Speech recognition is not available"
            }
        }
    }
}

enum SpeechError: LocalizedError {
    case notAuthorized
    case requestCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition permission denied. Please enable it in Settings."
        case .requestCreationFailed:
            return "Failed to create speech recognition request."
        }
    }
}
