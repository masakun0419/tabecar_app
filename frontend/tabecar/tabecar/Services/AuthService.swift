import Foundation

struct AuthService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func login(email: String, password: String) async throws -> TokenResponse {
        try await client.post("/auth/login", body: LoginRequest(email: email, password: password))
    }

    func register(email: String, password: String, displayName: String, userType: UserType) async throws -> User {
        try await client.post(
            "/auth/register",
            body: RegisterRequest(email: email, password: password, displayName: displayName, userType: userType.rawValue)
        )
    }
}

private struct LoginRequest: Encodable {
    let email: String
    let password: String
}

private struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let displayName: String
    let userType: String
}
