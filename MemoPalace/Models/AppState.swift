import Foundation
import SwiftUI

/// Central app state — drives navigation and AR session state.
@MainActor
class AppState: ObservableObject {

    enum Screen {
        case landing
        case loading
        case placement
        case review
    }

    enum PlacementPhase {
        case scanning       // Looking for surfaces
        case placing(Int)   // Placing concept at index
        case done           // All placed
    }

    @Published var screen: Screen = .landing
    @Published var palace: Palace? = nil
    @Published var placedObjects: [PlacedObject] = []
    @Published var placementPhase: PlacementPhase = .scanning
    @Published var revealedSet: Set<UUID> = []
    @Published var loadingMessage: String = "Generating your memory palace..."
    @Published var errorMessage: String? = nil

    var allConcepts: [Concept] {
        palace?.allConcepts ?? []
    }

    var totalConcepts: Int {
        allConcepts.count
    }

    var currentPlacementIndex: Int {
        if case .placing(let idx) = placementPhase { return idx }
        return 0
    }

    var currentConcept: Concept? {
        let idx = currentPlacementIndex
        guard idx < allConcepts.count else { return nil }
        return allConcepts[idx]
    }

    var placedCount: Int {
        placedObjects.count
    }

    var revealedCount: Int {
        revealedSet.count
    }

    // MARK: - Actions

    func startPlacement() {
        placedObjects = []
        revealedSet = []
        if allConcepts.isEmpty {
            placementPhase = .done
        } else {
            placementPhase = .placing(0)
        }
        screen = .placement
    }

    func placeObject(at position: SIMD3<Float>, rotation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)) {
        guard let concept = currentConcept else { return }

        let placed = PlacedObject(
            concept: concept,
            worldPosition: position,
            worldRotation: rotation
        )
        placedObjects.append(placed)

        let nextIndex = currentPlacementIndex + 1
        if nextIndex >= totalConcepts {
            placementPhase = .done
        } else {
            placementPhase = .placing(nextIndex)
        }
    }

    func startReview() {
        revealedSet = []
        screen = .review
    }

    func revealObject(_ id: UUID) {
        revealedSet.insert(id)
    }

    func resetPlacement() {
        placedObjects = []
        revealedSet = []
        placementPhase = .placing(0)
    }

    func goHome() {
        screen = .landing
        palace = nil
        placedObjects = []
        revealedSet = []
    }
}
