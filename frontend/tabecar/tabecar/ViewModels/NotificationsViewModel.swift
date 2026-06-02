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

    func markRead(_ notification: AppNotification) async {
        guard !notification.isRead else { return }

        do {
            let updated = try await api.markNotificationRead(id: notification.id)
            replace(notification: updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllRead() async {
        do {
            _ = try await api.markAllNotificationsRead()
            notifications = notifications.map { current in
                AppNotification(
                    id: current.id,
                    shopId: current.shopId,
                    eventId: current.eventId,
                    notificationType: current.notificationType,
                    title: current.title,
                    body: current.body,
                    isRead: true,
                    createdAt: current.createdAt
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func replace(notification: AppNotification) {
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        notifications[index] = notification
    }
}
