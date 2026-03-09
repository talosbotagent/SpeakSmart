import Foundation
import Speech
import AVFoundation

@MainActor
class SpeechRecognizer: NSObject, ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var errorMessage: String?
    @Published var remainingTime: TimeInterval = 30
    @Published var audioLevel: Float = 0

    static let maxDuration: TimeInterval = 30

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var accumulatedTranscript: String = ""
    private var countdownTask: Task<Void, Never>?
    private var routeChangeObserver: NSObjectProtocol?
    private var isStopping = false

    override init() {
        super.init()
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }

    func requestAudioPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func startRecording() async throws {
        reset()

        let speechAuthorized = await requestAuthorization()
        let audioAuthorized = await requestAudioPermission()

        guard speechAuthorized else {
            throw RecognitionError.speechNotAuthorized
        }

        guard audioAuthorized else {
            throw RecognitionError.audioNotAuthorized
        }

        // Configure audio session — use .default mode for broadest
        // hardware compatibility including Bluetooth HFP devices.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // If a Bluetooth input is available, explicitly select it
        if let bluetoothInput = audioSession.availableInputs?.first(where: {
            $0.portType == .bluetoothHFP
        }) {
            try? audioSession.setPreferredInput(bluetoothInput)
        }

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest else {
            throw RecognitionError.recognitionRequestFailed
        }

        recognitionRequest.shouldReportPartialResults = true
        if #available(iOS 16, *) {
            recognitionRequest.addsPunctuation = true
        }

        // Start recognition task
        startRecognitionTask()

        // Create a fresh engine so its internal audio units
        // are configured for the current hardware (built-in mic or Bluetooth HFP).
        audioEngine = AVAudioEngine()
        let inputNode = audioEngine.inputNode

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)

            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frames = buffer.frameLength
            var sum: Float = 0
            for i in 0..<Int(frames) {
                sum += channelData[i] * channelData[i]
            }
            let rms = sqrt(sum / Float(frames))
            let level = max(0, min(1, rms * 5))
            DispatchQueue.main.async {
                self?.audioLevel = level
            }
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            // Clean up tap and recognition if engine fails to start
            inputNode.removeTap(onBus: 0)
            self.recognitionRequest?.endAudio()
            self.recognitionRequest = nil
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
            try? audioSession.setActive(false)
            throw error
        }

        // Stop recording gracefully on audio device changes.
        routeChangeObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let userInfo = notification.userInfo,
                  let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

            switch reason {
            case .newDeviceAvailable, .oldDeviceUnavailable:
                let message = reason == .newDeviceAvailable
                    ? "Audio device connected. Recording stopped — tap record to continue."
                    : "Audio device disconnected. Recording stopped — tap record to continue."
                Task { @MainActor in
                    guard let self, self.isRecording else { return }
                    self.errorMessage = message
                    self.stopRecording()
                }
            default:
                break
            }
        }

        isRecording = true
        isStopping = false
        remainingTime = Self.maxDuration

        countdownTask = Task { [weak self] in
            for _ in 0..<Int(Self.maxDuration) {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, let self, self.isRecording else { return }
                self.remainingTime -= 1
                if self.remainingTime <= 0 {
                    self.stopRecording()
                    return
                }
            }
        }
    }

    private func startRecognitionTask() {
        guard let request = recognitionRequest else { return }

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let error = error {
                let nsError = error as NSError
                // Suppress errors that are expected during normal stop or transient issues
                let ignoredCodes: Set<Int> = [7, 16, 209, 216, 301, 1101, 1110]
                if ignoredCodes.contains(nsError.code) {
                    return
                }
                DispatchQueue.main.async {
                    if !self.isStopping {
                        self.errorMessage = error.localizedDescription
                    }
                    self.stopRecording()
                }
                return
            }

            if let result = result {
                DispatchQueue.main.async {
                    let currentSegment = result.bestTranscription.formattedString
                    if self.accumulatedTranscript.isEmpty {
                        self.transcript = currentSegment
                    } else {
                        self.transcript = self.accumulatedTranscript + " " + currentSegment
                    }
                }

                if result.isFinal {
                    DispatchQueue.main.async {
                        self.accumulatedTranscript = self.transcript
                        if self.isRecording, !self.isStopping, self.remainingTime > 0 {
                            self.restartRecognitionTask()
                        }
                    }
                }
            }
        }
    }

    private func restartRecognitionTask() {
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionRequest = nil
        let newRequest = SFSpeechAudioBufferRecognitionRequest()
        newRequest.shouldReportPartialResults = true
        if #available(iOS 16, *) {
            newRequest.addsPunctuation = true
        }
        recognitionRequest = newRequest

        startRecognitionTask()
    }

    func stopRecording() {
        guard isRecording, !isStopping else { return }
        isStopping = true

        countdownTask?.cancel()
        countdownTask = nil

        if let observer = routeChangeObserver {
            NotificationCenter.default.removeObserver(observer)
            routeChangeObserver = nil
        }

        // Stop audio engine first so no more buffers are produced
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        // Signal end of audio — don't cancel the task yet,
        // let it deliver the final result with the last words.
        recognitionRequest?.endAudio()

        // Give the recognizer a moment to process the final buffer,
        // then clean up.
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(800))
            self?.finalizeStop()
        }
    }

    private func finalizeStop() {
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        isRecording = false
        isStopping = false
        audioLevel = 0

        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func reset() {
        transcript = ""
        errorMessage = nil
        accumulatedTranscript = ""
        remainingTime = Self.maxDuration
    }

    enum RecognitionError: Error, LocalizedError {
        case speechNotAuthorized
        case audioNotAuthorized
        case audioNotAvailable
        case recognitionRequestFailed

        var errorDescription: String? {
            switch self {
            case .speechNotAuthorized:
                return "Speech recognition not authorized. Please enable in Settings."
            case .audioNotAuthorized:
                return "Microphone access not authorized. Please enable in Settings."
            case .audioNotAvailable:
                return "Microphone is not available. If running in the simulator, use a physical device."
            case .recognitionRequestFailed:
                return "Failed to create speech recognition request."
            }
        }
    }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    nonisolated func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // Handle availability changes
    }
}
