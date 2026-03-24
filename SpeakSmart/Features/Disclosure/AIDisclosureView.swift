//
//  AIDisclosureView.swift
//  SpeakSmart
//
//  AI Processing disclosure required by App Store Guidelines 5.1.1(i) & 5.1.2(i)
//

import SwiftUI

struct AIDisclosureView: View {
    @AppStorage("hasAcceptedAIDisclosure") private var hasAcceptedAIDisclosure = false
    @Environment(\.dismiss) private var dismiss
    var isReviewMode: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Icon
                    HStack {
                        Spacer()
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue.gradient)
                            .symbolRenderingMode(.hierarchical)
                            .accessibilityLabel("Privacy shield icon")
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    // Title
                    Text("AI Processing Notice")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .accessibilityAddTraits(.isHeader)
                    
                    // Intro text
                    Text("SpeakSmart uses AI to enhance your voice recordings. Depending on your device:")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    // Apple Intelligence section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "apple.logo")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: 24)
                                .accessibilityHidden(true)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Apple Intelligence devices")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("All processing happens on your device. Your data never leaves your phone.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .accessibilityElement(children: .combine)
                    
                    // OpenAI section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "cloud")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                                .accessibilityHidden(true)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Other devices")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("When you provide your OpenAI API key, voice data is sent to OpenAI for processing. This uses YOUR OpenAI account and is subject to OpenAI's privacy policy.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .accessibilityElement(children: .combine)
                    
                    // Data sharing details
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Data sent")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Voice recordings, transcription text")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                        }
                        
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recipient")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("OpenAI (only when using your API key)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "building.2")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isReviewMode {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    // Continue button
                    if !isReviewMode {
                        Button(action: acceptDisclosure) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .accessibilityLabel("Continue and accept AI processing notice")
                    }
                    
                    // Learn More button
                    if let url = URL(string: "https://openai.com/privacy") {
                        Link(destination: url) {
                            Text("Learn More")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .accessibilityLabel("Learn more about OpenAI's privacy policy")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(.regularMaterial)
            }
        }
    }
    
    private func acceptDisclosure() {
        withAnimation {
            hasAcceptedAIDisclosure = true
        }
    }
}

#Preview("First Time") {
    AIDisclosureView()
}

#Preview("Review Mode") {
    AIDisclosureView(isReviewMode: true)
}
