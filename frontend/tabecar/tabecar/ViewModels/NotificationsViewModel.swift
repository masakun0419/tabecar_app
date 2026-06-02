import Combine
import Foundation

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published private(set) var notifications: [AppNotification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = TabecarAPI()

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            notifications = try await api.notifications()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

