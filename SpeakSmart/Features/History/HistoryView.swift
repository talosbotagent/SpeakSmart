//
//  HistoryView.swift
//  SpeakSmart
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var historyStore: HistoryStore
    @State private var searchText = ""
    @State private var selectedRecording: Recording?
    
    var filteredRecordings: [Recording] {
        if searchText.isEmpty {
            return historyStore.recordings
        }
        return historyStore.recordings.filter {
            $0.originalText.localizedCaseInsensitiveContains(searchText) ||
            ($0.rewrittenText?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredRecordings) { recording in
                    RecordingRow(recording: recording)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRecording = recording
                        }
                        .accessibilityLabel("Recording from \(recording.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .accessibilityHint("Double tap to view details")
                }
                .onDelete(perform: deleteRecordings)
            }
            .listStyle(.plain)
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search recordings")
            .overlay {
                if historyStore.recordings.isEmpty {
                    emptyStateView
                }
            }
            .sheet(item: $selectedRecording) { recording in
                RecordingDetailView(recording: recording)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No recordings yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Your transcribed recordings will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
        }
    }
    
    private func deleteRecordings(at offsets: IndexSet) {
        let recordingsToDelete = offsets.map { filteredRecordings[$0] }
        let sourceOffsets = IndexSet(recordingsToDelete.compactMap { recording in
            historyStore.recordings.firstIndex(where: { $0.id == recording.id })
        })
        historyStore.delete(at: sourceOffsets)
    }
}

struct RecordingRow: View {
    let recording: Recording
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recording.originalText)
                .lineLimit(2)
                .font(.body)
            
            HStack {
                Label(recording.format.rawValue, systemImage: recording.format.icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let tone = recording.tone {
                    Label(tone.rawValue, systemImage: tone.icon)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(recording.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
}
