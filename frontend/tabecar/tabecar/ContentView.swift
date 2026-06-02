import Combine
import SwiftUI

struct ContentView: View {
    @StateObject private var session = AuthSession()

    var body: some View {
        Group {
            if !session.hasFinishedRestore {
                ProgressView()
            } else if session.isAuthenticated {
                RootTabView()
                    .environmentObject(session)
            } else {
                AuthRootView()
                    .environmentObject(session)
            }
        }
        .tint(Tabecar.orange)
        .task {
            await session.restore()
        }
    }
}

#Preview {
    ContentView()
}
