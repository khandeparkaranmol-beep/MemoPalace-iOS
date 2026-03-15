# MemoPalace

An iOS AR app that turns any concept into a 3D memory palace you can place in your real space.

Paste what you want to learn, and MemoPalace generates vivid 3D voxel objects — each one a visual mnemonic — that you place around your room using ARKit. Walk around to review, tap to recall. It's the ancient Method of Loci, brought to life with augmented reality.

## How It Works

1. **Enter concepts** — paste text you want to memorize (e.g., the Krebs cycle, vocabulary, historical events)
2. **AI generates mnemonics** — Claude creates memorable visual associations and 3D voxel models for each concept
3. **Place in AR** — use your iPhone camera to place each 3D object on real surfaces around your room
4. **Review & recall** — walk back through your space, tap ghosted objects to test your memory

## Tech Stack

- **SwiftUI** — declarative UI
- **ARKit + SceneKit** — real-world surface detection, 3D voxel rendering
- **Claude API** — AI-powered mnemonic generation (with built-in demo data)

## Requirements

- iPhone XS/XR or newer (A12+ chip)
- iOS 16.0+
- Xcode 15+

## Quick Start

See [SETUP.md](SETUP.md) for full Xcode setup instructions.

**TL;DR:**
1. Create a new Xcode iOS App project (SwiftUI, Swift)
2. Delete the auto-generated `ContentView.swift`
3. Drag in all files from the `MemoPalace/` folder
4. Add `Info.plist` to the project
5. Run on your iPhone — tap **"Try demo: Krebs Cycle"** to test immediately

## Project Structure

```
MemoPalace/
├── MemoPalaceApp.swift          # App entry point
├── Models/
│   ├── Palace.swift             # Data models (Palace, Room, Concept, Voxel)
│   ├── PlacedObject.swift       # AR-placed object with world position
│   └── AppState.swift           # Observable state machine
├── AR/
│   ├── ARViewContainer.swift    # ARKit + SceneKit integration
│   └── VoxelEntityBuilder.swift # Converts voxel data → 3D SceneKit nodes
├── Views/
│   ├── LandingView.swift        # Text input screen
│   ├── LoadingView.swift        # Generation loading screen
│   ├── PlacementView.swift      # AR placement with HUD overlay
│   └── ReviewView.swift         # AR review/recall mode
└── Services/
    ├── ClaudeAPIService.swift   # Anthropic API integration
    └── MockData.swift           # Built-in Krebs cycle demo (8 objects)
```

## License

MIT
# MemoPalace-iOS
