import SwiftUI

@main
struct SpeakSmartApp: App {
    @StateObject private var historyStore = HistoryStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                TabView {
                    RecordingView()
                        .environmentObject(historyStore)
                        .tabItem {
                            Label("Record", systemImage: "mic.fill")
                        }
                    
                    HistoryView()
                        .environmentObject(historyStore)
                        .tabItem {
                            Label("History", systemImage: "clock.arrow.circlepath")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
            } else {
                OnboardingView()
            }
        }
    }
}
