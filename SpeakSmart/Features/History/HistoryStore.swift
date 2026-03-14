//
//  HistoryStore.swift
//  SpeakSmart
//

import Foundation

@MainActor
class HistoryStore: ObservableObject {
    @Published var recordings: [Recording] = []

    private static var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("speaksmart_recordings.json")
    }

    /// Legacy UserDefaults key — used only for one-time migration.
    private static let legacyDefaultsKey = "speaksmart.recordings"

    init() {
        migrateFromUserDefaultsIfNeeded()
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
        do {
            let data = try JSONEncoder().encode(recordings)
            try data.write(to: Self.fileURL, options: .atomic)
        } catch {
            print("[HistoryStore] Failed to save recordings: \(error)")
        }
    }

    private func loadRecordings() {
        let url = Self.fileURL
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            recordings = try JSONDecoder().decode([Recording].self, from: data)
        } catch {
            print("[HistoryStore] Failed to load recordings: \(error)")
        }
    }

    /// Migrate existing data from UserDefaults to file storage (one-time).
    private func migrateFromUserDefaultsIfNeeded() {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: Self.legacyDefaultsKey) else { return }
        // Only migrate if the file doesn't exist yet
        guard !FileManager.default.fileExists(atPath: Self.fileURL.path) else {
            defaults.removeObject(forKey: Self.legacyDefaultsKey)
            return
        }
        do {
            try data.write(to: Self.fileURL, options: .atomic)
            defaults.removeObject(forKey: Self.legacyDefaultsKey)
        } catch {
            print("[HistoryStore] Migration from UserDefaults failed: \(error)")
        }
    }
}
