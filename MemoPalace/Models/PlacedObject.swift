import Foundation
import simd

/// Represents a concept that has been placed in the real world via ARKit.
struct PlacedObject: Identifiable {
    let id: UUID
    let concept: Concept
    let worldPosition: SIMD3<Float>   // ARKit world coordinates
    let worldRotation: simd_quatf     // orientation on surface
    let placedAt: Date

    /// Whether this object has been revealed in review mode
    var isRevealed: Bool = false

    init(
        id: UUID = UUID(),
        concept: Concept,
        worldPosition: SIMD3<Float>,
        worldRotation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    ) {
        self.id = id
        self.concept = concept
        self.worldPosition = worldPosition
        self.worldRotation = worldRotation
        self.placedAt = Date()
    }
}
