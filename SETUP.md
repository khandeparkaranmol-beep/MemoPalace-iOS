# MemoPalace iOS — Xcode Setup Guide

## Prerequisites

- Mac with Xcode 15+ installed (free from App Store)
- iPhone with A12 chip or later (iPhone XS/XR and newer) — ARKit requires a physical device
- iOS 16.0+ on your iPhone
- Apple Developer account (free tier works for personal device testing)

## Step-by-Step Setup

### 1. Create a New Xcode Project

1. Open Xcode → **File → New → Project**
2. Choose **iOS → App** → Next
3. Fill in:
   - **Product Name:** `MemoPalace`
   - **Team:** Select your Apple ID / developer team
   - **Organization Identifier:** `com.yourname` (e.g., `com.anmol`)
   - **Interface:** SwiftUI
   - **Language:** Swift
   - Leave "Include Tests" unchecked (optional)
4. Click **Next**, choose a save location, and click **Create**

### 2. Add the Source Files

1. In Xcode's Project Navigator (left sidebar), **delete** the auto-generated `ContentView.swift` (Move to Trash)
2. Right-click the `MemoPalace` folder in the navigator → **Add Files to "MemoPalace"...**
3. Navigate to the `MemoPalace-iOS/MemoPalace/` folder from this repository
4. Select **all files and folders**:
   - `MemoPalaceApp.swift`
   - `Models/` folder (Palace.swift, PlacedObject.swift, AppState.swift)
   - `AR/` folder (VoxelEntityBuilder.swift, ARViewContainer.swift)
   - `Views/` folder (LandingView.swift, LoadingView.swift, PlacementView.swift, ReviewView.swift)
   - `Services/` folder (ClaudeAPIService.swift, MockData.swift)
5. Make sure **"Copy items if needed"** is checked
6. Make sure **"Create groups"** is selected (not folder references)
7. Click **Add**

### 3. Add the Info.plist Entries

**Option A — Use the provided Info.plist:**
1. Copy `MemoPalace-iOS/Info.plist` into your Xcode project's root folder
2. In Xcode, select the project (blue icon at the top of the navigator)
3. Go to **Build Settings** → search for "Info.plist File"
4. Set the value to `MemoPalace/Info.plist` (or wherever you placed it)

**Option B — Add entries manually:**
1. Select your project in the navigator → select the **MemoPalace** target
2. Go to the **Info** tab
3. Add these keys:
   - `Privacy - Camera Usage Description` → "MemoPalace uses the camera to place 3D memory objects in your real space using augmented reality."
   - `Required device capabilities` → Add item: `arkit`

### 4. Configure the Target

1. Select the project → **MemoPalace** target → **General** tab
2. Set **Minimum Deployments** to **iOS 16.0**
3. Under **Supported Destinations**, ensure **iPhone** is listed
4. Set **Device Orientation** to **Portrait** only (uncheck Landscape Left/Right)

### 5. Add Required Frameworks

The project uses ARKit and SceneKit. Xcode should auto-link them, but verify:

1. Select the project → **MemoPalace** target → **General** tab
2. Scroll to **Frameworks, Libraries, and Embedded Content**
3. If not already present, click **+** and add:
   - `ARKit.framework`
   - `SceneKit.framework`

### 6. Fix the App Entry Point

If Xcode created its own `@main` App struct, you may get a duplicate entry point error:
1. Make sure `MemoPalaceApp.swift` has the `@main` attribute
2. Delete any other file with `@main` (like a default `MemoPalaceApp.swift` that Xcode generated)

### 7. Run on Your iPhone

1. Connect your iPhone via USB (or use wireless debugging if set up)
2. Select your iPhone from the device dropdown at the top of Xcode
3. Press **⌘R** (or click the Play button)
4. If prompted, trust the developer certificate on your iPhone:
   - Go to **Settings → General → VPN & Device Management** on your phone
   - Tap your developer certificate → Trust

## How It Works

### Placement Mode
1. On launch, you'll see the landing screen. Tap **"Try demo: Krebs Cycle"** to test with built-in data, or paste your own concepts and tap **"Generate Memory Palace"**
2. The AR camera will open. Move your phone slowly to let ARKit detect surfaces (floors, tables, shelves)
3. A **green reticle** appears on detected surfaces
4. **Tap** to place each concept as a 3D voxel object. The bottom card shows which concept you're placing and its mnemonic association
5. After placing all objects, you can walk around your space to see them

### Review Mode
1. Tap **"Start Review"** after placing all objects
2. Objects appear as dimmed pink ghosts with "?" labels
3. Walk to each object and **tap** it to reveal what concept it represents
4. Try to remember before tapping — that's the memory palace technique in action

## Connecting to Claude API (Optional)

By default, the app uses built-in mock data (Krebs cycle). To enable real AI generation:

1. Open `Services/ClaudeAPIService.swift`
2. Set your Anthropic API key in `anthropicAPIKey` (for testing only)
3. For production, set up a backend proxy (e.g., Vercel serverless function) and update `apiURL`

**Important:** Never ship an app with an API key embedded in the source code. Use a server-side proxy.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| "Camera permission denied" | Go to Settings → MemoPalace → toggle Camera on |
| "ARKit not supported" | You need a physical iPhone with A12+ chip. Simulator doesn't support ARKit |
| Build error: duplicate `@main` | Delete Xcode's auto-generated App file, keep our `MemoPalaceApp.swift` |
| Reticle doesn't appear | Move phone slowly over flat surfaces (tables, floors). Good lighting helps |
| Objects floating/misplaced | Reset ARKit: close and reopen the placement view |
