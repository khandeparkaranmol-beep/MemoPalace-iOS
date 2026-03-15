import SceneKit
import UIKit

/// Converts our Voxel data model into a SceneKit node.
///
/// Each voxel becomes a small cube (SCNBox). Solid voxels are batched
/// into a single flattened geometry for performance. Emissive voxels
/// get individual nodes so they can animate independently.
class VoxelEntityBuilder {

    static let voxelSize: CGFloat = 0.008  // ~8mm per voxel in AR

    /// Build a SceneKit node from a Concept's voxel data.
    /// The node is centered on X/Z but sits on the ground plane (y=0).
    static func buildNode(from concept: Concept) -> SCNNode {
        let rootNode = SCNNode()
        let voxels = concept.voxels
        guard !voxels.isEmpty else { return rootNode }

        // Calculate center offset (X/Z only — Y starts at 0)
        let avgX = Float(voxels.map { $0.x }.reduce(0, +)) / Float(voxels.count)
        let avgZ = Float(voxels.map { $0.z }.reduce(0, +)) / Float(voxels.count)

        // Separate solid vs emissive
        let solidVoxels = voxels.filter { $0.emissive == nil }
        let emissiveVoxels = voxels.filter { $0.emissive != nil }

        // ── Solid voxels: batch into groups by color for efficiency ──
        let colorGroups = Dictionary(grouping: solidVoxels) { $0.color }
        for (hexColor, group) in colorGroups {
            let color = UIColor(hex: hexColor)
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.roughness.contents = NSNumber(value: 0.3)
            material.metalness.contents = NSNumber(value: 0.15)
            material.lightingModel = .physicallyBased

            for voxel in group {
                let box = SCNBox(width: voxelSize, height: voxelSize, length: voxelSize, chamferRadius: 0)
                box.materials = [material]
                let node = SCNNode(geometry: box)
                node.position = SCNVector3(
                    (Float(voxel.x) - avgX) * Float(voxelSize),
                    Float(voxel.y) * Float(voxelSize),
                    (Float(voxel.z) - avgZ) * Float(voxelSize)
                )
                rootNode.addChildNode(node)
            }
        }

        // ── Emissive voxels: individual nodes with glow ──
        for (index, voxel) in emissiveVoxels.enumerated() {
            let box = SCNBox(width: voxelSize, height: voxelSize, length: voxelSize, chamferRadius: 0)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(hex: voxel.color)
            material.emission.contents = UIColor(hex: voxel.emissive ?? voxel.color)
            material.emission.intensity = CGFloat(voxel.emissiveIntensity ?? 1.0) * 0.5
            material.roughness.contents = NSNumber(value: 0.15)
            material.metalness.contents = NSNumber(value: 0.2)
            material.lightingModel = .physicallyBased
            box.materials = [material]

            let node = SCNNode(geometry: box)
            node.position = SCNVector3(
                (Float(voxel.x) - avgX) * Float(voxelSize),
                Float(voxel.y) * Float(voxelSize),
                (Float(voxel.z) - avgZ) * Float(voxelSize)
            )
            node.name = "emissive_\(index)"

            // Add animation
            if let animType = voxel.animate {
                addAnimation(to: node, type: animType, index: index, intensity: voxel.emissiveIntensity ?? 1.0)
            }

            rootNode.addChildNode(node)
        }

        // ── Add a small omnidirectional light matching the concept's glow ──
        let light = SCNLight()
        light.type = .omni
        light.color = UIColor(hex: concept.glowColor)
        light.intensity = 300
        light.attenuationStartDistance = 0.05
        light.attenuationEndDistance = 0.3
        let lightNode = SCNNode()
        lightNode.light = light
        // Position light at the center-top of the object
        let maxY = Float(voxels.map { $0.y }.max() ?? 10)
        lightNode.position = SCNVector3(0, maxY * Float(voxelSize) * 0.5, 0)
        rootNode.addChildNode(lightNode)

        return rootNode
    }

    /// Build a dimmed "mystery" version for review mode (before reveal).
    static func buildMysteryNode(from concept: Concept) -> SCNNode {
        let rootNode = SCNNode()
        let voxels = concept.voxels
        guard !voxels.isEmpty else { return rootNode }

        let avgX = Float(voxels.map { $0.x }.reduce(0, +)) / Float(voxels.count)
        let avgZ = Float(voxels.map { $0.z }.reduce(0, +)) / Float(voxels.count)

        // Dimmed ghost material
        let ghostMaterial = SCNMaterial()
        ghostMaterial.diffuse.contents = UIColor(white: 0.3, alpha: 0.3)
        ghostMaterial.emission.contents = UIColor(red: 1, green: 0.27, blue: 0.4, alpha: 1)
        ghostMaterial.emission.intensity = 0.2
        ghostMaterial.transparency = 0.3
        ghostMaterial.lightingModel = .physicallyBased

        for voxel in voxels {
            let box = SCNBox(width: voxelSize, height: voxelSize, length: voxelSize, chamferRadius: 0)
            box.materials = [ghostMaterial]
            let node = SCNNode(geometry: box)
            node.position = SCNVector3(
                (Float(voxel.x) - avgX) * Float(voxelSize),
                Float(voxel.y) * Float(voxelSize),
                (Float(voxel.z) - avgZ) * Float(voxelSize)
            )
            rootNode.addChildNode(node)
        }

        // Red "?" light
        let light = SCNLight()
        light.type = .omni
        light.color = UIColor.systemPink
        light.intensity = 150
        light.attenuationEndDistance = 0.2
        let lightNode = SCNNode()
        lightNode.light = light
        let maxY = Float(voxels.map { $0.y }.max() ?? 10)
        lightNode.position = SCNVector3(0, maxY * Float(voxelSize) * 0.5, 0)
        rootNode.addChildNode(lightNode)

        return rootNode
    }

    // MARK: - Animations

    private static func addAnimation(to node: SCNNode, type: String, index: Int, intensity: Float) {
        switch type {
        case "pulse":
            let duration = 2.0 + Double(index % 5) * 0.3
            let pulseUp = SCNAction.scale(to: 1.15, duration: duration / 2)
            pulseUp.timingMode = .easeInEaseOut
            let pulseDown = SCNAction.scale(to: 0.9, duration: duration / 2)
            pulseDown.timingMode = .easeInEaseOut
            node.runAction(.repeatForever(.sequence([pulseUp, pulseDown])))

        case "flicker":
            let duration = 0.1 + Double(index % 7) * 0.05
            let on = SCNAction.customAction(duration: duration) { node, _ in
                node.opacity = CGFloat.random(in: 0.5...1.0)
            }
            let off = SCNAction.customAction(duration: duration) { node, _ in
                node.opacity = CGFloat.random(in: 0.3...0.8)
            }
            node.runAction(.repeatForever(.sequence([on, off])))

        case "drift":
            let duration = 3.0 + Double(index % 4) * 0.5
            let phase = Float(index) * 0.7
            let drift = SCNAction.customAction(duration: duration) { node, elapsed in
                let t = Float(elapsed) / Float(duration)
                let baseY = node.position.y
                node.position.y = baseY + sin(t * .pi * 2 + phase) * 0.003
                node.position.x += sin(t * .pi * 2 * 1.3 + phase) * 0.0002
                node.opacity = max(0.1, CGFloat(1.0 - t * 0.5))
            }
            node.runAction(.repeatForever(drift))

        default:
            break
        }
    }
}

// MARK: - UIColor hex extension
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat((rgb & 0x0000FF)) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
