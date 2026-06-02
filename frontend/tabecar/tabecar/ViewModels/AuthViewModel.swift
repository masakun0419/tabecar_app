import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var displayName = ""
    @Published var userType: UserType = .user
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = AuthService()

    var canLogin: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var canRegister: Bool {
        !email.isEmpty && password.count >= 8 && !displayName.isEmpty
    }

    func login(session: AuthSession) async {
        guard canLogin else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await service.login(email: email, password: password)
            try session.signIn(token: response.accessToken, userType: userType)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func registerThenLogin(session: AuthSession) async {
        guard canRegister else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await service.register(email: email, password: password, displayName: displayName, userType: userType)
            let response = try await service.login(email: email, password: password)
            try session.signIn(token: response.accessToken, userType: userType)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
