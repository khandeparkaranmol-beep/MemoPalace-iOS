import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var appState: AppState
    @State private var dotCount = 0
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.indigo)

            Text(appState.loadingMessage + String(repeating: ".", count: dotCount))
                .font(.headline)
                .foregroundColor(.white)

            Text("The LLM is crafting memorable objects\nfor each concept")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }
}
