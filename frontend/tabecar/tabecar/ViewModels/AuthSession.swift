import Combine
import Foundation

@MainActor
final class AuthSession: ObservableObject {
    @Published var hasFinishedRestore = false
    @Published private(set) var accessToken: String?
    @Published var assumedUserType: UserType = .user
    @Published private(set) var biometricLoginAvailable = false
    @Published private(set) var savedEmail: String?

    var isAuthenticated: Bool {
        accessToken != nil
    }

    var biometricLabel: String {
        BiometricAuthService.label
    }

    var biometricSystemImage: String {
        BiometricAuthService.systemImage
    }

    func restore() async {
        hasFinishedRestore = false
        defer { hasFinishedRestore = true }

        if let rawType = UserDefaults.standard.string(forKey: Keys.assumedUserType),
           let type = UserType(rawValue: rawType) {
            assumedUserType = type
            hasFinishedRestore = true
        }

        let biometricEnabled = UserDefaults.standard.bool(forKey: Keys.biometricEnabled)
        savedEmail = UserDefaults.standard.string(forKey: Keys.savedEmail)

        if biometricEnabled, assumedUserType == .user {
            biometricLoginAvailable = BiometricAuthService.isAvailable()
            return
        }

        accessToken = KeychainStore.read(account: Keys.accessToken)
        APIClient.shared.accessToken = accessToken
    }

    func signIn(token: String, userType: UserType, email: String? = nil) throws {
        UserDefaults.standard.set(userType.rawValue, forKey: Keys.assumedUserType)
        assumedUserType = userType
        accessToken = token
        APIClient.shared.accessToken = token

        if userType == .user, BiometricAuthService.isAvailable(), let email {
            try KeychainStore.saveBiometric(token, account: Keys.biometricAccessToken)
            KeychainStore.delete(account: Keys.accessToken)
            UserDefaults.standard.set(true, forKey: Keys.biometricEnabled)
            UserDefaults.standard.set(email, forKey: Keys.savedEmail)
            savedEmail = email
            biometricLoginAvailable = true
        } else {
            try KeychainStore.save(token, account: Keys.accessToken)
            KeychainStore.delete(account: Keys.biometricAccessToken)
            UserDefaults.standard.set(false, forKey: Keys.biometricEnabled)
            UserDefaults.standard.removeObject(forKey: Keys.savedEmail)
            savedEmail = nil
            biometricLoginAvailable = false
        }
    }

    func loginWithBiometrics() throws {
        guard biometricLoginAvailable else { throw BiometricAuthError.unavailable }

        let reason = "\(biometricLabel)でログインする"
        guard let token = try KeychainStore.readBiometric(account: Keys.biometricAccessToken, reason: reason) else {
            clearBiometricCredentials()
            throw BiometricAuthError.failed
        }

        accessToken = token
        APIClient.shared.accessToken = token
    }

    func signOut() {
        KeychainStore.delete(account: Keys.accessToken)
        KeychainStore.delete(account: Keys.biometricAccessToken)
        UserDefaults.standard.removeObject(forKey: Keys.assumedUserType)
        UserDefaults.standard.removeObject(forKey: Keys.biometricEnabled)
        UserDefaults.standard.removeObject(forKey: Keys.savedEmail)
        accessToken = nil
        APIClient.shared.accessToken = nil
        assumedUserType = .user
        biometricLoginAvailable = false
        savedEmail = nil
    }

    private func clearBiometricCredentials() {
        KeychainStore.delete(account: Keys.biometricAccessToken)
        UserDefaults.standard.set(false, forKey: Keys.biometricEnabled)
        UserDefaults.standard.removeObject(forKey: Keys.savedEmail)
        biometricLoginAvailable = false
        savedEmail = nil
    }

    private enum Keys {
        static let accessToken = "accessToken"
        static let biometricAccessToken = "biometricAccessToken"
        static let assumedUserType = "assumedUserType"
        static let biometricEnabled = "biometricLoginEnabled"
        static let savedEmail = "savedEmail"
    }
}
