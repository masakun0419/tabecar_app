import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: AuthSession

    var body: some View {
        NavigationStack {
            Form {
                Section("接続先") {
                    Text(APIClient.shared.baseURL.absoluteString)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("ログイン種別") {
                    Picker("種別", selection: $session.assumedUserType) {
                        ForEach(UserType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .onChange(of: session.assumedUserType) { _, newValue in
                        UserDefaults.standard.set(newValue.rawValue, forKey: "assumedUserType")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        session.signOut()
                    } label: {
                        Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}
