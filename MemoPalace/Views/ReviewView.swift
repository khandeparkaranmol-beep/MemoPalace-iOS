import SwiftUI

/// Review mode — walk around and tap objects to recall concepts.
struct ReviewView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // AR Camera View (review mode)
            ARViewContainer(appState: appState, mode: .review)
                .ignoresSafeArea()

            // HUD Overlay
            VStack {
                topBar
                Spacer()
                bottomContent
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    appState.goHome()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                        Text("Close")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }

                Spacer()

                Text("Review Mode")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Text("\(appState.revealedCount)/\(appState.totalConcepts)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
            }

            // Progress dots
            HStack(spacing: 5) {
                ForEach(Array(appState.placedObjects.enumerated()), id: \.element.id) { _, placed in
                    Circle()
                        .fill(appState.revealedSet.contains(placed.id) ? Color.green : Color.white.opacity(0.2))
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(appState.revealedSet.contains(placed.id) ? Color.green : Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }

            Text("Walk to each object and tap to reveal")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [.black.opacity(0.6), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Bottom Content

    @ViewBuilder
    private var bottomContent: some View {
        // Show last revealed concept
        if let lastRevealedId = appState.revealedSet.sorted(by: { $0.uuidString < $1.uuidString }).last,
           let placed = appState.placedObjects.first(where: { $0.id == lastRevealedId }) {

            if appState.revealedCount == appState.totalConcepts {
                celebrationCard
            } else {
                revealedCard(concept: placed.concept)
            }
        }
    }

    private func revealedCard(concept: Concept) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(concept.label)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.green)

            Text(concept.originalText)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var celebrationCard: some View {
        VStack(spacing: 12) {
            Text("🎉")
                .font(.largeTitle)

            Text("Perfect Recall!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("You remembered all \(appState.totalConcepts) concepts")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))

            HStack(spacing: 10) {
                Button {
                    appState.revealedSet = []
                    appState.screen = .review
                } label: {
                    Text("Review Again")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button {
                    appState.goHome()
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}
