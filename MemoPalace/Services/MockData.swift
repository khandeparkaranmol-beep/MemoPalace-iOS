import Foundation

/// Mock Krebs cycle palace data for testing without an API key.
/// Matches the same voxel format as the web version.
enum MockData {

    // MARK: - Helpers

    static func fillSphere(cx: Int, cy: Int, cz: Int, r: Int, color: String, emissive: String? = nil, emissiveIntensity: Float? = nil, animate: String? = nil) -> [Voxel] {
        var voxels: [Voxel] = []
        for x in -r...r {
            for y in -r...r {
                for z in -r...r {
                    if x*x + y*y + z*z <= r*r {
                        voxels.append(Voxel(x: cx+x, y: cy+y, z: cz+z, color: color, emissive: emissive, emissiveIntensity: emissiveIntensity, animate: animate))
                    }
                }
            }
        }
        return voxels
    }

    static func shellSphere(cx: Int, cy: Int, cz: Int, r: Int, color: String) -> [Voxel] {
        var voxels: [Voxel] = []
        let innerR = Float(r) - 1.4
        for x in -r...r {
            for y in -r...r {
                for z in -r...r {
                    let d2 = Float(x*x + y*y + z*z)
                    if d2 <= Float(r*r) && d2 > innerR * innerR {
                        voxels.append(Voxel(x: cx+x, y: cy+y, z: cz+z, color: color, emissive: nil, emissiveIntensity: nil, animate: nil))
                    }
                }
            }
        }
        return voxels
    }

    static func column(cx: Int, cy: Int, cz: Int, height: Int, color: String) -> [Voxel] {
        (0..<height).map { i in
            Voxel(x: cx, y: cy+i, z: cz, color: color, emissive: nil, emissiveIntensity: nil, animate: nil)
        }
    }

    static func fillBox(x1: Int, y1: Int, z1: Int, x2: Int, y2: Int, z2: Int, color: String, emissive: String? = nil, emissiveIntensity: Float? = nil, animate: String? = nil) -> [Voxel] {
        var voxels: [Voxel] = []
        for x in min(x1,x2)...max(x1,x2) {
            for y in min(y1,y2)...max(y1,y2) {
                for z in min(z1,z2)...max(z1,z2) {
                    voxels.append(Voxel(x: x, y: y, z: z, color: color, emissive: emissive, emissiveIntensity: emissiveIntensity, animate: animate))
                }
            }
        }
        return voxels
    }

    // MARK: - Krebs Cycle Palace

    static var krebsCyclePalace: Palace {
        Palace(
            theme: "The Krebs Cycle Journey",
            ambientDescription: "Place these objects around your room to trace the eight steps of cellular energy production.",
            rooms: [
                Room(name: "Steps 1-4", concepts: [

                    // 1. Citrate — Orange
                    Concept(
                        label: "Citrate",
                        originalText: "Acetyl-CoA + Oxaloacetate → Citrate (citrate synthase)",
                        association: "A massive glowing ORANGE — citrus fruit. Citrus → Citrate.",
                        voxels: {
                            var v = shellSphere(cx: 0, cy: 7, cz: 0, r: 6, color: "#FF8C00")
                            v += fillSphere(cx: 0, cy: 7, cz: 0, r: 4, color: "#E07700")
                            // Stem
                            v += column(cx: 0, cy: 13, cz: 0, height: 3, color: "#5C3320")
                            // Leaves
                            v.append(Voxel(x: 1, y: 15, z: 0, color: "#228B22", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: 2, y: 15, z: 0, color: "#33AA3A", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: 3, y: 16, z: 0, color: "#44CC4D", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: -1, y: 15, z: 0, color: "#228B22", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: -2, y: 16, z: 0, color: "#33AA3A", emissive: nil, emissiveIntensity: nil, animate: nil))
                            // Glowing core
                            v.append(Voxel(x: 0, y: 7, z: 0, color: "#FFCC00", emissive: "#FFAA00", emissiveIntensity: 3.5, animate: "pulse"))
                            v.append(Voxel(x: 1, y: 7, z: 0, color: "#FFBB00", emissive: "#FF9900", emissiveIntensity: 3.0, animate: "pulse"))
                            v.append(Voxel(x: -1, y: 7, z: 0, color: "#FFBB00", emissive: "#FF9900", emissiveIntensity: 3.0, animate: "pulse"))
                            v.append(Voxel(x: 0, y: 8, z: 0, color: "#FFCC00", emissive: "#FFAA00", emissiveIntensity: 2.5, animate: "pulse"))
                            v.append(Voxel(x: 0, y: 6, z: 0, color: "#FFCC00", emissive: "#FFAA00", emissiveIntensity: 2.5, animate: "pulse"))
                            return v
                        }(),
                        glowColor: "#FF8800"
                    ),

                    // 2. Isocitrate — Frozen orange
                    Concept(
                        label: "Isocitrate",
                        originalText: "Citrate → Isocitrate (aconitase)",
                        association: "An ICY version of the orange — same shape but frozen in blue ice crystals. 'Iso' = same, just rearranged.",
                        voxels: {
                            var v = shellSphere(cx: 0, cy: 7, cz: 0, r: 6, color: "#8AACCC")
                            v += fillSphere(cx: 0, cy: 7, cz: 0, r: 4, color: "#7799BB")
                            // Ice spike on top
                            v += column(cx: 0, cy: 13, cz: 0, height: 5, color: "#BBDDFF")
                            v.append(Voxel(x: 0, y: 18, z: 0, color: "#DDEEFF", emissive: "#88CCFF", emissiveIntensity: 3.5, animate: "pulse"))
                            // Side spikes
                            v.append(Voxel(x: 7, y: 9, z: 0, color: "#BBDDFF", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: 8, y: 10, z: 0, color: "#CCDDFF", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: -7, y: 9, z: 0, color: "#BBDDFF", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: -8, y: 10, z: 0, color: "#CCDDFF", emissive: nil, emissiveIntensity: nil, animate: nil))
                            // Frozen core
                            v.append(Voxel(x: 0, y: 7, z: 0, color: "#88DDFF", emissive: "#44AAFF", emissiveIntensity: 3.5, animate: "pulse"))
                            v.append(Voxel(x: 0, y: 8, z: 0, color: "#88DDFF", emissive: "#44AAFF", emissiveIntensity: 2.5, animate: "pulse"))
                            return v
                        }(),
                        glowColor: "#44AAFF"
                    ),

                    // 3. α-Ketoglutarate — Kettle
                    Concept(
                        label: "α-Ketoglutarate",
                        originalText: "Isocitrate → α-Ketoglutarate (produces NADH + CO₂)",
                        association: "A massive iron KETTLE boiling over. Keto- = kettle, golden sparks (NADH) fly out, steam (CO₂) rises.",
                        voxels: {
                            var v = fillSphere(cx: 0, cy: 8, cz: 0, r: 5, color: "#3a3a4a")
                            // Legs
                            v += column(cx: -3, cy: 0, cz: -3, height: 4, color: "#444455")
                            v += column(cx: 3, cy: 0, cz: -3, height: 4, color: "#444455")
                            v += column(cx: -3, cy: 0, cz: 3, height: 4, color: "#444455")
                            v += column(cx: 3, cy: 0, cz: 3, height: 4, color: "#444455")
                            // Steam
                            v.append(Voxel(x: 0, y: 14, z: 0, color: "#aaaacc", emissive: "#8888aa", emissiveIntensity: 1.0, animate: "drift"))
                            v.append(Voxel(x: -1, y: 15, z: 1, color: "#9999bb", emissive: "#7777aa", emissiveIntensity: 0.9, animate: "drift"))
                            v.append(Voxel(x: 0, y: 16, z: 0, color: "#ccccee", emissive: "#aaaacc", emissiveIntensity: 0.6, animate: "drift"))
                            // Golden sparks (NADH)
                            v.append(Voxel(x: 2, y: 14, z: 1, color: "#FFdd00", emissive: "#FFcc00", emissiveIntensity: 4.0, animate: "flicker"))
                            v.append(Voxel(x: -1, y: 15, z: -2, color: "#FFee22", emissive: "#FFdd00", emissiveIntensity: 3.5, animate: "flicker"))
                            return v
                        }(),
                        glowColor: "#FFdd88"
                    ),

                    // 4. Succinyl-CoA — Cactus in a coat
                    Concept(
                        label: "Succinyl-CoA",
                        originalText: "α-Ketoglutarate → Succinyl-CoA (produces NADH + CO₂)",
                        association: "A SUCCULENT cactus wearing a fur COAT (CoA). Green cactus body with brown coat wrapping the base.",
                        voxels: {
                            var v = fillBox(x1: -1, y1: 0, z1: -1, x2: 1, y2: 10, z2: 1, color: "#2D7D3A")
                            v += fillBox(x1: -2, y1: 0, z1: -2, x2: 2, y2: 3, z2: 2, color: "#2D7D3A")
                            // Arms
                            v.append(Voxel(x: -3, y: 5, z: 0, color: "#3A8D4A", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: -3, y: 6, z: 0, color: "#4A9D5A", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: -3, y: 7, z: 0, color: "#5AAD6A", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: 3, y: 4, z: 0, color: "#3A8D4A", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: 3, y: 5, z: 0, color: "#4A9D5A", emissive: nil, emissiveIntensity: nil, animate: nil))
                            // Coat
                            v += fillBox(x1: -3, y1: 0, z1: -2, x2: -2, y2: 4, z2: -2, color: "#6B4420")
                            v += fillBox(x1: 2, y1: 0, z1: -2, x2: 3, y2: 4, z2: -2, color: "#6B4420")
                            v += fillBox(x1: -3, y1: 0, z1: 2, x2: -2, y2: 4, z2: 2, color: "#7B5430")
                            v += fillBox(x1: 2, y1: 0, z1: 2, x2: 3, y2: 4, z2: 2, color: "#7B5430")
                            // Flower on top
                            v.append(Voxel(x: 0, y: 11, z: 0, color: "#FF66AA", emissive: "#FF4488", emissiveIntensity: 3.5, animate: "pulse"))
                            v.append(Voxel(x: 1, y: 11, z: 0, color: "#FF88CC", emissive: "#FF66AA", emissiveIntensity: 1.8, animate: "pulse"))
                            v.append(Voxel(x: -1, y: 11, z: 0, color: "#FF88CC", emissive: "#FF66AA", emissiveIntensity: 1.8, animate: "pulse"))
                            return v
                        }(),
                        glowColor: "#FF88CC"
                    ),
                ]),

                Room(name: "Steps 5-8", concepts: [

                    // 5. Succinate — Trophy
                    Concept(
                        label: "Succinate",
                        originalText: "Succinyl-CoA → Succinate (produces GTP)",
                        association: "A golden SUCCESS TROPHY. Success → Succinate. The cactus shed its coat and became golden trophies.",
                        voxels: {
                            var v = fillBox(x1: -3, y1: 0, z1: -3, x2: 3, y2: 1, z2: 3, color: "#B8860B")
                            v += fillBox(x1: -1, y1: 2, z1: -1, x2: 1, y2: 6, z2: 1, color: "#DAA520")
                            v += fillBox(x1: -4, y1: 7, z1: -4, x2: 4, y2: 9, z2: 4, color: "#FFD700")
                            // Star on top
                            v.append(Voxel(x: 0, y: 10, z: 0, color: "#FFFFFF", emissive: "#FFFFAA", emissiveIntensity: 3.0, animate: "pulse"))
                            v.append(Voxel(x: 1, y: 10, z: 0, color: "#FFEE88", emissive: "#FFDD44", emissiveIntensity: 3.0, animate: "pulse"))
                            v.append(Voxel(x: -1, y: 10, z: 0, color: "#FFEE88", emissive: "#FFDD44", emissiveIntensity: 3.0, animate: "pulse"))
                            v.append(Voxel(x: 0, y: 11, z: 0, color: "#FFFFFF", emissive: "#FFFFFF", emissiveIntensity: 3.5, animate: "pulse"))
                            return v
                        }(),
                        glowColor: "#FFD700"
                    ),

                    // 6. Fumarate — Chimney
                    Concept(
                        label: "Fumarate",
                        originalText: "Succinate → Fumarate (produces FADH₂)",
                        association: "A tall brick CHIMNEY billowing purple FUMES. Fume-arate — it's fuming! Glows violet inside (FADH₂).",
                        voxels: {
                            var v = fillBox(x1: -3, y1: 0, z1: -3, x2: 3, y2: 2, z2: 3, color: "#6B3A2A")
                            v += fillBox(x1: -2, y1: 2, z1: -2, x2: 2, y2: 12, z2: -2, color: "#7B4A3A")
                            v += fillBox(x1: -2, y1: 2, z1: 2, x2: 2, y2: 12, z2: 2, color: "#6B3A2A")
                            v += fillBox(x1: -2, y1: 2, z1: -1, x2: -2, y2: 12, z2: 1, color: "#7B4A3A")
                            v += fillBox(x1: 2, y1: 2, z1: -1, x2: 2, y2: 12, z2: 1, color: "#6B3A2A")
                            v += fillBox(x1: -3, y1: 12, z1: -3, x2: 3, y2: 13, z2: 3, color: "#5B2A1A")
                            // Inner glow
                            v.append(Voxel(x: 0, y: 7, z: 0, color: "#AA55FF", emissive: "#8833EE", emissiveIntensity: 1.8, animate: "pulse"))
                            // Purple smoke
                            v.append(Voxel(x: 0, y: 14, z: 0, color: "#9955CC", emissive: "#7733AA", emissiveIntensity: 2.0, animate: "drift"))
                            v.append(Voxel(x: -1, y: 15, z: 1, color: "#AA66DD", emissive: "#8844BB", emissiveIntensity: 1.8, animate: "drift"))
                            v.append(Voxel(x: 0, y: 16, z: 0, color: "#CC88FF", emissive: "#AA66DD", emissiveIntensity: 0.7, animate: "drift"))
                            v.append(Voxel(x: 0, y: 17, z: 0, color: "#DD99FF", emissive: "#BB77EE", emissiveIntensity: 0.5, animate: "drift"))
                            return v
                        }(),
                        glowColor: "#9944FF"
                    ),

                    // 7. Malate — Crystal Mallet
                    Concept(
                        label: "Malate",
                        originalText: "Fumarate → Malate (adds H₂O)",
                        association: "A giant crystal MALLET smashing into a fountain. Malate ≈ Mallet. Water splashes everywhere (H₂O).",
                        voxels: {
                            var v = column(cx: 0, cy: 0, cz: 0, height: 8, color: "#888899")
                            v += column(cx: 1, cy: 0, cz: 0, height: 8, color: "#777788")
                            // Mallet head
                            v += fillBox(x1: -4, y1: 8, z1: -2, x2: 4, y2: 10, z2: 2, color: "#66DDDD")
                            v += fillBox(x1: -4, y1: 10, z1: -2, x2: 4, y2: 10, z2: 2, color: "#88EEFF")
                            // Crystal glow
                            v.append(Voxel(x: 0, y: 9, z: 0, color: "#88EEFF", emissive: "#44DDDD", emissiveIntensity: 3.0, animate: "pulse"))
                            v.append(Voxel(x: -2, y: 9, z: 0, color: "#77DDEE", emissive: "#33CCCC", emissiveIntensity: 3.5, animate: "pulse"))
                            v.append(Voxel(x: 2, y: 9, z: 0, color: "#77DDEE", emissive: "#33CCCC", emissiveIntensity: 3.5, animate: "pulse"))
                            // Water splash
                            v.append(Voxel(x: -2, y: 1, z: -3, color: "#44CCFF", emissive: "#22AADD", emissiveIntensity: 1.8, animate: "drift"))
                            v.append(Voxel(x: 3, y: 2, z: 2, color: "#66DDFF", emissive: "#44BBDD", emissiveIntensity: 0.8, animate: "drift"))
                            return v
                        }(),
                        glowColor: "#44DDDD"
                    ),

                    // 8. Oxaloacetate — Ox with ACE card
                    Concept(
                        label: "Oxaloacetate",
                        originalText: "Malate → Oxaloacetate (produces NADH). Cycle restarts!",
                        association: "A sturdy OX (Oxalo-) with an ACE card (acetate) on its head. Glows golden (NADH). Cycle restarts!",
                        voxels: {
                            var v: [Voxel] = []
                            // Legs
                            v += fillBox(x1: -4, y1: 0, z1: -3, x2: -3, y2: 4, z2: -2, color: "#7B5534")
                            v += fillBox(x1: 3, y1: 0, z1: -3, x2: 4, y2: 4, z2: -2, color: "#7B5534")
                            v += fillBox(x1: -4, y1: 0, z1: 2, x2: -3, y2: 4, z2: 3, color: "#7B5534")
                            v += fillBox(x1: 3, y1: 0, z1: 2, x2: 4, y2: 4, z2: 3, color: "#7B5534")
                            // Body
                            v += fillBox(x1: -4, y1: 4, z1: -3, x2: 4, y2: 8, z2: 3, color: "#8B6544")
                            // Neck + head
                            v += fillBox(x1: -2, y1: 7, z1: -6, x2: 2, y2: 9, z2: -3, color: "#8B6544")
                            v += fillBox(x1: -3, y1: 7, z1: -8, x2: 3, y2: 10, z2: -6, color: "#9B7554")
                            // Horns
                            v.append(Voxel(x: -4, y: 11, z: -7, color: "#DDCCAA", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: -5, y: 12, z: -7, color: "#EEDDBB", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: -5, y: 13, z: -6, color: "#F5EECC", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: 4, y: 11, z: -7, color: "#DDCCAA", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: 5, y: 12, z: -7, color: "#EEDDBB", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: 5, y: 13, z: -6, color: "#F5EECC", emissive: nil, emissiveIntensity: nil, animate: nil))
                            // ACE card
                            v += fillBox(x1: -3, y1: 12, z1: -9, x2: 3, y2: 16, z2: -6, color: "#FFFFFF")
                            // Red A on card
                            v.append(Voxel(x: 0, y: 16, z: -8, color: "#DD0000", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: -1, y: 15, z: -8, color: "#DD0000", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: 1, y: 15, z: -8, color: "#DD0000", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v += fillBox(x1: -1, y1: 14, z1: -8, x2: 1, y2: 14, z2: -8, color: "#DD0000")
                            v.append(Voxel(x: -2, y: 12, z: -8, color: "#DD0000", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: -2, y: 13, z: -8, color: "#DD0000", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: 2, y: 12, z: -8, color: "#DD0000", emissive: nil, emissiveIntensity: nil, animate: nil))
                            v.append(Voxel(x: 2, y: 13, z: -8, color: "#DD0000", emissive: nil, emissiveIntensity: nil, animate: nil))
                            // Golden glow (NADH)
                            v.append(Voxel(x: 0, y: 6, z: 0, color: "#FFdd00", emissive: "#FFcc00", emissiveIntensity: 3.0, animate: "pulse"))
                            v.append(Voxel(x: 0, y: 14, z: -8, color: "#FFFFFF", emissive: "#FFdd88", emissiveIntensity: 4.0, animate: "pulse"))
                            return v
                        }(),
                        glowColor: "#FFdd88"
                    ),
                ]),
            ]
        )
    }
}
