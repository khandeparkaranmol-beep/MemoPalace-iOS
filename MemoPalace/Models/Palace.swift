import Foundation

// MARK: - Palace Data Model
// Mirrors the JSON structure from the Claude API response.
// A Palace has a theme, and contains Rooms, each with Concepts.

struct Palace: Codable, Identifiable {
    let id: UUID
    let theme: String
    let ambientDescription: String?
    let rooms: [Room]

    init(id: UUID = UUID(), theme: String, ambientDescription: String? = nil, rooms: [Room]) {
        self.id = id
        self.theme = theme
        self.ambientDescription = ambientDescription
        self.rooms = rooms
    }

    /// All concepts flattened, in order
    var allConcepts: [Concept] {
        rooms.flatMap { $0.concepts }
    }
}

struct Room: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let concepts: [Concept]

    init(id: UUID = UUID(), name: String, description: String? = nil, concepts: [Concept]) {
        self.id = id
        self.name = name
        self.description = description
        self.concepts = concepts
    }
}

struct Concept: Codable, Identifiable {
    let id: UUID
    let label: String
    let originalText: String
    let association: String
    let voxels: [Voxel]
    let glowColor: String  // hex color for the primary glow light

    init(
        id: UUID = UUID(),
        label: String,
        originalText: String,
        association: String,
        voxels: [Voxel],
        glowColor: String = "#ffffff"
    ) {
        self.id = id
        self.label = label
        self.originalText = originalText
        self.association = association
        self.voxels = voxels
        self.glowColor = glowColor
    }
}

struct Voxel: Codable {
    let x: Int
    let y: Int
    let z: Int
    let color: String           // hex color
    let emissive: String?       // hex emissive color (nil = not emissive)
    let emissiveIntensity: Float?
    let animate: String?        // "pulse", "flicker", "drift", or nil
}
