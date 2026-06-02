import SwiftUI

struct ContentView: View {
    @StateObject private var session = AuthSession()

    var body: some View {
        Group {
            if session.isAuthenticated {
                RootTabView()
                    .environmentObject(session)
            } else {
                AuthRootView()
                    .environmentObject(session)
            }
        }
        .task {
            await session.restore()
        }
    }
}

#Preview {
    ContentView()
}
