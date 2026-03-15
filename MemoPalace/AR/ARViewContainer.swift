import SwiftUI
import ARKit
import SceneKit

/// SwiftUI wrapper around ARSCNView (ARKit + SceneKit).
///
/// Handles:
/// - Plane detection for surface finding
/// - Raycasting to find placement points
/// - Rendering a reticle on detected surfaces
/// - Placing voxel objects when the user taps
/// - Tap-to-reveal in review mode
struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var appState: AppState
    let mode: ARViewMode

    enum ARViewMode {
        case placement
        case review
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator
        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true
        arView.scene = SCNScene()

        // Enable environment-based lighting for realistic look
        arView.scene.lightingEnvironment.intensity = 1.0

        // Add tap gesture
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tap)

        // Start AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic

        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics.insert(.sceneDepth)
        }

        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        // Add reticle node (hidden initially)
        let reticle = createReticleNode()
        reticle.isHidden = true
        reticle.name = "reticle"
        arView.scene.rootNode.addChildNode(reticle)

        // Add already-placed objects (for review mode)
        if mode == .review {
            for placed in appState.placedObjects {
                let isRevealed = appState.revealedSet.contains(placed.id)
                let node: SCNNode
                if isRevealed {
                    node = VoxelEntityBuilder.buildNode(from: placed.concept)
                } else {
                    node = VoxelEntityBuilder.buildMysteryNode(from: placed.concept)
                }
                node.position = SCNVector3(placed.worldPosition.x, placed.worldPosition.y, placed.worldPosition.z)
                node.name = "placed_\(placed.id.uuidString)"

                // Add floating label
                let label = createLabelNode(text: isRevealed ? placed.concept.label : "?",
                                            color: isRevealed ? .systemGreen : .systemPink)
                let maxY = Float(placed.concept.voxels.map { $0.y }.max() ?? 10)
                label.position = SCNVector3(0, maxY * Float(VoxelEntityBuilder.voxelSize) + 0.02, 0)
                node.addChildNode(label)

                arView.scene.rootNode.addChildNode(node)
            }
        }

        return arView
    }

    func updateUIView(_ arView: ARSCNView, context: Context) {
        // Update reticle visibility
        let reticle = arView.scene.rootNode.childNode(withName: "reticle", recursively: false)
        if mode == .placement {
            if case .placing = appState.placementPhase {
                reticle?.isHidden = false
            } else {
                reticle?.isHidden = true
            }
        } else {
            reticle?.isHidden = true
        }

        // In review mode, update revealed objects
        if mode == .review {
            for placed in appState.placedObjects {
                let nodeName = "placed_\(placed.id.uuidString)"
                guard let existingNode = arView.scene.rootNode.childNode(withName: nodeName, recursively: false) else { continue }

                let isRevealed = appState.revealedSet.contains(placed.id)
                if isRevealed && existingNode.childNodes.first?.geometry?.materials.first?.transparency == 0.3 {
                    // Replace mystery node with real node
                    let newNode = VoxelEntityBuilder.buildNode(from: placed.concept)
                    newNode.position = existingNode.position
                    newNode.name = nodeName

                    let label = createLabelNode(text: placed.concept.label, color: .systemGreen)
                    let maxY = Float(placed.concept.voxels.map { $0.y }.max() ?? 10)
                    label.position = SCNVector3(0, maxY * Float(VoxelEntityBuilder.voxelSize) + 0.02, 0)
                    newNode.addChildNode(label)

                    // Animate reveal
                    newNode.scale = SCNVector3(0.01, 0.01, 0.01)
                    existingNode.removeFromParentNode()
                    arView.scene.rootNode.addChildNode(newNode)

                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5
                    SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
                    newNode.scale = SCNVector3(1, 1, 1)
                    SCNTransaction.commit()
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(appState: appState, mode: mode)
    }

    // MARK: - Reticle

    private func createReticleNode() -> SCNNode {
        let root = SCNNode()

        // Outer ring
        let ring = SCNTorus(ringRadius: 0.04, pipeRadius: 0.003)
        let ringMaterial = SCNMaterial()
        ringMaterial.diffuse.contents = UIColor.systemGreen.withAlphaComponent(0.8)
        ringMaterial.emission.contents = UIColor.systemGreen
        ringMaterial.emission.intensity = 0.5
        ring.materials = [ringMaterial]
        let ringNode = SCNNode(geometry: ring)
        ringNode.eulerAngles.x = -.pi / 2
        root.addChildNode(ringNode)

        // Center dot
        let dot = SCNSphere(radius: 0.005)
        let dotMaterial = SCNMaterial()
        dotMaterial.diffuse.contents = UIColor.white.withAlphaComponent(0.9)
        dotMaterial.emission.contents = UIColor.systemGreen
        dotMaterial.emission.intensity = 0.8
        dot.materials = [dotMaterial]
        let dotNode = SCNNode(geometry: dot)
        root.addChildNode(dotNode)

        // Pulse animation
        let pulseUp = SCNAction.scale(to: 1.15, duration: 0.6)
        pulseUp.timingMode = .easeInEaseOut
        let pulseDown = SCNAction.scale(to: 0.85, duration: 0.6)
        pulseDown.timingMode = .easeInEaseOut
        root.runAction(.repeatForever(.sequence([pulseUp, pulseDown])))

        return root
    }

    // MARK: - Label

    private static let labelFont = UIFont.systemFont(ofSize: 0.012, weight: .bold)

    func createLabelNode(text: String, color: UIColor) -> SCNNode {
        let textGeo = SCNText(string: text, extrusionDepth: 0.001)
        textGeo.font = UIFont.systemFont(ofSize: 0.012, weight: .bold)
        textGeo.flatness = 0.1
        textGeo.firstMaterial?.diffuse.contents = color
        textGeo.firstMaterial?.emission.contents = color
        textGeo.firstMaterial?.emission.intensity = 0.3
        textGeo.firstMaterial?.isDoubleSided = true

        let textNode = SCNNode(geometry: textGeo)
        // Center the text
        let (min, max) = textGeo.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation(
            (max.x - min.x) / 2 + min.x,
            (max.y - min.y) / 2 + min.y,
            0
        )

        // Billboard constraint — always face the camera
        let billboard = SCNBillboardConstraint()
        billboard.freeAxes = [.Y]
        textNode.constraints = [billboard]

        return textNode
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, ARSCNViewDelegate {
        let appState: AppState
        let mode: ARViewMode
        var lastRaycastResult: ARRaycastResult?

        init(appState: AppState, mode: ARViewMode) {
            self.appState = appState
            self.mode = mode
        }

        // Update reticle position every frame
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let arView = renderer as? ARSCNView else { return }
            guard mode == .placement else { return }

            // Raycast from screen center
            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
            let query = arView.raycastQuery(from: center, allowing: .estimatedPlane, alignment: .any)

            if let query = query, let result = arView.session.raycast(query).first {
                lastRaycastResult = result

                DispatchQueue.main.async {
                    let reticle = arView.scene.rootNode.childNode(withName: "reticle", recursively: false)
                    let transform = result.worldTransform
                    reticle?.position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                    reticle?.isHidden = false
                }
            }
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = gesture.view as? ARSCNView else { return }

            if mode == .placement {
                handlePlacementTap(arView: arView, gesture: gesture)
            } else {
                handleReviewTap(arView: arView, gesture: gesture)
            }
        }

        private func handlePlacementTap(arView: ARSCNView, gesture: UITapGestureRecognizer) {
            guard case .placing = appState.placementPhase else { return }

            // Use the last raycast result (center of screen)
            let point = gesture.location(in: arView)
            let query = arView.raycastQuery(from: point, allowing: .estimatedPlane, alignment: .any)

            guard let query = query, let result = arView.session.raycast(query).first else { return }

            let position = SIMD3<Float>(
                result.worldTransform.columns.3.x,
                result.worldTransform.columns.3.y,
                result.worldTransform.columns.3.z
            )

            // Build and place the voxel node
            guard let concept = appState.currentConcept else { return }
            let node = VoxelEntityBuilder.buildNode(from: concept)
            node.position = SCNVector3(position.x, position.y, position.z)

            // Add label
            let label = createLabelNode(text: concept.label, color: .systemCyan)
            let maxY = Float(concept.voxels.map { $0.y }.max() ?? 10)
            label.position = SCNVector3(0, maxY * Float(VoxelEntityBuilder.voxelSize) + 0.02, 0)
            node.addChildNode(label)

            // Spawn animation — scale from 0 to 1
            node.scale = SCNVector3(0.01, 0.01, 0.01)
            arView.scene.rootNode.addChildNode(node)

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.4
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
            node.scale = SCNVector3(1, 1, 1)
            SCNTransaction.commit()

            // Gentle idle rotation
            let rotate = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 12)
            node.runAction(.repeatForever(rotate))

            // Update state
            let placedId = UUID()
            node.name = "placed_\(placedId.uuidString)"

            DispatchQueue.main.async {
                self.appState.placeObject(at: position)
            }

            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }

        private func handleReviewTap(arView: ARSCNView, gesture: UITapGestureRecognizer) {
            let point = gesture.location(in: arView)
            let hits = arView.hitTest(point, options: [
                .searchMode: SCNHitTestSearchMode.all.rawValue,
                .boundingBoxOnly: true
            ])

            // Find the first placed object that was tapped
            for hit in hits {
                var node = hit.node
                // Walk up to find the "placed_" parent
                while let parent = node.parent {
                    if let name = node.name, name.hasPrefix("placed_") {
                        let uuidStr = String(name.dropFirst("placed_".count))
                        if let uuid = UUID(uuidString: uuidStr) {
                            DispatchQueue.main.async {
                                self.appState.revealObject(uuid)
                            }
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            return
                        }
                    }
                    node = parent
                }
            }
        }

        private func createLabelNode(text: String, color: UIColor) -> SCNNode {
            let textGeo = SCNText(string: text, extrusionDepth: 0.001)
            textGeo.font = UIFont.systemFont(ofSize: 0.012, weight: .bold)
            textGeo.flatness = 0.1
            textGeo.firstMaterial?.diffuse.contents = color
            textGeo.firstMaterial?.emission.contents = color
            textGeo.firstMaterial?.emission.intensity = 0.3
            textGeo.firstMaterial?.isDoubleSided = true

            let textNode = SCNNode(geometry: textGeo)
            let (min, max) = textGeo.boundingBox
            textNode.pivot = SCNMatrix4MakeTranslation(
                (max.x - min.x) / 2 + min.x,
                (max.y - min.y) / 2 + min.y,
                0
            )
            let billboard = SCNBillboardConstraint()
            billboard.freeAxes = [.Y]
            textNode.constraints = [billboard]
            return textNode
        }

        // Visualize detected planes (subtle mesh)
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

            let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width),
                                height: CGFloat(planeAnchor.planeExtent.height))
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemGreen.withAlphaComponent(0.08)
            plane.materials = [material]

            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            node.addChildNode(planeNode)
        }

        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            guard let planeNode = node.childNodes.first,
                  let plane = planeNode.geometry as? SCNPlane else { return }

            plane.width = CGFloat(planeAnchor.planeExtent.width)
            plane.height = CGFloat(planeAnchor.planeExtent.height)
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        }
    }
}
