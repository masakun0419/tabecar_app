import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: AuthSession
    @ObservedObject private var locationService = LocationService.shared
    @State private var radiusKm = 5
    @State private var isSavingRadius = false
    @State private var radiusMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("接続先") {
                    Text(APIClient.shared.baseURL.absoluteString)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if session.assumedUserType == .user {
                    Section("近隣通知") {
                        Stepper(value: $radiusKm, in: 1...100) {
                            Text("通知半径: \(radiusKm) km")
                        }

                        if let radiusMessage {
                            Text(radiusMessage)
                                .font(.caption)
                                .foregroundStyle(radiusMessage.contains("保存") ? .green : .red)
                        }

                        Button {
                            Task { await saveRadius() }
                        } label: {
                            if isSavingRadius {
                                ProgressView()
                            } else {
                                Text("通知半径を保存")
                            }
                        }
                        .disabled(isSavingRadius)
                    }
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
            .onAppear {
                radiusKm = locationService.notificationRadiusKm
            }
        }
    }

    private func saveRadius() async {
        isSavingRadius = true
        radiusMessage = nil
        defer { isSavingRadius = false }

        do {
            try await locationService.updateNotificationRadius(radiusKm)
            radiusMessage = "通知半径を保存しました"
        } catch {
            radiusMessage = error.localizedDescription
        }
    }
}
