import SwiftUI

@main
struct MemoPalaceApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch appState.screen {
            case .landing:
                LandingView()
                    .transition(.opacity)
            case .loading:
                LoadingView()
                    .transition(.opacity)
            case .placement:
                PlacementView()
                    .transition(.opacity)
            case .review:
                ReviewView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.screen == .landing)
    }
}
