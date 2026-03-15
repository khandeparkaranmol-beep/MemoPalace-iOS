import SwiftUI

struct LandingView: View {
    @EnvironmentObject var appState: AppState
    @State private var conceptsText: String = ""
    @State private var isGenerating = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer().frame(height: 40)

                // Title
                VStack(spacing: 8) {
                    Text("MemoPalace")
                        .font(.system(size: 36, weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Turn any concept into a memory palace\nyou walk through in AR")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                // Text input
                VStack(alignment: .leading, spacing: 8) {
                    Text("PASTE YOUR CONCEPTS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .tracking(0.5)

                    TextEditor(text: $conceptsText)
                        .frame(minHeight: 160)
                        .padding(12)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                }

                // Generate button
                Button {
                    generatePalace()
                } label: {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        }
                        Text(isGenerating ? "Generating..." : "Generate Memory Palace")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(conceptsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
                .opacity(conceptsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)

                // Demo button
                Button {
                    loadDemo()
                } label: {
                    Text("Try demo: Krebs Cycle")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .underline()
                }

                // Error
                if let error = appState.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .background(Color.black)
    }

    private func generatePalace() {
        isGenerating = true
        appState.screen = .loading

        Task {
            do {
                let palace = try await ClaudeAPIService.shared.generate(concepts: conceptsText)
                appState.palace = palace
                appState.startPlacement()
            } catch {
                appState.errorMessage = error.localizedDescription
                appState.screen = .landing
            }
            isGenerating = false
        }
    }

    private func loadDemo() {
        appState.palace = MockData.krebsCyclePalace
        appState.startPlacement()
    }
}
