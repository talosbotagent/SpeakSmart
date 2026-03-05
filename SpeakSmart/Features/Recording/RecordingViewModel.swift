//
//  RecordingViewModel.swift
//  SpeakSmart
//

import Foundation
import Combine
import Speech
import AVFoundation

@MainActor
class RecordingViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let speechRecognizer = SpeechRecognizer()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        speechRecognizer.$transcribedText
            .receive(on: DispatchQueue.main)
            .assign(to: &$transcribedText)
        
        speechRecognizer.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.errorMessage = error
                self?.showError = true
                self?.isRecording = false
            }
            .store(in: &cancellables)
    }
    
    func toggleRecording() {
        Task {
            if isRecording {
                await stopRecording()
            } else {
                await startRecording()
            }
        }
    }
    
    private func startRecording() async {
        do {
            try await speechRecognizer.startRecording()
            isRecording = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func stopRecording() async {
        await speechRecognizer.stopRecording()
        isRecording = false
    }
    
    func clearTranscription() {
        transcribedText = ""
    }
}
