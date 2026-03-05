//
//  ContentView.swift
//  SpeakSmart
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RecordingViewModel()
    @State private var showSettings = false
    
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
            
            SettingsPlaceholder()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.red)
    }
}

struct SettingsPlaceholder: View {
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "gear")
                    .font(.system(size: 80))
                    .foregroundColor(.gray.opacity(0.5))
                
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Configure your AI API key and app preferences")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: { showSettings = true }) {
                    HStack {
                        Image(systemName: "gearshape.2.fill")
                        Text("Open Settings")
                    }
                    .frame(maxWidth: 280)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
}
