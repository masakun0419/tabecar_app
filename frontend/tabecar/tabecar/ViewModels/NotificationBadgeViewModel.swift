import Combine
import Foundation

@MainActor
final class NotificationBadgeViewModel: ObservableObject {
    @Published private(set) var unreadCount = 0

    private let api = TabecarAPI()

    func refresh() async {
        guard APIClient.shared.accessToken != nil else {
            unreadCount = 0
            return
        }

        do {
            unreadCount = try await api.unreadNotificationCount()
        } catch {
            unreadCount = 0
        }
    }
}
