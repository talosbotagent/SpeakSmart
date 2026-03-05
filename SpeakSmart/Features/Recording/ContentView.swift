//
//  ContentView.swift
//  SpeakSmart
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RecordingViewModel()
    
    var body: some View {
        TabView {
            RecordingView(viewModel: viewModel)
                .tabItem {
                    Label("Record", systemImage: "mic.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
        }
        .accentColor(.red)
    }
}

#Preview {
    ContentView()
}
