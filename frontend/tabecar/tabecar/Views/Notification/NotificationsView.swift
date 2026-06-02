import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var badgeViewModel: NotificationBadgeViewModel
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        NavigationStack {
            List {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .listRowBackground(Color.clear)
                }

                ForEach(viewModel.notifications) { notification in
                    if let shopId = notification.shopId {
                        NavigationLink {
                            ShopDetailView(shopID: shopId)
                                .task {
                                    await viewModel.markRead(notification)
                                    await badgeViewModel.refresh()
                                }
                        } label: {
                            NotificationRow(notification: notification)
                        }
                        .listRowBackground(Color.white)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                    } else {
                        Button {
                            Task {
                                await viewModel.markRead(notification)
                                await badgeViewModel.refresh()
                            }
                        } label: {
                            NotificationRow(notification: notification)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.white)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Tabecar.background)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.notifications.isEmpty && viewModel.errorMessage == nil {
                    ContentUnavailableView(
                        "通知なし",
                        systemImage: "bell",
                        description: Text("出店通知がここに表示されます")
                    )
                }
            }
            .navigationTitle("通知")
            .toolbar {
                if viewModel.notifications.contains(where: { !$0.isRead }) {
                    Button("すべて既読") {
                        Task {
                            await viewModel.markAllRead()
                            await badgeViewModel.refresh()
                        }
                    }
                }
            }
            .task {
                await viewModel.load()
                await badgeViewModel.refresh()
            }
            .refreshable {
                await viewModel.load()
                await badgeViewModel.refresh()
            }
        }
        .tint(Tabecar.orange)
    }
}

private struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(notification.isRead ? Color(.systemGray5) : Tabecar.orange.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: notification.isRead ? "bell" : "bell.fill")
                    .foregroundStyle(notification.isRead ? Tabecar.textSecondary : Tabecar.orange)
                    .font(.system(size: 17))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundStyle(notification.isRead ? Tabecar.textSecondary : Tabecar.textPrimary)
                    Spacer()
                    if !notification.isRead {
                        Circle()
                            .fill(Tabecar.orange)
                            .frame(width: 8, height: 8)
                    }
                    Text(notification.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(Tabecar.textSecondary)
                }
                Text(notification.body)
                    .font(.subheadline)
                    .foregroundStyle(Tabecar.textSecondary)
                Text(notificationTypeLabel)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Tabecar.orange.opacity(0.1))
                    .foregroundStyle(Tabecar.orange)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
        .opacity(notification.isRead ? 0.75 : 1)
    }

    private var notificationTypeLabel: String {
        switch notification.notificationType {
        case "FAVORITE_EVENT":
            "お気に入り"
        case "NEARBY_EVENT":
            "近くの出店"
        default:
            notification.notificationType
        }
    }
}
