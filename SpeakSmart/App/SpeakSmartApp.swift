import SwiftUI

@main
struct SpeakSmartApp: App {
    @StateObject private var historyStore = HistoryStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                VStack(spacing: 0) {
                    // Custom top tab bar
                    HStack(spacing: 0) {
                        TabBarButton(title: "Record", icon: "mic.fill", isSelected: selectedTab == 0) { selectedTab = 0 }
                        TabBarButton(title: "History", icon: "clock.arrow.circlepath", isSelected: selectedTab == 1) { selectedTab = 1 }
                        TabBarButton(title: "Settings", icon: "gear", isSelected: selectedTab == 2) { selectedTab = 2 }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Divider()

                    // Content
                    Group {
                        switch selectedTab {
                        case 0:
                            RecordingView()
                                .environmentObject(historyStore)
                        case 1:
                            HistoryView()
                                .environmentObject(historyStore)
                        case 2:
                            SettingsView()
                        default:
                            EmptyView()
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            } else {
                OnboardingView()
            }
        }
    }
}

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundColor(isSelected ? .blue : .secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) tab")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
