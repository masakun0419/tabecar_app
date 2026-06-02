import Foundation

@MainActor
final class AuthSession: ObservableObject {
    @Published private(set) var accessToken: String?
    @Published var assumedUserType: UserType = .user

    var isAuthenticated: Bool {
        accessToken != nil
    }

    func restore() async {
        accessToken = KeychainStore.read(account: "accessToken")
        APIClient.shared.accessToken = accessToken
        if let rawType = UserDefaults.standard.string(forKey: "assumedUserType"),
           let type = UserType(rawValue: rawType) {
            assumedUserType = type
        }
    }

    func signIn(token: String, userType: UserType) throws {
        try KeychainStore.save(token, account: "accessToken")
        UserDefaults.standard.set(userType.rawValue, forKey: "assumedUserType")
        accessToken = token
        APIClient.shared.accessToken = token
        assumedUserType = userType
    }

    func signOut() {
        KeychainStore.delete(account: "accessToken")
        UserDefaults.standard.removeObject(forKey: "assumedUserType")
        accessToken = nil
        APIClient.shared.accessToken = nil
        assumedUserType = .user
    }
}
