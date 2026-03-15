import SwiftUI

/// Full-screen AR placement experience.
/// Camera feed with ARKit + HUD overlay showing current concept and progress.
struct PlacementView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // AR Camera View
            ARViewContainer(appState: appState, mode: .placement)
                .ignoresSafeArea()

            // HUD Overlay
            VStack {
                topBar
                Spacer()
                bottomCard
            }
        }
    }

    // MARK: - Top Bar (progress + close)

    private var topBar: some View {
        VStack(spacing: 8) {
            // Close button row
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

                // Counter
                if case .placing(let idx) = appState.placementPhase {
                    Text("\(idx + 1) of \(appState.totalConcepts)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                }
            }

            // Progress bar
            HStack(spacing: 3) {
                ForEach(0..<appState.totalConcepts, id: \.self) { i in
                    Capsule()
                        .fill(progressColor(for: i))
                        .frame(height: 3)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func progressColor(for index: Int) -> Color {
        if case .placing(let current) = appState.placementPhase {
            if index < current { return .green }
            if index == current { return .green.opacity(0.7) }
        }
        if case .done = appState.placementPhase {
            return .green
        }
        return .white.opacity(0.2)
    }

    // MARK: - Bottom Card

    @ViewBuilder
    private var bottomCard: some View {
        if case .placing(let idx) = appState.placementPhase, idx < appState.allConcepts.count {
            let concept = appState.allConcepts[idx]
            conceptCard(concept: concept)
        } else if case .done = appState.placementPhase {
            doneCard
        }
    }

    private func conceptCard(concept: Concept) -> some View {
        VStack(spacing: 10) {
            Text(concept.label)
                .font(.headline)
                .foregroundColor(.white)

            if !concept.association.isEmpty {
                Text(concept.association.prefix(140) + (concept.association.count > 140 ? "…" : ""))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(3)
            }

            HStack(spacing: 4) {
                Image(systemName: "hand.tap")
                    .font(.caption)
                Text("Tap a surface to place")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.green)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
    }

    private var doneCard: some View {
        VStack(spacing: 12) {
            Text("✨")
                .font(.title)

            Text("All \(appState.totalConcepts) objects placed!")
                .font(.headline)
                .foregroundColor(.white)

            Text("Walk around to see them in your space")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))

            HStack(spacing: 10) {
                Button {
                    appState.startReview()
                } label: {
                    Text("Start Review")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }

                Button {
                    appState.resetPlacement()
                } label: {
                    Text("Reset")
                        .fontWeight(.medium)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
    }
}
