//
//  HistoryStore.swift
//  SpeakSmart
//

import Foundation

@MainActor
class HistoryStore: ObservableObject {
    @Published var recordings: [Recording] = []
    
    private let storageKey = "speaksmart.recordings"
    
    init() {
        loadRecordings()
    }
    
    func add(_ recording: Recording) {
        recordings.insert(recording, at: 0)
        saveRecordings()
    }
    
    func delete(at offsets: IndexSet) {
        recordings.remove(atOffsets: offsets)
        saveRecordings()
    }
    
    func update(_ recording: Recording) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index] = recording
            saveRecordings()
        }
    }
    
    private func saveRecordings() {
        if let encoded = try? JSONEncoder().encode(recordings) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadRecordings() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([Recording].self, from: data) {
            recordings = decoded
        }
    }
}
