//
//  OnboardingView.swift
//  SpeakSmart
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            icon: "mic.circle.fill",
            title: "Speak Naturally",
            description: "Record your voice and let SpeakSmart transcribe it instantly. No typing required."
        ),
        OnboardingPage(
            icon: "wand.and.stars",
            title: "AI-Powered Rewriting",
            description: "Transform your raw speech into polished text. Choose from professional, casual, funny, and more."
        ),
        OnboardingPage(
            icon: "square.and.arrow.up",
            title: "Share Anywhere",
            description: "Export your rewritten text to email, messages, social media, or copy to clipboard."
        ),
        OnboardingPage(
            icon: "gear",
            title: "Set Up API Key",
            description: "Add your OpenAI API key in Settings to enable AI rewriting. Your key stays on your device."
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Page content
                VStack(spacing: 24) {
                    Image(systemName: pages[currentPage].icon)
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                        .symbolRenderingMode(.hierarchical)
                    
                    Text(pages[currentPage].title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(pages[currentPage].description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: currentPage == index ? 20 : 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: previousPage) {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: 56, height: 56)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                        }
                    }
                    
                    Button(action: nextPage) {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 32)
                
                // Skip button
                if currentPage < pages.count - 1 {
                    Button(action: completeOnboarding) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 16)
                }
            }
            .padding(.vertical, 40)
        }
    }
    
    private func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func previousPage() {
        withAnimation {
            currentPage -= 1
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

#Preview {
    OnboardingView()
}
